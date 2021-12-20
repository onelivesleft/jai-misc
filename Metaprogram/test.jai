#import "Hash_Table";

main :: () {
    array : [..] int;
    foo := other(array); @Becomes_Invalid
}

other :: (array: [] int) -> *int {
    return null;
}
