#include <string>
#ifndef enums_H__
#define enums_H__
enum ops{
    Plus,
    Minus,
    Mul,
    Div,
    And,
    Or,
    Bit_And,
    Bit_Or,
};
enum types{
    Int,
    Double,
    String,
    Bool
};
const std::string typeNames[] = {"int","double","string","bool"};
const std::string opNames[] = {"ADD","SUB","MUL","DIV","AND","OR","ANDB","ORB"};
#endif