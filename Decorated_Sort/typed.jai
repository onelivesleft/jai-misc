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


undecorate :: (buffer: [] Typed_Decoration($T, $U)) -> Typed_Undecorated(T, U) {
    undecorated : Typed_Undecorated(T, U) = ---;
    undecorated.buffer = buffer;
    return undecorated;
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
