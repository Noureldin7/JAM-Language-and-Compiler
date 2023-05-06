%{ 
    #include <stdlib.h>
    #include <stdio.h>
    #include <iostream>
    #include <unordered_map>
    #include <string>
    #include <cstring>
    #include <vector>
    #include <algorithm>
    using namespace std;
    int yylex(void);
    void yyerror(char const *);
    unordered_map<string,int> symbol_table;
    extern FILE* yyin;
    int functional_depth = 0;
    unordered_map<string,vector<string>> enum_table;
    string current_enum;
%}
%union {
    int intVal;
    char* stringVal;
    double doubleVal;
}
// Reserved Words
%token FOR WHILE REPEAT UNTIL EQ NE GT LT GTE LTE AND OR CONST INT DOUBLE STRING BOOL VOID RETURN ENUM
%token IF ELSE SWITCH CASE DEFAULT BREAK
%token <intVal> INT_VAL <stringVal> ID <doubleVal> DOUBLE_VAL <stringVal> STRING_VAL <stringVal> SINGLE_CHAR
%type <stringVal> for_loop_stmt_1
%type <stringVal> for_loop_stmt_2
%type <intVal> expr
%type <intVal> expr_AND
%type <intVal> expr_bitwise_OR
%type <intVal> expr_bitwise_XOR
%type <intVal> expr_bitwise_AND
%type <intVal> expr_OR
%type <intVal> expr_ADD
%type <intVal> expr_MUL
%type <intVal> literal
%type <stringVal> type
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
    initialization ';'                  {cout<<"Initialization"<<endl;}
    |
    {cout << "IF statement started" <<endl;} if_statement                        {cout << "IF statement ended" <<endl;}
    |
    {cout << "SWITCH statement started" <<endl;} switch_statement                {cout << "SWITCH statement ended" <<endl;}
    |
    assignment ';'                  {cout<<"Assignment"<<endl;}
    |
    ID ';'                            {cout<<$1 << ": " << symbol_table[string($1)]<<endl;}
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
    CONST type ID '=' expr       {symbol_table[string($3)] = $5;}
    |
    type ID '=' expr             {symbol_table[string($2)] = $4;}
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
assignment:
    ID '=' expr             {symbol_table[string($1)] = $3;}
type:
    INT                         {$$ = strdup(string("int").data());}
    |
    DOUBLE                      {$$ = strdup(string("double").data());}
    |
    STRING                      {$$ = strdup(string("string").data());}
    |
    BOOL                        {$$ = strdup(string("bool").data());}
expr:
    expr_OR                         {;}
expr_OR:
    expr_OR OR expr_AND           {cout<<"OR ";}
    |
    expr_AND                         {;}
expr_AND:
    expr_AND AND expr_bitwise_OR           {cout<<"AND ";}
    |
    expr_bitwise_OR                         {;}
expr_bitwise_OR:
    expr_bitwise_OR '|' expr_bitwise_XOR           {cout<<"or ";}
    |
    expr_bitwise_XOR                         {;}
expr_bitwise_XOR:
    expr_bitwise_XOR '^' expr_bitwise_AND           {cout<<"xor ";}
    |
    expr_bitwise_AND                         {;}
expr_bitwise_AND:
    expr_bitwise_AND '&' expr_EQ           {cout<<"and ";}
    |
    expr_EQ                         {;}
expr_EQ:
    expr_EQ EQ expr_REL           {cout<<"EQ ";}
    |
    expr_EQ NE expr_REL           {cout<<"NE ";}
    |
    expr_REL                         {;}
expr_REL:
    expr_REL GT expr_ADD           {cout<<"GT ";}
    |
    expr_REL LT expr_ADD           {cout<<"LT ";}
    |
    expr_REL GTE expr_ADD           {cout<<"GTE ";}
    |
    expr_REL LTE expr_ADD           {cout<<"LTE ";}
    |
    expr_ADD                         {;}

expr_ADD:
    expr_ADD '+' expr_MUL           {cout<<"ADD ";}
    |
    expr_ADD '-' expr_MUL           {cout<<"SUB ";}
    |
    expr_MUL                         {;}
expr_MUL:
    expr_MUL '*' expr_NOT             {cout<<"MUL ";}
    |
    expr_MUL '/' expr_NOT             {cout<<"DIV ";}
    |
    expr_NOT                      {;}
expr_NOT:
    '!' ID                        {;}
    |
    literal                       {;}
    |
    '(' expr_OR ')'               {;}
literal:
    INT_VAL                      {;}
    |
    DOUBLE_VAL                      {;}
    |
    SINGLE_CHAR                      {;}
    |
    STRING_VAL                      {;}
    |
    ID '.' ID                       {
                                    auto v = enum_table.find(string($1));
                                    if(v == enum_table.end()) yyerror("Enum not found");
                                    auto e = find(v->second.begin(), v->second.end(), string($3));
                                    if(e == v->second.end()) yyerror("Enum value not found");
                                    $$ = distance(v->second.begin(), e);
                                    }
    |
    ID                           {$$ = symbol_table[string($1)];}
%%
void yyerror(char const *s){
    extern int yylineno;
    fprintf(stderr, "%s near line  %d\n",s,yylineno);
    exit(-1);
}
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