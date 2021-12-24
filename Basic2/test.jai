test :: false;
#if test {
    #import "Basic";
    #import "Struct";
    #import "Error";
}
else {
    #import "Basic2";
}


main :: () {
    string_builder :: #insert #run constructor(String_Builder, #bake_arguments init_string_builder(buffer_size=1), whitelist=.["allocator"]);
    builder := string_builder();
    append(*builder, "Hello, World\n");
    print_error(builder_to_string(*builder));
}
