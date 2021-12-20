#import "Basic";
#import "Compiler";


constructor :: ($type : Type, $initializer := "", $blacklist := string.[], $whitelist := string.[]) -> string #expand {
    verbose_struct_print();

    info := type_info(type);
    assert(info.info.type == .STRUCT, "Expected a struct: constructor may only be used with struct types.");

    builder : String_Builder;
    init_string_builder(*builder);

    dummy : type;

    append(*builder, "(");
    argument_count := 0;

    should_skip :: () -> bool #expand {
        if `it.flags & .CONSTANT  return true;
        #if `whitelist.count {
            return !contains(`whitelist, `it.name);
        }
        #if `blacklist.count {
            return contains(`blacklist, `it.name);
        }
        return false;
    }

    for info.members {
        if should_skip()  continue;

        if argument_count  append(*builder, ", ");
        argument_count += 1;

        if it.type.type == {
            case .TYPE;
            print_to_builder(*builder, "%1 : %2 = void", it.name, <<cast(*Type)*it.type);
            continue;

            case .STRUCT;
            print_to_builder(*builder, "%1 : %2 = .{}", it.name, <<cast(*Type)*it.type);
            continue;
        }

        default : Any = ---;
        default.type = it.type;
        default.value_pointer = (cast(*void)*dummy) + it.offset_in_bytes;

        if it.type.type == .PROCEDURE {
            s := sprint("%", <<cast(*Type)*it.type);
            s.data += "procedure ".count;
            s.count -= "procedure ".count;
            print_to_builder(*builder, "%1 : %2 = %3", it.name, s, default);
        }
        else {
            print_to_builder(*builder, "%1 : %2 = %3", it.name, <<cast(*Type)*it.type, default);
        }
    }

    print_to_builder(*builder, #string __jai
) -> %1 {
    result : %1;
__jai, info.name);

    for info.members {
        if should_skip()  continue;
        print_to_builder(*builder, "    result.%1 = %1;\n", it.name, <<cast(*Type)*it.type);
    }

    if initializer {
        print_to_builder(*builder, "    %1(*result);\n", initializer);
    }

    append(*builder, #string __jai
    return result;
};
__jai);

    return builder_to_string(*builder);

}


verbose_struct_print :: () {
    format := *context.print_style.default_format_struct;
    format.use_long_form_if_more_than_this_many_members = 0;
    format.use_newlines_if_long_form = true;
}


#scope_file


contains :: (haystack: [] string, needle: string) -> bool {
    for haystack  if it == needle  return true;
    return false;
}
