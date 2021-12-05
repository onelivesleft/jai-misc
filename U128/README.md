# U128

Provides a `U128` type that currently supports bitwise and comparison operators.

```jai
#import "Basic";
#import "U128";

main :: () {
    foo := u128(65535, 0);
    bar := u128(65535);
    qux := foo | bar;
    print("Qux = %\n", format(qux, base=2, separator="_"));
}
```
