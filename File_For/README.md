# File_For

Most of the time you want to just read a file in in one go and then process its data, which the standard `File` module lets you do with `read_entire_file`.  However, sometimes this might not be the correct approach: for instance, the file might be 20GB in size.  In that case you want to read it in in chunks, which the `File` module will let you do, but which requires a bunch of micro-management and error checking.

`read_file` lets you read in a file using a `for` loop.  You can set up a buffer (`[n] u8`) yourself, or pass in a size (and optional `Allocator`) for it to set up for you.  Each iteration of the loop `it` will be set to the next chunk of data, while `it_index` will be set to `true` if an error has occured (if an error has occured then `it` will also be set to a string detailing the error).

Example:

```jai
#import "Basic";
#import "File_For";

filepath :: "File_For.jai";

buffer : [64] u8;  // Normally you'd want to use a much bigger buffer than this

main :: () {
    // Using buffer you've set up already
    for chunk, error: read_file(filepath, buffer) {
        if error {
            print("\n\nFAILED TO READ:\n%\n\n", chunk);
            exit(1);
        }
        print(chunk);
    }

    // Sets up a buffer itself of the size provided
    for chunk, error: read_file(filepath, 64, __temporary_allocator) {
        if error {
            print("\n\nFAILED TO READ:\n%\n\n", chunk);
            exit(2);
        }
        print(chunk);
    }
}
```
