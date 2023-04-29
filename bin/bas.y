%{ 
    #include <stdlib.h>
    #include <stdio.h>
    #include <iostream>
    #include <unordered_map>
    #include <string>
    using namespace std;
    int yylex(void);
    void yyerror(char const *);
    unordered_map<string,int> symbol_table;
    extern FILE* yyin;
%}
%union {
    int intVal;
    char* stringVal;
    double doubleVal;
}
// Reserved Words
%token FOR WHILE REPEAT UNTIL EQ NE GT LT GTE LTE AND OR CONST INT DOUBLE STRING BOOL
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
%%
root:
    root statement           {;}
    |
    ;
statement:
    repeat_until_loop ';'                   {cout<<"Repeat Loop Detected"<<endl;}
    |
    for_loop                            {cout<<"For Loop Detected"<<endl;}
    |
    while_loop                   {cout<<"While Loop Detected"<<endl;}
    |
    initialization ';'                  {cout<<"Initialization"<<endl;}
    |
    if_statement                        {cout << "IF statement Detected" <<endl;}
    |
    switch_statement                    {cout << "SWITCH statement Detected" <<endl;}
    // declaration ';'                  {cout<<"Declaration"<<endl;}
    |
    assignment ';'                  {cout<<"Assignment"<<endl;}
    |
    ID                           {cout<<symbol_table[string($1)]<<endl;}
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
    INT                         {;}
    |
    DOUBLE                      {;}
    |
    STRING                      {;}
    |
    BOOL                        {;}
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
    ID                           {$$ = symbol_table[string($1)];}
%%
void yyerror(char const *s){
    extern int yylineno;
    printf("%s near line  %d ",s,yylineno);  
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