Typed_Decoration :: struct(type: Type, index_type := int) {
    index : index_type;
    data : *type;
}


operator < :: (a: Typed_Decoration, b: Typed_Decoration) -> bool {
    return a.index < b.index;
}


decorate :: (array: [] $T, buffer: [] Typed_Decoration(T, $U), f: (T) -> U) -> [] Typed_Decoration(T, U) {
    assert(buffer.count >= array.count, "Buffer is not large enough for that array.");

    for i: 0 .. array.count - 1 {
        buffer[i].index = f(array[i]);
        buffer[i].data = *array[i];
    }

    result : [] Typed_Decoration(T, U) = ---;
    result.data = buffer.data;
    result.count = array.count;

    return result;
}


undecorate :: (decorated: [] Typed_Decoration($T, $U)) -> Typed_Undecorated(T, U) {
    undecorated : Typed_Undecorated(T, U) = ---;
    undecorated.buffer = decorated;
    return undecorated;
}


copy :: (decorated: [] Typed_Decoration($T, $U), allocator := context.allocator, allocator_data := context.allocator_data) -> [] T {
    array : [] T = ---;
    array.count = decorated.count;
    array.data = alloc(array.count, allocator, allocator_data);
    for decorated_item, i: decorated {
        array[i] = <<decorated_item.data;
    }
    return array;
}


apply :: (array: [] $T, decorated: [] Typed_Decoration(T, $U), allocator := __temporary_allocator, allocator_data : *void = null) {
    assert(decorated.count >= array.count, "Decorated buffer is not large enough for that array.");

    if !allocator {
        allocator = context.allocator;
        allocator_data = context.allocator_data;
    }

    intermediate := copy(decorated, allocator, allocator_data);
    defer free(intermediate.data, allocator, allocator_data);

    memcpy(array.data, intermediate.data, array.count);
}


apply :: (array: [] $T, decorated: [] Typed_Decoration(T, $U), intermediate: [] T) {
    assert(decorated.count >= array.count, "Decorated buffer is not large enough for that array.");
    assert(intermediate.count >= array.count, "Intermediate array is not large enough for that array.");

    for i: 0 .. array.count - 1 {
        intermediate[i] = <<decorated[i].data;
    }

    memcpy(array.data, intermediate.data, intermediate.count);
}


Typed_Undecorated :: struct(type: Type, index_type := int) {
    buffer : [] Typed_Decoration(type, index_type);
}


for_expansion :: (info: *Typed_Undecorated, body: Code, flags: For_Flags) #expand {
    assert(flags == 0);

    for item, `it_index: info.buffer {
        `it := <<item.data;
        #insert body;
    }
}
