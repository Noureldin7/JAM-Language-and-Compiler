%{ 
    #include "../source/utils/quadruple_generator.hpp"
    #include <stdlib.h>
    #include <stdio.h>
    #include <cstring>
    #include <algorithm>
    #include <stack>
    using namespace std;
    int yylex(void);
    // void yyerror(char const *);
    symbol_table table;
    extern FILE* yyin;
    int functional_depth = 0;
    unordered_map<string,vector<string>> enum_table;
    vector<types> current_params;
    vector<symbol> current_params_symb;
    stack<types> return_stack;
    string current_enum;
    symbol current_switch = symbol();
    quadruple_generator quad_gen("quad.txt");
%}
%union {
    types typeVal;
    symbol* symbVal;
    char* stringVal;
}
// Reserved Words
%token FOR WHILE REPEAT UNTIL EQ NE GT LT GTE LTE AND OR CONST INT DOUBLE STRING BOOL VOID RETURN ENUM
%token IF ELSE SWITCH CASE DEFAULT BREAK
%token BOOL_TRUE BOOL_FALSE
%token <stringVal> INT_VAL <stringVal> ID <stringVal> DOUBLE_VAL <stringVal> STRING_VAL
%type <symbVal> for_loop_stmt_2, expr, expr_OR, expr_AND, expr_bitwise_OR, expr_bitwise_XOR, expr_bitwise_AND, expr_EQ, expr_REL, expr_ADD, expr_MUL, expr_NOT, expr_lit, literal
%type <typeVal> type
%type <stringVal> unmatched_if_statement
%type <typeVal> return_type
%type <symbVal> function_declaration_parameter
%%
root:
    root statement           {;}
    |
    ;
statement:
    repeat_until_loop ';'
    |
    for_loop
    |
    while_loop
    |
    function_declaration
    |
    function_call ';'
    |
    return_statement ';' {if(functional_depth < 1) yyerror(strdup(string("Return statement outside function scope").data()));}
    |
    enum_declaration ';'
    |
    initialization ';'
    |
    if_statement
    |
    switch_statement
    |
    assignment ';'
    |
    {table.create_scope();} '{' root '}' {table.pop_scope();}
;
repeat_until_loop:
    REPEAT {$<stringVal>$ = strdup(quad_gen.write_label(false).data()); table.create_scope();} '{' root '}' {table.pop_scope();} UNTIL '(' expr ')'  {quad_gen.jmp_on_condition($9, false, string($<stringVal>2));}
;
for_loop:
    FOR  {table.create_scope();} '(' for_loop_stmt_1 ';' {$<stringVal>$ = strdup(quad_gen.write_label(false).data());} for_loop_stmt_2 ';' {string l = generate_laj_label(); quad_gen.jmp_on_condition($7, false, l); $<stringVal>$ = strdup(l.data());} for_loop_stmt_3 ')' '{' root '}' {quad_gen.jmp_unconditional(string($<stringVal>6)); table.pop_scope(); quad_gen.write_label(true, string($<stringVal>9));}
;
for_loop_stmt_1:
    initialization      {;}
    |
    assignment          {;}
;
for_loop_stmt_2:
    expr                {$$ = $1;}
;
for_loop_stmt_3:
    assignment          {;}
;
while_loop:
    WHILE {$<stringVal>$ = strdup(quad_gen.write_label(false).data());} '(' expr ')' {string l = generate_laj_label(); quad_gen.jmp_on_condition($4, false, l); $<stringVal>$ = strdup(l.data()); table.create_scope();} '{' root '}' {quad_gen.jmp_unconditional(string($<stringVal>2)); table.pop_scope(); quad_gen.write_label(true, string($<stringVal>6));}
;
initialization:
    CONST type ID '=' expr       {symbol s = table.insert_symbol(string($3),$2,true); quad_gen.assign_op(&s,$5);}
    |
    type ID '=' expr             {symbol s = table.insert_symbol(string($2),$1, false); quad_gen.assign_op(&s,$4);}
;
function_call:
    ID {} '(' function_call_parameters_optional ')' {}
;
function_call_parameters_optional:
    function_call_parameters
    |
                                                                                {;}
;
function_call_parameters:
    function_call_parameters ',' function_call_parameter                        {;}
    |
    function_call_parameter
;
function_call_parameter:
    ID                                                                          {;}
