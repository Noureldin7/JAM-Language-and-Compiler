#include <string>
#ifndef enums_H__
#define enums_H__
enum ops
{
    Eq,
    Neq,
    Lt,
    Gte,
    Lte,
    Gt,
    Jmp_True,
    Jmp_False,
    Jmp,
    Add,
    Sub,
    Mul,
    Div,
    And,
    Or,
    Not,
    Bit_And,
    Bit_Or,
};
enum types
{
    Double,
    Int,
    Bool,
    String,
    Function
};
const std::string typeNames[] = {"double", "int", "bool", "string", "function"};
const std::string opNames[] = {"EQ", "NEQ", "LT", "GTE", "LTE", "GT","JMP_TRUE","JMP_FALSE","JMP","ADD", "SUB", "MUL", "DIV", "AND", "OR", "NOT", "ANDB", "ORB"};
//(int) op + 1- 2 * (op % 2) 
// if(x > 5 || y ==0) -->
// gt x , 5, t1
// eq y, 0, t2 
// or t1 , t2 , t3 --> jmp false t3, label2
// $$ = new symbol(*$1); delete $1;
#endif