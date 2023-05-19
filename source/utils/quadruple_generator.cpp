#include "quadruple_generator.hpp"

quadruple_generator::quadruple_generator(string filename)
{
    writer = fstream(filename);
}
void quadruple_generator::write_quadruple(ops operation, symbol *op1, symbol *op2, symbol *dst)
{
    string op1_str = op1 ? op1->get_name() : "";
    string op2_str = op2 ? op2->get_name() : "";
    string dst_str = dst ? dst->get_name() : "";
    write_quadruple(operation, op1_str, op2_str, dst_str);
}

void quadruple_generator::write_quadruple(ops operation, string op1_str, string op2_str, string dst_str) {
    string quad = opNames[operation] + " " + op1_str + ", " + op2_str + ", " + dst_str;
    // writer << quad << "\n";
    cout << quad << "\n";
}

void quadruple_generator::Numeric(symbol*op1,symbol*op2){
    // If not arithmetic => yyerror
    if(op1->type==types::String)
    {
        yyerror(("Invalid type "+typeNames[op1->type]).c_str());
    }
    if(op2->type==types::String)
    {
        yyerror(("Invalid type "+typeNames[op2->type]).c_str());
    }
    if(op1->type==op2->type)
    {
        // No coercion needed
        return;
    }
    else
    {
        symbol* strong_type;
        symbol* weak_type;
        if(op1->type < op2->type)
        {
            strong_type = op1;
            weak_type = op2;
            op2->type = op1->type;
        }
        else
        {
            strong_type = op2;
            weak_type = op1;
            op1->type = op2->type;
        }
        if(strong_type->type==types::Int)
        {
            write_quadruple(ops::Bool_To_Int,weak_type->get_name(),NULL,generate_temp());
        }
        else
        {
            if(weak_type->type==types::Bool)
            {
                write_quadruple(ops::Bool_To_Double,weak_type->get_name(),NULL,generate_temp());
            }
            else
            {
                write_quadruple(ops::Bool_To_Int,weak_type->get_name(),NULL,generate_temp());
            }
        }
    }
}

symbol *quadruple_generator::assign_op(symbol *dst, symbol *src)
{
    // String => ALL
    // Integer => ALL but String
    // Double => ALL but String
    // Bool => ALL
    if (src->type == dst->type)
    {
        // Direct Assignment
    }
    else if(dst->type==types::String)
    {
        String(src);
    }
    else if(dst->type==types::Bool)
    {
        Bool(src);
    }
    else if(dst->type==types::Double)
    {
        if (src->type == types::String)
        {
            yyerror("Cannot cast string to double");
        }
        Double(src);
    }
    else if(dst->type==types::Int)
    {
        if (src->type == types::String)
        {
            yyerror("Cannot cast string to int");
        }
        Int(src);
    }
    write_quadruple(ops::Assign, src, NULL, dst);
    // write it in quadruples file
    // create new boolean symbol temp 
    // return pointer to that new symbol 
}

symbol *quadruple_generator::not_op(symbol *op)
{
    Bool(op);
    symbol *temp = new symbol(generate_temp(), op->scope_depth, types::Bool, 0, 0);
    write_quadruple(ops::Not, op, NULL, temp);
    delete op;
}
// add , minus , mul , divide
symbol* quadruple_generator::arth_op(ops operation , symbol* op1 , symbol* op2){
    Numeric(op1,op2);
    // create new symbol temp 
    symbol* dst = new symbol(generate_temp(),op1->scope_depth,op1->type,false,true);
    string quad = opNames[operation]+" "+op1->get_name()+", "+op2->get_name()+", "+dst->get_name();
    // Print the quad
    write_quadruple(operation, op1, op2, dst);
    if (op1->is_literal)
    {
        delete op1;
    }
    if(op2->is_literal)
    {
        delete op2;
    }
    return dst;
    // return pointer to that new symbol 
}

symbol *quadruple_generator::plus_op(symbol *op1, symbol *op2)
{
    if (op1->type == types::String || op2->type == types::String)
    {
        return concat_op(op1, op2);
    }
    else
    {
        return arth_op(ops::Add, op1, op2);
    }
}

