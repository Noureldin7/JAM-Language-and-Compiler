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
    // symbol_table[]
    extern FILE* yyin;
%}
%union {
    int intVal;
    char* stringVal;
    double doubleVal;
}
%token <intVal> INTEGER <stringVal> ID
/* %type <intVal> statement */
/* %type <stringVal> assignment */
%type <intVal> expr
%type <intVal> term
%type <intVal> literal
%left '-' '+'
%%
root:
    root statement ';'           {;}
    |
    ;
statement:
    assignment                   {;}
    |
    ID                           {cout<<symbol_table[string($1)]<<endl;}
assignment:
    ID '=' expr             {symbol_table[string($1)] = $3;}
expr:
    expr '+' term           {$$ = $1 + $3;}
    |
    expr '-' term           {$$ = $1 - $3;}
    |
    term                         {$$ = $1;}
term:
    term '*' literal             {$$ = $1 * $3;}
    |
    term '/' literal             {$$ = $1 / $3;}
    |
    literal                      {$$ = $1;}
    |
    '(' expr ')'                 {$$ = $2;}
literal:
    INTEGER                      {$$ = $1;}
    |
    ID                           {$$ = symbol_table[string($1)];}


%%
void yyerror(char const*s)
{
    printf("%s\n",s);
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