Decoration :: struct {
    sort_index : int;
    value_index : int;
}


operator < :: (a: Decoration, b: Decoration) -> bool {
    return a.sort_index < b.sort_index;
}


decorate :: (array: [] $T, buffer: [] Decoration, f: (T) -> int) -> [] Decoration {
    assert(buffer.count >= array.count, "Buffer is not large enough for that array.");

    for i: 0 .. array.count - 1 {
        buffer[i].sort_index = f(array[i]);
        buffer[i].value_index = i;
    }

    result : [] Decoration = ---;
    result.data = buffer.data;
    result.count = array.count;

    return result;
}


undecorate :: (array: [] $T, buffer: [] Decoration) -> Undecorated(T) {
    assert(buffer.count >= array.count, "Buffer is not large enough for that array.");

    undecorated : Undecorated(T) = ---;
    undecorated.array = array;
    undecorated.buffer = buffer;
    return undecorated;
}



copy :: (array: [] $T, decorated: [] Decoration, allocator := context.allocator) -> [] T {
    assert(decorated.count >= array.count, "Decorated buffer is not large enough for that array.");

    result : [] T = ---;
    result.count = array.count;
    result.data = alloc(result.count, allocator);
    for decorated_item, i: decorated {
        result[i] = array[decorated[i].value_index];
    }
    return result;
}


apply :: (array: [] $T, decorated: [] Decoration, allocator := temp) {
    assert(decorated.count >= array.count, "Decorated buffer is not large enough for that array.");

    if !allocator {
        allocator = context.allocator;
        allocator_data = context.allocator_data;
    }

    intermediate := copy(array, decorated, allocator, allocator_data);
    defer free(intermediate.data, allocator, allocator_data);

    memcpy(array.data, intermediate.data, intermediate.count);
}


apply :: (array: [] $T, decorated: [] Decoration, intermediate: [] T) {
    assert(decorated.count >= array.count, "Decorated buffer is not large enough for that array.");
    assert(intermediate.count >= array.count, "Intermediate array is not large enough for that array.");

    for i: 0 .. array.count - 1{
        intermediate[i] = array[decorated[i].value_index];
    }

    memcpy(array.data, intermediate.data, intermediate.count);
}


Undecorated :: struct(type: Type) {
    array : [] type;
    buffer : [] Decoration;
}


for_expansion :: (info: *Undecorated, body: Code, flags: For_Flags) #expand {
    assert(flags == 0);

    for buffer_item, `it_index: info.buffer {
        `it := info.array[buffer_item.value_index];
        #insert body;
    }
}
