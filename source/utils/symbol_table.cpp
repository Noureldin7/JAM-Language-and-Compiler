#include "utils.hpp"
#include "symbol_table.hpp"
#include "enums.hpp"

symbol::symbol()
{
    this->name = "";
    this->type = types::Int;
    this->scope_depth = -1;
    this->is_const = false;
    this->is_literal = false;
}
symbol::symbol(symbol* symb)
{
    this->name = symb->name;
    this->type = symb->type;
    this->scope_depth = symb->scope_depth;
    this->is_const = symb->is_const;
    this->is_literal = symb->is_literal;
    this->is_used = symb->is_used;
}
symbol::symbol(string name, int scope_depth, types type, bool is_const, bool is_literal, bool is_used)
{
    this->name = name;
    this->type = type;
    this->scope_depth = scope_depth;
    this->is_const = is_const;
    this->is_literal = is_literal;
    this->is_used = is_used;
}
string symbol::get_name()
{
    if(is_literal)
    {
        return name;
    }
    else
    {
        return name+"_"+to_string(scope_depth);
    }
}
string symbol::print()
{
    if(is_const)
    {
        return "Constant "+typeNames[type]+" "+this->get_name()+"\n";
    }
    else
    {
        return typeNames[type]+" "+this->get_name()+"\n";
    }
}
symbol_table::symbol_table(string filename)
{
    writer = ofstream(filename);
    scopes = vector(1,map<string,symbol>());
    local_scope = &scopes.back();
}
void symbol_table::create_scope()
{
    scopes.push_back(map<string,symbol>());
    local_scope = &scopes.back();
}
void symbol_table::pop_scope()
{
    // if(scopes.size()==1)
    // {
    //     return;
    // }
    // else
    // {
    // }
    for(auto itr = local_scope->begin();itr!=local_scope->end();itr++)
    {
        if((*itr).second.is_used==false)
        {
            string var = (*itr).second.type==types::Function?"Function":"Variable";
            yywarn(("Unused "+var+" \""+(*itr).second.name+"\"").c_str());
        }
    }
    scopes.pop_back();
    local_scope = &scopes.back();
}
int symbol_table::get_depth()
{
    return scopes.size()-1;
}
symbol symbol_table::insert_symbol(string name, types type, bool is_const, vector<types> params, string label)
{
    if((*local_scope).find(name)!=(*local_scope).end())
    {
        string error = "Redeclaration of Variable \""+name+"\"";
        yyerror(error.c_str());
        return NULL;
    }
    (*local_scope)[name] = symbol(name,this->get_depth(),type,is_const,false,false);
    (*local_scope)[name].params = params;
    (*local_scope)[name].label = label;
    return (*local_scope)[name];
}
symbol symbol_table::lookup_symbol(string name)
{
    for (auto itr = scopes.rbegin(); itr < scopes.rend(); itr++)
    {
        if((*itr).find(name)!=(*itr).end())
        {
            (*itr)[name].is_used = true;
            return (*itr)[name];
        }
    }
    string error = "Undeclared Variable \""+name+"\"";
    yyerror(error.c_str());
    return NULL;
}
symbol symbol_table::update_symbol(string name)
{
    symbol retrieved_symbol = lookup_symbol(name);
    if(retrieved_symbol.is_const)
    {
        string error = "Variable \""+name+"\" is Constant";
        yyerror(error.c_str());
    }
    return retrieved_symbol;
}
// bool symbol_table::update_symbol(string name, types rhs_type)
// {
//     auto retrieved_symbol = lookup_symbol(name);
//     if(retrieved_symbol->is_const)
//     {
//         return false;
//     }
//     if(retrieved_symbol)
//     {
//         if(retrieved_symbol->type==rhs_type)
//         {
//             return true;
//         }
//         return false;
//     }
//     return false;
// }
// bool symbol_table::remove_symbol(string name)
// {
//     auto retrieved_symbol = lookup_symbol(name);
//     if(retrieved_symbol)
//     {
//         table[retrieved_symbol->scope_depth].erase(name);
//         return true;
//     }
//     return false;
// }
void symbol_table::print()
{
    writer<<"##########"<<"Table"<<"##########"<<endl;
    for (int i = 0; i <= this->get_depth(); i++)
    {
        auto scope = scopes[i];
        for (auto itr = scope.begin(); itr != scope.end(); itr++)
        {
            writer<<(*itr).second.print();
        }
    }
    
    writer<<"#########################"<<endl;
    
}
symbol_table::~symbol_table(){
    this->pop_scope();
}