symbol *quadruple_generator::concat_op(symbol *op1, symbol *op2)
{
    String(op1);
    String(op2);
    symbol *result = new symbol(generate_temp(), max(op1->scope_depth, op2->scope_depth), types::String, 0, 0);
    writer << opNames[ops::Concat] << "\t" << op1->get_name() << " , " << op2->get_name() << " , " << result->get_name() << endl;
    delete op1;
    delete op2;
    return result;
}

void quadruple_generator::jmp_on_condition(symbol *op, bool on_true, string label)
{
    Bool(op);
    if (on_true)
    {
        writer << opNames[ops::Jmp_True] << "\t" << op->get_name() << " , " << label << endl;
    }
    else
    {
        writer << opNames[ops::Jmp_False] << "\t" << op->get_name() << " , " << label << endl;
    }
    delete op;
    return;
}

symbol *quadruple_generator::relational_op(ops operation, symbol *op1, symbol *op2)
{
    // gte x , 3 , t1 
    symbol *result = new symbol(generate_temp(), max(op1->scope_depth, op2->scope_depth), types::Bool, 0, 0);
    if(op1->type == types::Function || op2->type == types::Function){
        yyerror("Error: Function can't be compared");
    }
    if (op1->type != op2->type)
    {
        if(op1->type == types::String || op2->type == types::String){
            yyerror("Error: String can't be compared with other types");
        }
        if(op1->type == types::Double || op2->type == types::Double){
            Double(op1);
            Double(op2);
        }
        else{
            Int(op1);
            Int(op2);
        }
    }
    write_quadruple(operation,op1,op2,result);
    delete op1;
    delete op2;
    return result;
}

void quadruple_generator::Int(symbol *op)
{
}

void quadruple_generator::Double(symbol *op)
{
    string old_name = op->get_name();
    op->is_const = true;
    op->is_literal = true;
    op->name = generate_temp();
    switch (op->type)
    {
    case types::Int:
        write_quadruple(ops::Int_To_Double, old_name, "", op->get_name());
        break;
    case types::Bool:
        write_quadruple(ops::Bool_To_Double, old_name, "", op->get_name());
        break;
    case types::String:
        yyerror("Cannot cast string to double");
        break;
    case types::Function:
        yyerror("Cannot cast function to double");
        break;
    default:
        yyerror("Unknown Type");
        break;
    }
    op->type = types::Double;
}

void quadruple_generator::Int(symbol *op)
{
    if(op->type==types::String)
    {
        yyerror("Cannot cast type string to int");
    }
    op->type = types::Int;
    if(op->type==types::Bool)
    {
        write_quadruple(ops::Bool_To_Int,op->get_name(),"",generate_temp());
    }
    else if(op->type==types::Double)
    {
        write_quadruple(ops::Double_To_Int,op->get_name(),"",generate_temp());
    }
}

void quadruple_generator::String(symbol *op)
{
    // check that op is string
    // if it is string call concat_op
    // else throw error
}

void quadruple_generator::Bool(symbol *op) {
    if (op->type == types::Double || op->type == types::Int || op->type == types::String) {
        string new_name = generate_temp();
        ops coercion_type = infer_coercion_type(op->type, types::Bool);
        quadruple_generator::write_quadruple(coercion_type, op->get_name(), "", new_name);
        op->type = types::Bool;
        op->name = new_name;
        op->is_const = true;
        op->is_literal = false;
    } else if (op->type == types::Function) {
        yyerror("Error: Are you retarded?");
    }
}

quadruple_generator::~quadruple_generator()
{
    writer.close();
}

// list of needed quadruples generating functions
//? 1- assign_op --> NOUR
// 2- jmp op(label) --> NASHAR
// 4- push_op --> NASHAR
// 5- pop_op --> NASHAR
// 6- logical_op(&&,||)-->JOHN
//? 7- relational_op -->(special cases for == and != (plus_op_like)) --> ATAREK
// 8- bitwise_op(&,|,^) --> JOHN
// 9- not_op{logical_op} --> JOHN
//? 10- arth_op(+,-,*,/) --> NOUR
//? 11- plus_op(+) --> ATAREK
//? 12- concat_op(+) --> ATAREK

// for each op , validate the type match --> return error if not matched
