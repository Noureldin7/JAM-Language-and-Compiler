#include <fstream>
#include "utils.hpp"
#include "symbol_table.hpp"
#include "enums.hpp"


class quadruple_generator {
    ofstream writer;
    void write_quadruple(ops operation, symbol *op1, symbol *op2, symbol *dst);
    void write_quadruple(ops operation, string op1_str, string op2_str, string dst_str, string type);
public:
    quadruple_generator(string filename);
    // these print conversion quadruples to file
    // assuming the input op is convertible to this type
    // otherwise it throws a yyerror
    void cast_to(types target, symbol* op);
    void Int(symbol* op);
    void Double(symbol* op);
    void String(symbol* op);
    void Bool(symbol* op);
    void Numeric(symbol* op1,symbol* op2);
    void BitAccessible(symbol* op1, symbol* op2);

    void assign_op(symbol* dst, symbol* src);
    symbol* not_op(symbol* op);
    symbol* binary_logical_op(ops operation , symbol* op1 , symbol* op2);
    symbol* binary_bitwise_op(ops operation , symbol* op1 , symbol* op2);
    symbol* arth_op(ops operation , symbol* op1 , symbol* op2);
    symbol* plus_op(symbol* op1 , symbol* op2);
    symbol* concat_op(symbol* op1 , symbol* op2);
    symbol* relational_op(ops operation , symbol* op1 , symbol* op2);
    void jmp_on_condition(symbol* op , bool on_true , string label);
    void jmp_unconditional(string label);
    void push(symbol *op);
    symbol* pop(symbol *op);
    void call(symbol *op);
    void ret();
    string write_label(bool is_laj, string label = "");
    ~quadruple_generator();
};

