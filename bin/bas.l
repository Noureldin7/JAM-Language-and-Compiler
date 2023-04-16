%{
    #include <stdlib.h>
    void yyerror(char*);
    #include "bas.tab.h"
%}
digit           [0-9]
whitespace      [ \t\n]  
%%
{digit}+        {
                    yylval.intVal = atoi(yytext);
                    return INTEGER;
                }
[-+;]            return *yytext;
{whitespace}    ;
.               yyerror("Invalid Character");
%%
int yywrap(void)
{
    return 1;
}