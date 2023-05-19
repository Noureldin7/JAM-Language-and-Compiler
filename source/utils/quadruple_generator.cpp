#include "quadruple_generator.hpp"

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
        // Coerce into stronger type (min value)
        if(op1->type < op2->type)
        {
            op2->type = op1->type;
        }
        else
        {
            op1->type = op2->type;
        }
        // Print Coerce quad
    }
}

symbol* quadruple_generator::assign_op(symbol* dst, symbol* src){
    if(src->type==dst->type)
    {
        // Direct Assignment
    }
    else if(dst->type==types::String)
    {
        yyerror("No");
    }
    else if(dst->type==types::Bool)
    {
        Bool(src);
    }
    else if(dst->type==types::Double)
    {
        Double(src);
    }
    else if(dst->type==types::Int)
    {
        Int(src);
    }
    // write it in quadruples file
    // create new boolean symbol temp 
    // return pointer to that new symbol 
}
symbol* quadruple_generator::not_op(symbol* op){
    // print eni b3ks el operation eli 3ndy
    // write it in quadruples file
    // create new boolean symbol temp 
    // return pointer to that new symbol 
}
// add , minus , mul , divide
symbol* quadruple_generator::arth_op(ops operation , symbol* op1 , symbol* op2){
    Numeric(op1,op2);
    // create new symbol temp 
    symbol* dst = new symbol(generate_temp(),op1->scope_depth,op1->type,false,true);
    string quad = opNames[operation]+" "+op1->get_name()+", "+op2->get_name()+", "+dst->get_name();
    // Print the quad
    if(op1->is_literal)
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

symbol* quadruple_generator::plus_op(symbol* op1 , symbol* op2){
    // check that op1 and op2 are not strings 
    // if they are not strings call arth_op
    if(op1->type!=types::String&&op2->type!=types::String)
    {
        return arth_op(ops::Add,op1,op2);
    }
    // else call concat_op
    else
    {
        return concat_op(op1,op2);
    }
}

symbol* quadruple_generator::concat_op(symbol* op1 , symbol* op2){
    String(op1);
    String(op2);
    symbol* dst = new symbol(generate_temp(),op1->scope_depth,op1->type,false,true);
    string quad = "CONC "+op1->get_name()+", "+op2->get_name()+", "+dst->get_name();
    // Print the quad
    if(op1->is_literal)
    {
        delete op1;
    }
    if(op2->is_literal)
    {
        delete op2;
    }
    return dst;
}

// list of needed quadruples generating functions
// 1- assign_op --> NOUR
// 2- jmp op(label) --> NASHAR
// 3- jmp cond_op (symbol,label,bool) --> ATAREK
// 4- push_op --> NASHAR
// 5- pop_op --> NASHAR
// 6- logical_op(&&,||)-->JOHN
// 7- relational_op -->(special cases for == and != (plus_op_like)) --> ATAREK
// 8- bitwise_op(&,|,^) --> JOHN
// 9- not_op{logical_op} --> JOHN
// 10- arth_op(+,-,*,/) --> NOUR
// 11- plus_op(+) --> ATAREK
// 12- concat_op(+) --> ATAREK

// for each op , validate the type match --> return error if not matched 