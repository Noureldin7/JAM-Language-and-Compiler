#include <string>
#ifndef enums_H__
#define enums_H__
enum ops
{
    Assign,
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
    Bit_Xor,
    Concat,
    Push,
    Pop,
    Int_To_Bool,
    Double_To_Bool,
    String_To_Bool,
    Bool_To_Int,
    Double_To_Int,
    Bool_To_Double,
    Int_To_Double,
    Bool_To_String,
    Int_To_String,
    Double_To_String,
};
enum types
{
    Double,
    Int,
    Bool,
    String,
    Function,
    Void
};
const std::string typeNames[] = {
    "double",
    "int",
    "bool",
    "string",
    "function",
    "void"
};
const std::string opNames[] = {
    "ASS",
    "EQ",
    "NEQ",
    "LT",
    "GTE",
    "LTE",
    "GT",
    "JMP_TRUE",
    "JMP_FALSE",
    "JMP",
    "ADD",
    "SUB",
    "MUL",
    "DIV",
    "AND",
    "OR",
    "NOT", 
    "ANDB", 
    "ORB",
    "XORB",
    "CONCAT",
    "PUSH",
    "POP",
    "INT_TO_BOOL",
    "DOUBLE_TO_BOOL",
    "STRING_TO_BOOL",
    "BOOL_TO_INT",
    "DOUBLE_TO_INT",
    "BOOL_TO_DOUBLE",
    "INT_TO_DOUBLE",
    "BOOL_TO_STRING",
    "INT_TO_STRING",
    "DOUBLE_TO_STRING",
};
//(int) op + 1- 2 * (op % 2) 
// if(x > 5 || y ==0) -->
// gt x , 5, t1
// eq y, 0, t2 
// or t1 , t2 , t3 --> jmp false t3, label2
// $$ = new symbol(*$1); delete $1;
#endif