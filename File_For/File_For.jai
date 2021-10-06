read_file :: (filepath: string, buffer: [] u8) -> File_For {
    file_for : File_For = ---;
    file_for.type = .BUFFER;
    file_for.filepath = filepath;
    file_for.buffer = buffer;
    return file_for;
}

read_file :: (filepath: string, size: s64, allocator := context.allocator, allocator_data := context.allocator_data) -> File_For {
    file_for : File_For = ---;
    file_for.type = .SIZE;
    file_for.filepath = filepath;
    file_for.size = size;
    file_for.allocator = allocator;
    file_for.allocator_data = allocator_data;
    return file_for;
}


for_expansion :: (file_for: *File_For, body: Code, flags: For_Flags) #expand {
    assert(flags == 0, "Reverse/Pointer loops are not supported");

    `it : string = ---;
    `it_index := false;

    data : *void = ---;
    buffer_size : s64 = ---;
    if file_for.type == .BUFFER {
        data = file_for.buffer.data;
        buffer_size = file_for.buffer.count;
    }
    else {
        data = alloc(file_for.size, file_for.allocator, file_for.allocator_data);
        buffer_size = file_for.size;
    }

    if file_for.type == .SIZE && !data {
        it = "5: Failed to allocate buffer.";
        it_index = true;
        #insert body;
        return;
    }

    defer if file_for.type == .SIZE
        free(data, file_for.allocator, file_for.allocator_data);

    file, file_ok := file_open(file_for.filepath);
    if !file_ok {
        it = "0: Failed to open file.";
        it_index = true;
        #insert body;
        return;
    }

    defer file_close(*file);

    file_size, file_size_ok := file_length(file);
    if !file_size_ok {
        it = "1: Failed to find size of file.";
        it_index = true;
        #insert body;
        return;
    }

    cursor, cursor_ok := file_current_position(file);
    if !cursor_ok {
        it = "2: Failed to find cursor position.";
        it_index = true;
        #insert body;
        return;
    }

    cursor_ok = file_set_position(file, 0);
    if !cursor_ok {
        it = "3: Failed to set cursor position.";
        it_index = true;
        #insert body;
        return;
    }

    total_read := 0;
    it.data = data;

    while total_read < file_size {
        to_read := file_size - total_read;
        if to_read > buffer_size  to_read = buffer_size;

        read_ok, bytes_read := file_read(file, data, to_read);
        if !read_ok {
            it = "4: Failed to read from file.";
            it_index = true;
            #insert body;
            return;
        }

        total_read += bytes_read;
        it.count = bytes_read;
        #insert body;
    }
}



#scope_file



#import "Basic";
#import "File";


File_For :: struct {
    type : enum {BUFFER; SIZE;};
    filepath : string;
    allocator : Allocator;
    allocator_data : *void;
    union {
        buffer : [] u8;
        size : s64;
    }
}
