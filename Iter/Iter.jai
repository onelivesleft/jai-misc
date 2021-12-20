#import "Basic";


Map :: struct(iterator_type: Type, input_type: Type, output_type: Type) {
    iterator : iterator_type;
    function : (input_type) -> output_type;
}


map :: (iterator: $T, f : (input: $U) -> $V) -> Map(T, U, V) {
   result : Map(T, U, V) = ---;
   result.iterator = iterator;
   result.function = f;
   return result;
}


for_expansion :: (m: *Map, body: Code, flags: For_Flags) #expand {
    for other_it, other_index: m.iterator {
        `it := m.function(other_it);
        `it_index := other_index;
        #insert body;
    }
}
