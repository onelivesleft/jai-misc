#import "Basic";
#import "File_For";

filepath :: "File_For.jai";

buffer : [64] u8;

main :: () {
    for chunk, error: read_file(filepath, buffer) {
        if error {
            print("\n\nFAILED TO READ:\n%\n\n", chunk);
            exit(1);
        }
        print(chunk);
    }

    for chunk, error: read_file(filepath, 64) {
        if error {
            print("\n\nFAILED TO READ:\n%\n\n", chunk);
            exit(2);
        }
        print(chunk);
    }
}
