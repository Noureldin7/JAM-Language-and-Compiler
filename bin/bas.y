%{ 
    #include <stdlib.h>
    #include <stdio.h>
    int yylex(void);
    void yyerror(char*);
    extern FILE* yyin;
%}
%union{
    int intVal;
    double doubleVal;
}
%token <intVal> INTEGER
%type <intVal> expr
%left '-' '+'
%%
root:
    root expr ';'                {printf("%d\n",$2);}
    |
    ;
expr:
    expr '+' INTEGER     {$$ = $1 + $3;}
    |
    expr '-' INTEGER     {$$ = $1 - $3;}
    |
    INTEGER                  {$$ = $1;}
%%
void yyerror(char*s)
{
    printf("%s\n",s);
    exit(-1);
}
int main(char * argc, char ** argv)
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