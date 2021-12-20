# Struct

Provides utilities for working with structs


## `verbose_struct_print`

Calling `verbose_struct_print()` will set up the context so that when you use `print` et al. on a struct the output is in a verbose, detailed format.


## `constructor`

`constructor` is a macro which generates a constructor for the given struct.  It has the following parameters:

* `type`: The struct type
* `intializer`: The name of an initializer procedure - a procedure which takes a pointer to the struct as its single parameter.
* `blacklist`: A list of member names which if present will preclude them from being added to the constructor.  Sometimes the type of a struct member is not accessible outside the struct or at your scope level, so it must be disabled.
* `whitelist`: As `blacklist`, but reversed: it allows the listed names, precluding all others.

```jai
#import "Basic";
#import "Struct";


main :: () {
    verbose_struct_print();


    Foo :: struct {
        value : int;
        default_value := 101;
        other : *Foo;
        type : Type;
        total : int = ---;
    }


    foo :: #insert #run constructor(Foo);

    f1 := foo();
    print("f1: %\n", f1);

    f2 := foo(2, 3, *f1, int);
    print("f2: %\n", f2);


    // An initializer is a proc which takes a pointer to the struct

    init_foo :: (f: *Foo) {
        f.total = f.value + f.default_value;
    }

    fooo :: #insert #run constructor(Foo, initializer="init_foo");

    f3 := fooo();
    print("f3: %\n", f3);

    f4 := fooo(2, 3, *f3, float);
    print("f4: %\n", f4);


    // `String_Builder` contains an inner struct called `Buffer` which we don't have access to,
    // so we disallow members that use it by adding them to the `blacklist`.
    string_builder :: #insert #run constructor(String_Builder, initializer="init_string_builder",
                                               blacklist=.["base_buffer", "current_buffer"]);

    builder := string_builder();
    print_to_builder(*builder, "Help I am a %", "robot");
    print("%\n", builder_to_string(*builder));
}
```
