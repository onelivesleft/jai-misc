#import "Basic";
#import ".Scratch/v1.0.8/jai-string.onelivesleft";


main :: () {
    array : [..] int;
    //foo : *s64;
    //foo = *array[0];
    //baz := *array[0];
    //bar := other(array);
    qux := array_add(*array);
}


other :: (array: [] int) -> *int {
    return null;
}
