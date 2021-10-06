#import "Basic";
#import "Decorated_Sort";


letters := #run cast([]u8) "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
typed_buffer : [1024] Typed_Decoration(u8, int);
buffer : [1024] Decoration;
intermediate : [1024] u8;
use_intermediate :: true;

main :: () {
    {
        decorated := decorate(letters, typed_buffer, index_of_letter);

        quick_sort(decorated);

        for undecorate(decorated) {
            print("%", as_string(*it));
        }
        print("\n");

        sorted := copy(decorated);
        for sorted {
            print("%", as_string(*it));
        }
        print("\n");

        #if use_intermediate
            apply(letters, decorated, intermediate);
        else
            apply(letters, decorated);
        for letters {
            print("%", as_string(*it));
        }
        print("\n");
    }

    print("\n");

    {
        decorated := decorate(letters, buffer, index_of_letter);

        quick_sort(decorated);

        for undecorate(letters, decorated) {
            print("%", as_string(*it));
        }
        print("\n");

        sorted := copy(letters, decorated);
        for sorted {
            print("%", as_string(*it));
        }
        print("\n");

        #if use_intermediate
            apply(letters, decorated, intermediate);
        else
            apply(letters, decorated);
        for letters {
            print("%", as_string(*it));
        }
        print("\n");
    }
}


index_of_letter :: (letter: u8) -> int {
    return to_upper(letter) * 2 + ifx is_lower(letter) then 1 else 0;
}


is_lower :: inline (a: u8) -> bool {
    return a >= #char "a" && a <= #char "z";
}


as_string :: (c: *u8) -> string {
    result : string = ---;
    result.data = c;
    result.count = 1;
    return result;
}
