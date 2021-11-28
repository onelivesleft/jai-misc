// Everything in this file is a copypaste from `Print.jai`, `String_Builder.jai`, or `Runtime_Support.jai`,
// then modified to work with stderr.


print_error :: (format_string: string, args: .. Any) -> bytes_printed: s64 {
    builder: String_Builder;
    defer free_buffers(*builder);

    print_to_builder(*builder, format_string, ..args);
    written := write_builder_to_stderr(*builder);

    return written;
} @PrintLike


write_builder_to_stderr :: (using b: *String_Builder) -> s64 {
    if !allocator.proc return 0;

    buffer  := *base_buffer;
    written := 0;
    while buffer {
        s: string = ---;
        s.data  = buffer.data.data;
        s.count = buffer.occupied;

        write_string_to_stderr(s);
        written += s.count;

        buffer = buffer.next;
    }

    return written;
}


write_string_to_stderr :: (s: string) #no_context {
    ensure_synchronization_is_initted();

    #if OS == .WINDOWS {
        EnterCriticalSection(*write_error_string_critical_section);
        write_string_to_stderr_unsynchronized(s);
        LeaveCriticalSection(*write_error_string_critical_section);
    } else {
        pthread_mutex_lock(*write_string_error_mutex);
        write_string_to_stderr_unsynchronized(s);
        pthread_mutex_unlock(*write_string_error_mutex);
    }
}


write_string_to_stderr_unsynchronized :: (s: string) #no_context {
    #if OS == .WINDOWS {
        // @Robustness @Incomplete: Fails if s.count doesn't fit in an u32.
        written: u32;
        status := WriteFile(windows_standard_error, s.data, cast(u32) s.count, *written, null);
    } else {
        STDERR_FILENO :: 2;
        written: ssize_t;

        while written != s.count {
            result := write(STDERR_FILENO, s.data + written, cast(u64) (s.count - written));
            // We should probably be checking errno for failures,
            // but, on macOS at least, we seem to be getting interrupted
            // only be EAGAIN.
            if result < 0 continue;

            written += result;
        }
    }
}



#scope_file



#import "Basic";


#if OS == .WINDOWS {
    kernel32     :: #foreign_system_library "kernel32";
    crt          :: #foreign_system_library "msvcrt";  // For malloc, free on Windows

    WriteFile    :: (handle: *void, buffer: *void, buffer_length: u32, written_result: *u32, overlapped: *void) -> s32 #foreign kernel32;
    GetStdHandle :: (handle: s32) -> *void #foreign kernel32;

    EnterCriticalSection :: (lpCriticalSection: *_CRITICAL_SECTION) #foreign kernel32;
    LeaveCriticalSection :: (lpCriticalSection: *_CRITICAL_SECTION) #foreign kernel32;

    // Our mutex / critical sections are just dummies to hold as much memory as we need, so we don't bloat Runtime_Support.
    _CRITICAL_SECTION :: struct {
        memory: [40] u8;
    }

    write_error_string_critical_section: _CRITICAL_SECTION;
    windows_standard_output: *void;
} else #if (OS == .MACOS) || (OS == .LINUX) {
    crt      :: #foreign_system_library "libc";
    pthreads :: #foreign_system_library "libpthread";

    size_t  :: u64;
    ssize_t :: s64;
    write :: (fd: s32, buf: *void, count: size_t) -> ssize_t #foreign crt;
    pthread_mutex_lock    :: (mutex: *_pthread_mutex_t) -> s32 #foreign pthreads;
    pthread_mutex_unlock  :: (mutex: *_pthread_mutex_t) -> s32 #foreign pthreads;

    // Our mutex / critical sections are just dummies to hold as much memory as we need, so we don't bloat Runtime_Support.
    _pthread_mutex_t :: struct {
        memory: [40] u8;
    }

    write_string_error_mutex: _pthread_mutex_t;
}

synch_initted: s32 = 0;
ensure_synchronization_is_initted :: inline () #no_context {
    // Courtesy of Jeff Roberts.
    // 0 = uninitialized, 1 = in progress init, 2 = initialized

    while 1 {
        // @Warning: Apparently this read may not work on ARM, we need to look into it.
        // The goal here is just to avoid the overhead of spamming the compare_and_swap.
        if synch_initted == 2  break;

        old := my_compare_and_swap(*synch_initted, 0, 1);
        if old == {
          case 0;
            init_synchronization();
            if my_compare_and_swap(*synch_initted, 1, 2) != 1  debug_break();  // Should not happen!
          case 1;
            // Maybe some exponential fall offy thing here?
            for 1..4 #asm { pause; pause; pause; pause; pause; }
          case 2;
        }
    }
}


// We don't want to take a dependency on Atomics, so here is a simple one that just does s32.
my_compare_and_swap  :: inline (dest: *s32, old: s32, new: s32) -> (actual_old_value: s32) #no_context {
    #asm {
        old === a;
        lock_cmpxchg.d old, [dest], new;
    }

    return old;
}


windows_standard_error : *void;

init_synchronization :: () #no_context {
    // For now, we do not bother to destroy write_error_string_critical_section, etc
    // on shutdown.
    #if OS == .WINDOWS {
        InitializeCriticalSection :: (section: *_CRITICAL_SECTION) #foreign kernel32;
        InitializeCriticalSection(*write_error_string_critical_section);

        STD_ERROR_HANDLE  :: -12;
        windows_standard_error = GetStdHandle(STD_ERROR_HANDLE);
    } else {
        _pthread_mutexattr_t :: struct { size: [16] s8; }
        _PTHREAD_MUTEX_RECURSIVE_NP :: 1;
        pthread_mutexattr_init    :: (attr: *_pthread_mutexattr_t) -> s32             #foreign pthreads;
        pthread_mutexattr_settype :: (attr: *_pthread_mutexattr_t, type:  s32) -> s32 #foreign pthreads;
        pthread_mutex_init        :: (mutex: *_pthread_mutex_t, attr: *_pthread_mutexattr_t) -> s32 #foreign pthreads;

        attr: _pthread_mutexattr_t;
        pthread_mutexattr_init(*attr);
        pthread_mutexattr_settype(*attr, _PTHREAD_MUTEX_RECURSIVE_NP);
        pthread_mutex_init(*write_string_error_mutex, *attr);  // This had better not fail!
    }
}
