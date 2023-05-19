#include <vector>
#include <iostream>
#include <unordered_map>
#include "enums.hpp"
using namespace std;
class symbol
{
public:
    string name;
    types type;
    // string value;
    bool is_const;
    // Index of the symbol's scope in the scope vector
    int scope_depth;
    symbol();
    symbol(symbol*);
    symbol(string name, int scope_depth, types type, bool is_const);
    void print();
};
class symbol_table
{
    // Scope vector
    vector<unordered_map<string, symbol>> scopes;
    // Pointer to last scope in scope vector
    unordered_map<string, symbol>* local_scope;
public:
    // Initializes the scope vector
    symbol_table();
    // Push new scope into scope vector
    void create_scope();
    // Pop last scope in scope vector
    void pop_scope();
    // Returns local scope's depth
    int get_depth();
    // Insert given symbol into the local scope
    // Returns true on success and false on failure
    bool insert_symbol(string name, types type, bool is_const=false);
    // Retrieve the given symbol from the closest scope
    // Returns Symbol pointer if found and NULL if not found
    symbol* lookup_symbol(string name);
    // Assign symbol to symbol
    // Returns true on success and false on failure
    bool update_symbol(string name, symbol* rhs);
    // Assign literal to symbol
    // Returns true on success and false on failure
    bool update_symbol(string name, types rhs_type);
    // bool remove_symbol(string name);

    // Print the local scope
    void print();
    // function that generates label names 
    string generate_label();
    // function that generates temporary names
    string generate_temp();
};