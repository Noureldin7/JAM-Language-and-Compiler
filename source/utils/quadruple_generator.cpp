#include "quadruple_generator.hpp"

quadruple_generator::quadruple_generator(string filename)
{
}

symbol* quadruple_generator::not_op(symbol* op){
    // print eni b3ks el operation eli 3ndy
    // write it in quadruples file
    // create new boolean symbol temp 
    // return pointer to that new symbol 
}
// add , minus , mul , divide
symbol* quadruple_generator::arth_op(ops operation , symbol* op1 , symbol* op2){
    // print eni b3ks el operation eli 3ndy
    // write it in quadruples file
    // create new symbol temp 
    // return pointer to that new symbol 
}

symbol* quadruple_generator::plus_op(symbol* op1 , symbol* op2){
    // check that op1 and op2 are not strings 
    // if they are not strings call arth_op
    // else call concat_op
}

symbol* quadruple_generator::concat_op(symbol* op1 , symbol* op2){
    
}

symbol* quadruple_generator::Int(symbol* op){
    // check that op is not string
    // if it is not string call arth_op
    // else throw error
}

symbol* quadruple_generator::Double(symbol* op){
    // check that op is not string
    // if it is not string call arth_op
    // else throw error
}

symbol* quadruple_generator::String(symbol* op){
    // check that op is string
    // if it is string call concat_op
    // else throw error
}

symbol* quadruple_generator::Bool(symbol* op){
    // check that op is not string
    // if it is not string call not_op
    // else throw error
}


quadruple_generator::~quadruple_generator()
{
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
// 10 - arth_op(+,-,*,/) --> NOUR
// 11- plus_op(+) --> ATAREK
// 12- concat_op(+) --> ATAREK

// for each op , validate the type match --> return error if not matched 
