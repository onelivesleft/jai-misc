#import "Hash_Table";

main :: () {
    array : Table(int, int);
    foo := other(array); @Becomes_Invalid
}

other :: (array: [] int) -> *int {
    return null;
}
