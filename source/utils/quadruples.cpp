#include "symbol_table.hpp"
#include "enums.hpp"
#include <fstream>
// create a global fstream writer

symbol *not_op(symbol *op)
{
    if (op->type != types::bool)
    {
        // error
        yyerror("not operator can only be applied to boolean values");
    }
    else
    {
        symbol *temp = new symbol(op);
        delete op;
        temp->type = !temp->type;
        return temp;
    }
}
// add , minus , mul , divide
symbol *arth_op(ops operation, symbol *op1, symbol *op2)
{
    // check on matching types first
    if (op1->type != op2->type)
    {
        // error
        yyerror(" addition type mismatch");
    }
    else if (op1->type == types::Bool && op1->type == types::Bool){
        //error 
        yyerror(" arithmetic operations can not be applied to boolean values")
    }
    switch (operation)
    {
    case Add:
        if (op1->type == types::String && op1->type == types::String)
        {
            // call concat_op
            return concat_op(op1, op2);
        }
        else
        {
            // call plus_op
            return plus_op(op1, op2);
        }
        break;
    case Sub:

    case Mul:
    case Div:
    }
}

symbol *plus_op(symbol *op1, symbol *op2)
{
    // check that op1 and op2 are not strings
    // if they are not strings call arth_op
    // else call concat_op
}

symbol *concat_op(symbol *op1, symbol *op2)
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
