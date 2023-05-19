#include "quadruple_generator.hpp"

quadruple_generator::quadruple_generator(string filename)
{
}

symbol *quadruple_generator::not_op(symbol *op)
{
    // print eni b3ks el operation eli 3ndy
    // write it in quadruples file
    // create new boolean symbol temp
    // return pointer to that new symbol
}
// add , minus , mul , divide
symbol *quadruple_generator::arth_op(ops operation, symbol *op1, symbol *op2)
{
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
    symbol *temp = String(op1);
    symbol *temp2 = String(op2);
    symbol *result = new symbol(generate_temp(), max(temp->scope_depth, temp2->scope_depth), types::String, 0, 0);
    writer << "CONCAT \t" << temp->get_name() << " , " << temp2->get_name() << " , " << result->get_name() << endl;
    delete temp;
    delete temp2;
    return result;
}

void quadruple_generator::jmp_on_condition(symbol *op, bool on_true, string label)
{
    symbol *temp = Bool(op);
    if (on_true)
    {
        writer << "JMP_TRUE \t" << temp->get_name() << " , " << label << endl;
    }
    else
    {
        writer << "JMP_FALSE\t" << temp->get_name() << " , " << label << endl;
    }
    delete temp;
    return;
}

symbol *quadruple_generator::relational_op(ops operation, symbol *op1, symbol *op2)
{
    // gte x , 3 , t1 
    symbol *result = new symbol(generate_temp(), max(temp->scope_depth, temp2->scope_depth), types::Bool, 0, 0);
    if (op1->type == types::Int && op2->type == types::Int)
    {
        
    }
    writer << opNames[operation] << "\t" << op1->get_name() << " , " << op2->get_name() << " , " << result->get_name() << endl;
}

symbol *quadruple_generator::Int(symbol *op)
{
}

symbol *quadruple_generator::Double(symbol *op)
{
    // check that op is not string
    // if it is not string call arth_op
    // else throw error
}

symbol *quadruple_generator::String(symbol *op)
{
    // check that op is string
    // if it is string call concat_op
    // else throw error
}

symbol *quadruple_generator::Bool(symbol *op)
{
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
// 4- push_op --> NASHAR
// 5- pop_op --> NASHAR
// 6- logical_op(&&,||)-->JOHN
// 7- relational_op -->(special cases for == and != (plus_op_like)) --> ATAREK
// 8- bitwise_op(&,|,^) --> JOHN
// 9- not_op{logical_op} --> JOHN
// 10 - arth_op(+,-,*,/) --> NOUR

// for each op , validate the type match --> return error if not matched