;
function_declaration:
    return_type ID {return_stack.push($1); current_params = vector<types>(); current_params_symb = vector<symbol>(); current_params.push_back($1); string l = generate_laj_label(); quad_gen.jmp_unconditional(l); $<stringVal>$ = strdup(l.data());} {$<stringVal>$ = strdup(quad_gen.write_label(false).data());} '(' function_declaration_parameters_optional ')' {table.insert_symbol(string($2), types::Function, false, current_params, string($<stringVal>4)); table.create_scope(); for (symbol s : current_params_symb){symbol temp = table.insert_symbol(s.name, s.type, false); quad_gen.pop(&temp);} functional_depth++;} '{' root return_statement'}' {functional_depth--; return_stack.pop(); quad_gen.ret(); table.pop_scope(); quad_gen.write_label(true, string($<stringVal>3));}
;
return_type:
    VOID {$$ = types::Void;}
    |
    type {$$ = $1;}
;
function_declaration_parameters_optional:
    function_declaration_parameters                                             {;}
    |
    
;
function_declaration_parameters:
    function_declaration_parameters ',' function_declaration_parameter          {;}
    |
    function_declaration_parameter                                              {;}
;
function_declaration_parameter:
    type ID                                                                     {current_params.push_back($1); current_params_symb.push_back(symbol(string($2), 0, $1, false, false));}
;
return_statement:
    RETURN expr                                                                 {quad_gen.cast_to(return_stack.top(), $2); quad_gen.push($2); quad_gen.ret();}
    |
    RETURN                                                                      {if (return_stack.top() != types::Void) {yyerror(("Can't cast void to " + typeNames[return_stack.top()]).c_str());} quad_gen.ret();}
;
enum_declaration:
    ENUM ID {enum_table[current_enum] = vector<string>();} '{' enum_declaration_body '}'
;
enum_declaration_body:
    enum_declaration_body ',' ID                                                          {enum_table[current_enum].push_back(string($3));}
    |
    ID                                                                                    {enum_table[current_enum].push_back(string($1));}
;
if_statement:
        unmatched_if_statement {quad_gen.write_label(true, string($1));}
        |
        unmatched_if_statement {string l = generate_laj_label(); quad_gen.jmp_unconditional(l); $<stringVal>$ = strdup(l.data()); quad_gen.write_label(true, string($1)); table.create_scope();} ELSE '{' root '}' {table.pop_scope(); quad_gen.write_label(true, string($<stringVal>2));}
;
unmatched_if_statement:
        IF '(' expr ')' {string l = generate_laj_label(); quad_gen.jmp_on_condition($3, false, l); $<stringVal>$ = strdup(l.data()); table.create_scope();} '{' root '}' {table.pop_scope(); $$ = $<stringVal>5;}
;
switch_statement:
    SWITCH {if (current_switch.name != "") yyerror("Nested switch cases aren't allowed");} '(' ID ')' {current_switch = table.lookup_symbol(string($4)); current_switch.label = generate_laj_label();} '{' switch_body '}' {quad_gen.write_label(true, current_switch.label); current_switch = symbol();}
;
switch_body:  case_stmts
    | case_stmts default_stmt
;
case_stmts: case_stmts case_stmt
        | case_stmt
;
case_stmt: CASE literal {symbol* s = quad_gen.relational_op(ops::Neq, new symbol(&current_switch), $2); string l = generate_laj_label(); $<stringVal>$ = strdup(l.data()); quad_gen.jmp_on_condition(s, true, l); table.create_scope();} ':' root BREAK ';' {quad_gen.jmp_unconditional(current_switch.label); quad_gen.write_label(true, string($<stringVal>3)); table.pop_scope();}
;
default_stmt: DEFAULT {table.create_scope();} ':' root BREAK ';' {table.pop_scope();}
;
/* const_expr: INT_VAL | DOUBLE_VAL | SINGLE_CHAR | STRING_VAL
; */
// declaration:
//     CONST type ID             {symbol_table[string($3)] = ;} //TODO: modify symbol table to accept an uninitialized variable
//     |
//     type ID            {symbol_table[string($2)] = ;}
type:
    INT                         {$$ = types::Int;}
    |
    DOUBLE                      {$$ = types::Double;}
    |
    STRING                      {$$ = types::String;}
    |
    BOOL                        {$$ = types::Bool;}
assignment:
    ID '=' expr             {symbol s = table.update_symbol(string($1)); quad_gen.assign_op(&s,$3);}
