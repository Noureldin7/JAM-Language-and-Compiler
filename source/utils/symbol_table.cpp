
#include "symbol_table.hpp"
symbol::symbol()
{
    this->name = "";
    this->type = types::Int;
    this->scope_depth = -1;
    this->is_const = false;
}
symbol::symbol(symbol* symb)
{
    this->name = symb->name;
    this->type = symb->type;
    this->scope_depth = symb->scope_depth;
    this->is_const = symb->is_const;
}
symbol::symbol(string name, int scope_depth, types type, bool is_const)
{
    this->name = name;
    this->type = type;
    this->scope_depth = scope_depth;
    this->is_const = is_const;
}
void symbol::print()
{
    if(is_const)
    {
        cout<<"Constant "<<typeNames[type]+" "<<name<<endl;
    }
    else
    {
        cout<<typeNames[type]+" "<<name<<endl;
    }
}
symbol_table::symbol_table()
{
    scopes = vector(1,unordered_map<string,symbol>());
    local_scope = &scopes.back();
}
void symbol_table::create_scope()
{
    scopes.push_back(unordered_map<string,symbol>());
    local_scope = &scopes.back();
}
void symbol_table::pop_scope()
{
    if(scopes.size()==1)
    {
        return;
    }
    else
    {
        scopes.pop_back();
        local_scope = &scopes.back();
    }
}
int symbol_table::get_depth()
{
    return scopes.size()-1;
}
bool symbol_table::insert_symbol(string name, types type, bool is_const)
{
    if((*local_scope).find(name)!=(*local_scope).end())
    {
        return false;
    }
    (*local_scope)[name] = symbol(name,scopes.size()-1,type,is_const);
    return true;
}
symbol* symbol_table::lookup_symbol(string name)
{
    for (auto itr = scopes.rbegin(); itr < scopes.rend(); itr++)
    {
        if((*itr).find(name)!=(*itr).end())
        {
            return &(*itr)[name];
        }
    }
    return NULL;
}
bool symbol_table::update_symbol(string name, symbol* rhs)
{
    auto retrieved_symbol = lookup_symbol(name);
    if(retrieved_symbol->is_const)
    {
        return false;
    }
    if(retrieved_symbol)
    {
        if(retrieved_symbol->type==rhs->type)
        {
            return true;
        }
        return false;
    }
    return false;
}
bool symbol_table::update_symbol(string name, types rhs_type)
{
    auto retrieved_symbol = lookup_symbol(name);
    if(retrieved_symbol->is_const)
    {
        return false;
    }
    if(retrieved_symbol)
    {
        if(retrieved_symbol->type==rhs_type)
        {
            return true;
        }
        return false;
    }
    return false;
}
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
    cout<<"##########"<<"Table"<<"##########"<<endl;
    for (auto itr = (*local_scope).begin(); itr != (*local_scope).end(); itr++)
    {
        (*itr).second.print();
    }
    cout<<"#########################"<<endl;
    
}