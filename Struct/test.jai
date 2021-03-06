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
    print("f2: %\n\n", f2);


    // An initializer is a proc which takes a pointer to the struct

    init_foo :: (f: *Foo) {
        f.total = f.value + f.default_value;
    }

    fooo :: #insert #run constructor(Foo, initializer=init_foo);

    f3 := fooo();
    print("f3: %\n", f3);

    f4 := fooo(2, 3, *f3, float);
    print("f4: %\n\n", f4);


    // `String_Builder` contains an inner struct called `Buffer` which we don't have access to.
    // We could disinclude members which use it by adding them to the `blacklist`, but in actuality
    // the only member we might want to set on `String_Builder` is `allocator` so we'll `whitelist` that instead.
    // The `initializer` parameter needs to be a proc which takes only one parameter: a pointer to the struct.
    // Therefor we bake the optional `buffer_size` parameter away.
    string_builder :: #insert #run constructor(String_Builder,
                                               initializer=#bake_arguments init_string_builder(buffer_size=-1),
                                               whitelist=.["allocator"]);

    builder := string_builder();
    print_to_builder(*builder, "Help I am a %", "robot");
    print("%\n", builder_to_string(*builder));
}
