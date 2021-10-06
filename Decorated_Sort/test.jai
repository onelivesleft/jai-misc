#import "Basic";
#import "Decorated_Sort";


letters := #run cast([]u8) "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
typed_buffer : [1024] Typed_Decoration(u8, int);
buffer : [1024] Decoration;


main :: () {
    {
        decorated := decorate(letters, typed_buffer, index_of_letter);

        quick_sort(decorated);

        for undecorate(decorated) {
            print("%", as_string(*it));
        }
        print("\n");
    }

    {
        decorated := decorate(letters, buffer, index_of_letter);

        quick_sort(decorated);

        for undecorate(letters, decorated) {
            print("%", as_string(*it));
        }
        print("\n");
    }
}


// @TODO This makes the compiler allocate a gajillion ram then crash:
//   index_of_letter :: (letter) => to_upper(letter) * 2 + ifx is_lower(letter) then 1 else 0;
// Report it after v86 if it isn't better.


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
