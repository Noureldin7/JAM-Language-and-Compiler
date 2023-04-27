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
%token <intVal> INTEGER <stringVal> ID
%type <intVal> expr_AND
%type <intVal> expr_XOR
%type <intVal> expr_OR
%type <intVal> expr_ADD
%type <intVal> expr_MUL
%type <intVal> literal
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
    ID '=' expr_OR             {symbol_table[string($1)] = $3;}
expr_OR:
    expr_OR '|' expr_XOR           {$$ = $1 | $3;}
    |
    expr_XOR                         {$$ = $1;}
expr_XOR:
    expr_XOR '^' expr_AND           {$$ = $1 ^ $3;}
    |
    expr_AND                         {$$ = $1;}
expr_AND:
    expr_AND '&' expr_ADD           {$$ = $1 & $3;}
    |
    expr_ADD                         {$$ = $1;}
expr_ADD:
    expr_ADD '+' expr_MUL           {$$ = $1 + $3;}
    |
    expr_ADD '-' expr_MUL           {$$ = $1 - $3;}
    |
    expr_MUL                         {$$ = $1;}
expr_MUL:
    expr_MUL '*' literal             {$$ = $1 * $3;}
    |
    expr_MUL '/' literal             {$$ = $1 / $3;}
    |
    literal                      {$$ = $1;}
    |
    '(' expr_OR ')'                 {$$ = $2;}
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