#include <fstream>
#include "utils.hpp"
#include "symbol_table.hpp"
#include "enums.hpp"


class quadruple_generator {
    fstream writer;

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

    ~quadruple_generator();
};