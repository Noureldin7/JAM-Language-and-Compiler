#include <fstream>
#include "utils.hpp"
#include "symbol_table.hpp"
#include "enums.hpp"


class quadruple_generator {
    fstream writer;
    void quadruple_generator::write_quadruple(ops operation, symbol *op1, symbol *op2, symbol *dst);
    void quadruple_generator::write_quadruple(ops operation, string op1_str, string op2_str, string dst_str);
public:
    quadruple_generator(string filename);
    // these print conversion quadruples to file
    // assuming the input op is convertable to this type
    // otherwise it throws a yyerror
    symbol* Int(symbol* op);
    symbol* Double(symbol* op);
    symbol* String(symbol* op);
    symbol* Bool(symbol* op);
    void Numeric(symbol* op1,symbol* op2);

    symbol* assign_op(symbol* dst, symbol* src);
    symbol* not_op(symbol* op);
    symbol* arth_op(ops operation , symbol* op1 , symbol* op2);
    symbol* plus_op(symbol* op1 , symbol* op2);
    symbol* concat_op(symbol* op1 , symbol* op2);
    symbol* relational_op(ops operation , symbol* op1 , symbol* op2);
    void jmp_on_condition(symbol* op , bool on_true , string label);
    ~quadruple_generator();
};

