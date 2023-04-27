%{
    #include <stdlib.h>
    void yyerror(char const*);
    #include "bas.tab.h"
%}
digit           [0-9]
symbols         [-+*/=&^|();]
whitespace      [ \t\n]
alpha           [a-zA-z]  
%%
{symbols}                                                   {   
                                                                return *yytext;
                                                            }
({alpha}|_)({alpha}|{digit}|_)*                             {
                                                                yylval.stringVal = strdup(yytext);
                                                                return ID;
                                                            }
{digit}+                                                    {
                                                                yylval.intVal = atoi(yytext);
                                                                return INTEGER;
                                                            }
{whitespace}                                                ;
.                                                           yyerror("Invalid Character");
%%
int yywrap(void)
{
    return 1;
}