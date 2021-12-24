#import "Basic";
#import "Compiler";


constructor :: ($type : Type, $initializer : (x: *type) = null, $blacklist : [$NB] string = .[], $whitelist : [$NW]string = .[], caller_code := #caller_code) -> string #expand {
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
        procedure_call :: (node: *Code_Node) -> *Code_Procedure_Call {
            assert(node.kind == .PROCEDURE_CALL);
            return cast(*Code_Procedure_Call)node;
        }

        procedure_name :: (expression: *Code_Node) -> string {
            if expression.kind == {
                case .IDENT;
                ident := cast(*Code_Ident) expression;
                return ident.name;

                case .DIRECTIVE_BAKE;
                bake := cast(*Code_Directive_Bake) expression;
                return procedure_name(procedure_call(bake.procedure_call).procedure_expression);

                case;
                assert(false, "You may only use a named procedure (or #bake_arguments thereof) as an initializer.");
                return "";
            }
        }

        nodes := compiler_get_nodes(caller_code);
        c := procedure_call(nodes);

        expression : *Code_Node = null;
        for c.arguments_unsorted {
            if it.name && (cast(*Code_Ident)it.name).name == "initializer" {
                print_to_builder(*builder, "    %1(*result);\n", procedure_name(it.expression));
                expression = null;
                break;
            }
            else if it_index == 1 {
                expression = it.expression;
            }
        }
        if expression  print_to_builder(*builder, "    %1(*result);\n", procedure_name(expression));
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
