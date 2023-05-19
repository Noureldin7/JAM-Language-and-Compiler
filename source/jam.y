%{ 
    #include "../source/utils/symbol_table.hpp"
    #include "../source/utils/utils.hpp"
    #include "../source/utils/quadruple_generator.hpp"
    #include <stdlib.h>
    #include <stdio.h>
    #include <cstring>
    #include <algorithm>
    using namespace std;
    int yylex(void);
    // void yyerror(char const *);
    symbol_table table;
    extern FILE* yyin;
    int functional_depth = 0;
    unordered_map<string,vector<string>> enum_table;
    string current_enum;
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
%token <stringVal> INT_VAL <stringVal> ID <stringVal> DOUBLE_VAL <stringVal> STRING_VAL
%type <symbVal> for_loop_stmt_2, expr, expr_OR, expr_AND, expr_bitwise_OR, expr_bitwise_XOR, expr_bitwise_AND, expr_EQ, expr_REL, expr_ADD, expr_MUL, expr_NOT, expr_lit, literal
%type <typeVal> type
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
    REPEAT {$<stringVal>$ = strdup(write_label(false).data()); table.create_scope();} '{' root '}' {table.pop_scope();} UNTIL '(' expr ')'  {quad_gen.jmp_on_condition($9, false, string($<stringVal>2));}
;
for_loop:
    FOR  {table.create_scope();} '(' for_loop_stmt_1 ';' {$<stringVal>$ = strdup(write_label(false).data());} for_loop_stmt_2 ';' {string l = generate_laj_label(); quad_gen.jmp_on_condition($<stringVal>7, false, l); $<stringVal>$ = strdup(l.data());} for_loop_stmt_3 ')' '{' root '}' {quad_gen.jmp_unconditional(string($<stringVal>6)); table.pop_scope(); quad_gen.write_label(true, string($<stringVal>9));}
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
    WHILE {$<stringVal>$ = strdup(write_label(false).data());} '(' expr ')' {string l = generate_laj_label(); quad_gen.jmp_on_condition($<stringVal>4, false, l); $<stringVal>$ = strdup(l.data()); table.create_scope();} '{' root '}' {quad_gen.jmp_unconditional(string($<stringVal>2)); table.pop_scope(); quad_gen.write_label(true, string($<stringVal>6));}
;
initialization:
    CONST type ID '=' expr       {symbol s = table.insert_symbol(string($3),$2,true); quad_gen.assignment(s,$5);}
    |
    type ID '=' expr             {symbol s = table.insert_symbol(string($2),$1); quad_gen.assignment(s,$4);}
;
function_call:
    ID '(' function_call_parameters_optional ')'                                {;}
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
    function_declaration_prototype {functional_depth++;} '{' root '}'           {cout<<"End of function "<< $1 << endl; functional_depth--;}
;
function_declaration_prototype:
    VOID ID {cout << $2 <<" function returns void, takes: ";} '(' function_declaration_parameters_optional ')'
    |
    type ID {cout << $2 <<" function returns " << $1 << ", takes: ";} '(' function_declaration_parameters_optional ')'
;
function_declaration_parameters_optional:
    function_declaration_parameters                                             {;}
    |
                                                                                {cout << "function with no arguments" << endl;}
;
function_declaration_parameters:
    function_declaration_parameters ',' function_declaration_parameter          {;}
    |
    function_declaration_parameter                                              {;}
;
function_declaration_parameter:
    type ID                                                                     {cout << $1 << ' ' << $2 << ", ";}
;
return_statement:
    RETURN expr                                                                 {;}
    |
    RETURN                                                                      {;}
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
        IF '(' expr ')' {string l = generate_laj_label(); quad_gen.jmp_on_condition($3, false, l); $<stringVal>$ = strdup(l.data()); table.create_scope();} '{' root '}' {table.pop_scope(); quad_gen.write_label(true, string($<stringVal>5));}
        |
        IF '(' expr ')' {string l = generate_laj_label(); quad_gen.jmp_on_condition($3, false, l); $<stringVal>$ = strdup(l.data()); table.create_scope();} '{' root '}' {string l = generate_laj_label(); quad_gen.jmp_unconditional(l); $<stringVal>$ = strdup(l.data()); table.pop_scope(); quad_gen.write_label(true, string($<stringVal>5)); table.create_scope();} ELSE '{' root '}' {table.pop_scope(); quad_gen.write_label(true, string($<stringVal>11));}
;
switch_statement:
    SWITCH '(' expr ')' '{' switch_body '}'
;
switch_body:  case_stmts
    | case_stmts default_stmt
;
case_stmts: case_stmts case_stmt
        | case_stmt
;
case_stmt: CASE literal ':' root BREAK ';'
;
default_stmt: DEFAULT ':' root BREAK ';'
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
    ID '=' expr             {lookup(ID); assign();}
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
    expr_EQ EQ expr_REL           {$$ = relational_op(ops::Eq,$1,$3);}
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
    expr_ADD '+' expr_MUL           {$$ = quad_gen.plus($1,$3);}
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