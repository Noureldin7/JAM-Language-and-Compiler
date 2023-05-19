%{ 
    #include "../source/utils/symbol_table.hpp"
    #include "../source/utils/utils.hpp"
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
%type <stringVal> for_loop_stmt_1
%type <stringVal> for_loop_stmt_2
%type <stringVal> expr
%type <stringVal> expr_AND
%type <stringVal> expr_bitwise_OR
%type <stringVal> expr_bitwise_XOR
%type <stringVal> expr_bitwise_AND
%type <stringVal> expr_OR
%type <stringVal> expr_ADD
%type <stringVal> expr_MUL
%type <stringVal> expr_NOT
%type <stringVal> expr_lit
%type <symbVal> literal
%type <typeVal> type
%type <stringVal> function_declaration_prototype
%%
root:
    root statement           {;}
    |
    ;
statement:
    {cout<<"Repeat Loop Started"<<endl;} repeat_until_loop ';'                   {cout<<"Repeat Loop Ended"<<endl;}
    |
    {cout<<"For Loop Started"<<endl;} for_loop                            {cout<<"For Loop Ended"<<endl;}
    |
    {cout<<"While Loop Started"<<endl;} while_loop                   {cout<<"While Loop Ended"<<endl;}
    |
    function_declaration                {;}
    |
    function_call ';'                   {;}
    |
    return_statement ';'                   {if(functional_depth < 1) yyerror(strdup(string("Return statement outside function scope").data()));}
    |
    enum_declaration ';'                   {;}
    |
    initialization ';'                  {;}
    |
    {cout << "IF statement started" <<endl;} if_statement                        {cout << "IF statement ended" <<endl;}
    |
    {cout << "SWITCH statement started" <<endl;} switch_statement                {cout << "SWITCH statement ended" <<endl;}
    |
    assignment ';'                  {cout<<"Assignment"<<endl;}
    |
    ID ';'                            {cout<<$1 << ": " << table.lookup_symbol(string($1))->type <<endl;}
    |
    {cout << "scope start" << endl;} '{' root '}'                     {cout << "scope end"<<endl;}
repeat_until_loop:
    REPEAT '{' root '}' UNTIL '(' cond ')'  {;}
for_loop:
    FOR '(' for_loop_stmt_1 ';' for_loop_stmt_2 ';' for_loop_stmt_2 ')' '{' root '}'        {;}
for_loop_stmt_1:
    initialization      {;}
    |
    for_loop_stmt_2     {;}              
for_loop_stmt_2:
    expr                {;}
    |
    assignment          {;}
    | 
                        {;}                                                        
while_loop:
    WHILE '(' cond ')' '{' root '}'     {;}
cond:
    cond OR literal                  {;}
    |
    cond AND literal                  {;}
    |
    cond EQ literal                  {;}
    |
    cond NE literal                  {;}
    |
    cond GT literal                  {;}
    |
    cond LT literal                  {;}
    |
    cond GTE literal                  {;}
    |
    cond LTE literal                  {;}
    |
    literal                             {;}
;
initialization:
    CONST type ID '=' expr       {table.insert_symbol(string($3),$2,true);}
    |
    type ID '=' expr             {table.insert_symbol(string($2),$1);}
;
function_call:
    ID '(' function_call_parameters_optional ')'                                {cout << "function " << $1 << " called" << endl;}
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
    VOID ID {cout << $2 <<" function returns void, takes: ";} '(' function_declaration_parameters_optional ')'          {cout << "\b\b  \n"; $$=strdup($2);}
    |
    type ID {cout << $2 <<" function returns " << $1 << ", takes: ";} '(' function_declaration_parameters_optional ')'  {cout << "\b\b  \n"; $$=strdup($2);}
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
    ENUM ID {cout << "Enum " << $2 << " contains values: "; current_enum=string($2); enum_table[current_enum] = vector<string>();} '{' enum_declaration_body '}'     {cout<<"\b\b  \n";}
;
enum_declaration_body:
    enum_declaration_body ',' ID                                                          {enum_table[current_enum].push_back(string($3)); cout << $3 << ", ";}
    |
    ID                                                                                    {enum_table[current_enum].push_back(string($1)); cout << $1 << ", ";}
;
if_statement:
        IF '(' expr ')' '{' root '}'
        | IF '(' expr ')' '{' root '}' ELSE '{' root '}'
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
    ID '=' expr             {;}
expr:
    expr_OR                         {;}
expr_OR:
    expr_OR OR expr_AND           {;}
    |
    expr_AND                         {;}
expr_AND:
    expr_AND AND expr_bitwise_OR           {;}
    |
    expr_bitwise_OR                         {;}
expr_bitwise_OR:
    expr_bitwise_OR '|' expr_bitwise_XOR           {;}
    |
    expr_bitwise_XOR                         {;}
expr_bitwise_XOR:
    expr_bitwise_XOR '^' expr_bitwise_AND           {;}
    |
    expr_bitwise_AND                         {;}
expr_bitwise_AND:
    expr_bitwise_AND '&' expr_EQ           {;}
    |
    expr_EQ                         {;}
expr_EQ:
    expr_EQ EQ expr_REL           {;}
    |
    expr_EQ NE expr_REL           {;}
    |
    expr_REL                         {;}
expr_REL:
    expr_REL GT expr_ADD           {;}
    |
    expr_REL LT expr_ADD           {;}
    |
    expr_REL GTE expr_ADD           {;}
    |
    expr_REL LTE expr_ADD           {;}
    |
    expr_ADD                         {;}

expr_ADD:
    expr_ADD '+' expr_MUL           {;}
    |
    expr_ADD '-' expr_MUL           {;}
    |
    expr_MUL                         {;}
expr_MUL:
    expr_MUL '*' expr_NOT             {;}
    |
    expr_MUL '/' expr_NOT             {;}
    |
    expr_NOT                      {;}
expr_NOT:
    '!' expr_lit                        {;}
    |
    expr_lit                            {;}
expr_lit:
    literal                       {;}
    |
    '(' expr_OR ')'               {;}
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
                                    $$ = new symbol(to_string(distance(v->second.begin(), e)),table.get_depth(),types::Int,true);
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