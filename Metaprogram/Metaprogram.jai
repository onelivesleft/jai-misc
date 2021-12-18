check_for_reallocatable_pointers : Option : .WARNING;
log_messages                     : bool   : false;

Option :: enum {
    OFF;
    WARNING;
    ERROR;
}


#import "Basic";
#import "Compiler";


check_message :: (message: *Message) {
    #if log_messages  log_message(message);
    #if check_reallocatable_pointers check_reallocatable_pointers(message);
}


log_message :: (message: *Message) {
    if message.kind == {
        case.TYPECHECKED;
        typechecked := cast(*Message_Typechecked) message;
        print("%\n", <<typechecked);
    }
}


becomes_invalid :: "Becomes_Invalid";


check_reallocatable_pointers :: (message: *Message) {
    if message.kind == {
        case .TYPECHECKED;
        typechecked := cast(*Message_Typechecked) message;
        for typechecked.all {
            check_expression(it.expression);
            for expression: it.subexpressions
                check_expression(expression);
        }
    }

    check_expression :: (expression: *Code_Node) {
        if !expression.enclosing_load
        || expression.enclosing_load.enclosing_import.module_type != .MAIN_PROGRAM
            return;

        if expression.kind == {
            case .BINARY_OPERATOR;
            op := cast(*Code_Binary_Operator) expression;
            if op.operator_type == #char "="
                check_right_hand_side(op.right);

            case .DECLARATION;
            decl := cast(*Code_Declaration) expression;
            if !has_note(decl, becomes_invalid)
            check_right_hand_side(decl.expression);
        }

        check_right_hand_side :: (expression: *Code_Node) #expand {
            if !expression return;

            if expression.kind == {
                case .UNARY_OPERATOR;
                    uop := cast(*Code_Unary_Operator) expression;
                    if uop.operator_type != #char "*"
                    || uop.subexpression.kind != .BINARY_OPERATOR
                        `return;

                    binop := cast(*Code_Binary_Operator) uop.subexpression;
                    if binop.operator_type != 347 // ARRAY_SUBSCRIPT?
                    || binop.left.kind != .IDENT
                        `return;

                    ident := cast(*Code_Ident) binop.left;
                    if !ident.resolved_declaration
                    || !ident.resolved_declaration.type_inst
                        `return;

                    pointer_to_resizable_array_message :: "You are taking a pointer to an item in a resizable array.  If the array reallocates (which can occur any time the array grows) the pointer will become invalid!  [You may silence this warning on a declaration by annotating it with @Becomes_Invalid]";
                    if ident.resolved_declaration.type_inst.inst_flags & .RESIZABLE
                        report(expression, pointer_to_resizable_array_message, check_for_reallocatable_pointers);

                case .PROCEDURE_CALL;
                    call := cast(*Code_Procedure_Call) expression;
                    if !call.resolved_procedure_expression
                    || call.resolved_procedure_expression.kind != .PROCEDURE_HEADER
                        `return;

                    header := cast(*Code_Procedure_Header) call.resolved_procedure_expression;

                    for argument: call.arguments_unsorted {
                        if argument.expression.kind != .IDENT
                            continue;

                        ident := cast(*Code_Ident) argument.expression;
                        if !ident.resolved_declaration
                        || !ident.resolved_declaration.type_inst
                            continue;

                        if !(ident.resolved_declaration.type_inst.inst_flags & .RESIZABLE)
                            continue;

                        for header.returns {
                            if !it.type_inst  continue;

                            if it.type_inst.pointer_to {
                                pointer_to_resizable_array_message :: "You are calling a procedure with a resizable array and getting back a pointer.  If it points into the array and the array reallocates (which can occur any time the array grows) the pointer will become invalid!  [You may silence this warning on a declaration by annotating it with @Becomes_Invalid]";
                                report(expression, pointer_to_resizable_array_message, check_for_reallocatable_pointers);
                                `return;
                            }
                        }
                    }
            }
        }
    }
}


report :: (node: *Code_Node, message: string, report_option: Option) {
    if report_option == {
        case .WARNING;  compiler_report(message, make_location(node), .WARNING);
        case .ERROR;    compiler_report(message, make_location(node), .ERROR);
    }
}


has_note :: (declaration: *Code_Declaration, note: string) -> bool {
    for declaration.notes  if it.text == note  return true;
    return false;
}


// @Note `log` is generated by the commented-out code below

log :: (node: *Code_Node) {
    format := *context.print_style.default_format_struct;
    format.use_long_form_if_more_than_this_many_members = 0;
    format.use_newlines_if_long_form = true;

    if node.kind == {
        case .BLOCK;  print("%\n", <<cast(*Code_Block)node);
        case .LITERAL;  print("%\n", <<cast(*Code_Literal)node);
        case .IDENT;  print("%\n", <<cast(*Code_Ident)node);
        case .UNARY_OPERATOR;  print("%\n", <<cast(*Code_Unary_Operator)node);
        case .BINARY_OPERATOR;  print("%\n", <<cast(*Code_Binary_Operator)node);
        case .PROCEDURE_BODY;  print("%\n", <<cast(*Code_Procedure_Body)node);
        case .PROCEDURE_CALL;  print("%\n", <<cast(*Code_Procedure_Call)node);
        case .CONTEXT;  print("%\n", <<cast(*Code_Context)node);
        case .WHILE;  print("%\n", <<cast(*Code_While)node);
        case .IF;  print("%\n", <<cast(*Code_If)node);
        case .LOOP_CONTROL;  print("%\n", <<cast(*Code_Loop_Control)node);
        case .CASE;  print("%\n", <<cast(*Code_Case)node);
        case .RETURN;  print("%\n", <<cast(*Code_Return)node);
        case .FOR;  print("%\n", <<cast(*Code_For)node);
        case .TYPE_DEFINITION;  print("%\n", <<cast(*Code_Type_Definition)node);
        case .TYPE_INSTANTIATION;  print("%\n", <<cast(*Code_Type_Instantiation)node);
        case .ENUM;  print("%\n", <<cast(*Code_Enum)node);
        case .PROCEDURE_HEADER;  print("%\n", <<cast(*Code_Procedure_Header)node);
        case .STRUCT;  print("%\n", <<cast(*Code_Struct)node);
        case .COMMA_SEPARATED_ARGUMENTS;  print("%\n", <<cast(*Code_Comma_Separated_Arguments)node);
        case .EXTRACT;  print("%\n", <<cast(*Code_Extract)node);
        case .SEQUENCE;  print("%\n", <<cast(*Code_Sequence)node);
        case .MAKE_VARARGS;  print("%\n", <<cast(*Code_Make_Varargs)node);
        case .DECLARATION;  print("%\n", <<cast(*Code_Declaration)node);
        case .CAST;  print("%\n", <<cast(*Code_Cast)node);
        case .DIRECTIVE_IMPORT;  print("%\n", <<cast(*Code_Directive_Import)node);
        case .DIRECTIVE_THROUGH;  print("%\n", <<cast(*Code_Directive_Through)node);
        case .DIRECTIVE_RUN;  print("%\n", <<cast(*Code_Directive_Run)node);
        case .DIRECTIVE_CODE;  print("%\n", <<cast(*Code_Directive_Code)node);
        case .DIRECTIVE_POKE_NAME;  print("%\n", <<cast(*Code_Directive_Poke_Name)node);
        case .ASM;  print("%\n", <<cast(*Code_Asm)node);
        case .DIRECTIVE_BAKE;  print("%\n", <<cast(*Code_Directive_Bake)node);
        case .DIRECTIVE_MODIFY;  print("%\n", <<cast(*Code_Directive_Modify)node);
        case .DIRECTIVE_FOREIGN_LIBRARY;  print("%\n", <<cast(*Code_Directive_Foreign_Library)node);
        case .SIZE_OR_TYPE_INFO;  print("%\n", <<cast(*Code_Size_Or_Type_Info)node);
        case .PUSH_CONTEXT;  print("%\n", <<cast(*Code_Push_Context)node);
        case .NOTE;  print("%\n", <<cast(*Code_Note)node);
        case .DIRECTIVE_SCOPE;  print("%\n", <<cast(*Code_Directive_Scope)node);
        case .DIRECTIVE_STATIC_IF;  print("%\n", <<cast(*Code_Directive_Static_If)node);
        case .DIRECTIVE_LOCATION;  print("%\n", <<cast(*Code_Directive_Location)node);
        case .COMPOUND_DECLARATION;  print("%\n", <<cast(*Code_Compound_Declaration)node);
        case .DEFER;  print("%\n", <<cast(*Code_Defer)node);
        case .USING;  print("%\n", <<cast(*Code_Using)node);
        case .PLACEHOLDER;  print("%\n", <<cast(*Code_Placeholder)node);
        case .DIRECTIVE_INSERT;  print("%\n", <<cast(*Code_Directive_Insert)node);
    }
}

/* This generates the above `log` procedure
#insert -> string {
    reflection :: #import "Reflection";
    builder : String_Builder;
    append(*builder, #string __jai
        log :: (node: *Code_Node) {
            format := *context.print_style.default_format_struct;
            format.use_long_form_if_more_than_this_many_members = 0;
            format.use_newlines_if_long_form = true;

            if node.kind == {
    __jai);

    for 0 .. 51 {
        enum_value := cast(Code_Node.Kind)it;
        if enum_value == {
            case .DIRECTIVE_ADD_CONTEXT; #through;
            case .DIRECTIVE_ALIGN; #through;
            case .DIRECTIVE_PLACE; #through;
            case .DIRECTIVE_LOAD; #through;
            case .DIRECTIVE_THIS; #through;
            case .REMOVE; #through;
            case .UNINITIALIZED;
            continue;
        }
        enum_name := reflection.get_enum_name(enum_value);
        type_name := sprint("Code_%", enum_name);
        for 5 .. type_name.count - 1
            if type_name[it - 1] != #char "_"
                type_name[it] = to_lower(type_name[it]);
        print_to_builder(*builder, #string __jai
                case .%1;  print("%%\n", <<cast(*%2)node);
        __jai, enum_name, type_name);
    }

    append(*builder, #string __jai
            }
        }
    __jai);

    return builder_to_string(*builder);
}
*/
