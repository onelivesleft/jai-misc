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