expr:
    expr_OR                         {$$ = $1;}
expr_OR:
    expr_OR OR expr_AND           {$$ = quad_gen.binary_logical_op(ops::Or,$1,$3);}
    |
    expr_AND                         {$$ = $1;}
expr_AND:
    expr_AND AND expr_bitwise_OR           {$$ = quad_gen.binary_logical_op(ops::And,$1,$3);}
    |
    expr_bitwise_OR                         {$$ = $1;}
expr_bitwise_OR:
    expr_bitwise_OR '|' expr_bitwise_XOR           {$$ = quad_gen.binary_bitwise_op(ops::Bit_Or,$1,$3);}
    |
    expr_bitwise_XOR                         {$$ = $1;}
expr_bitwise_XOR:
    expr_bitwise_XOR '^' expr_bitwise_AND           {$$ = quad_gen.binary_bitwise_op(ops::Bit_Xor,$1,$3);}
    |
    expr_bitwise_AND                         {$$ = $1;}
expr_bitwise_AND:
    expr_bitwise_AND '&' expr_EQ           {$$ = quad_gen.binary_bitwise_op(ops::Bit_And,$1,$3);}
    |
    expr_EQ                         {$$ = $1;}
expr_EQ:
    expr_EQ EQ expr_REL           {$$ = quad_gen.relational_op(ops::Eq,$1,$3);}
    |
    expr_EQ NE expr_REL           {$$ = quad_gen.relational_op(ops::Neq, $1, $3);}
    |
    expr_REL                         {$$ = $1;}
expr_REL:
    expr_REL GT expr_ADD           {$$ = quad_gen.relational_op(ops::Gt,$1,$3);}
    |
    expr_REL LT expr_ADD           {$$ = quad_gen.relational_op(ops::Lt,$1,$3);}
    |
    expr_REL GTE expr_ADD           {$$ = quad_gen.relational_op(ops::Gte,$1,$3);}
    |
    expr_REL LTE expr_ADD           {$$ = quad_gen.relational_op(ops::Lte, $1, $3);}
    |
    expr_ADD                         {$$ = $1;}

expr_ADD:
    expr_ADD '+' expr_MUL           {$$ = quad_gen.plus_op($1,$3);}
    |
    expr_ADD '-' expr_MUL           {$$ = quad_gen.arth_op(ops::Sub, $1, $3);}
    |
    expr_MUL                         {$$ = $1;}
expr_MUL:
    expr_MUL '*' expr_NOT             {$$ = quad_gen.arth_op(ops::Mul, $1, $3);}
    |
    expr_MUL '/' expr_NOT             {$$ = quad_gen.arth_op(ops::Div, $1, $3);}
    |
    expr_NOT                      {$$ = $1;}
expr_NOT:
    '!' expr_lit                        {$$ = quad_gen.not_op($2);}
    |
    expr_lit                            {$$ = $1;}
expr_lit:
    literal                       {$$ = $1;}
    |
    '(' expr_OR ')'               {$$ = $2;}
literal:
    INT_VAL                      {$$ = new symbol($1,table.get_depth(),types::Int,true,true);}
    |
    DOUBLE_VAL                      {$$ = new symbol($1,table.get_depth(),types::Double,true,true);}
    |
    STRING_VAL                      {$$ = new symbol($1,table.get_depth(),types::String,true,true);}
    |
    BOOL_FALSE                      {$$ = new symbol($1,table.get_depth(),types::Bool,true,true);}
    |
    BOOL_TRUE                      {$$ = new symbol($1,table.get_depth(),types::Bool,true,true);}
    |
    ID '.' ID                       {
                                    auto v = enum_table.find(string($1));
                                    if(v == enum_table.end()) yyerror("Enum not found");
                                    auto e = find(v->second.begin(), v->second.end(), string($3));
                                    if(e == v->second.end()) yyerror("Enum value not found");
                                    $$ = new symbol(to_string(distance(v->second.begin(), e)),table.get_depth(),types::Int,true,true);
                                    }
    |
    ID                           {$$ = new symbol(table.lookup_symbol(string($1)));}
%%

int main(int argc, char * argv[])
{
    char* filename = argv[1];
    FILE* file = fopen(filename,"r");
    if(!file)
    {
        printf("File Error\n");
    }
    yyin = file;
    yyparse();
    return 0;
}