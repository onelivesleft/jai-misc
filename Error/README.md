# Error

Provides `print_error` print-like that outputs to stderr.

```jai
#import "Basic";
#import "Error";

main :: () {
    print("This is standard output\n");
    print_error("BUT THIS IS AN ERROR!\n");
}
```
