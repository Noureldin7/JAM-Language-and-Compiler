%{
    #include <stdlib.h>
    void yyerror(char const*);
    #include "bas.tab.h"
%}
digit           [0-9]
symbols         [-+*/=&^!|(){};]
whitespace      [ \t\n]
alpha           [a-zA-z]  
string          \"({digit}|{alpha})*\"
%%
ඞ                                                           {return COMMENT;}
const                                                       {return CONST;}
int                                                         {return INT;}
double                                                      {return DOUBLE;}
string                                                      {return STRING;}
bool                                                        {return BOOL;}
==                                                          {return EQ;}
!=                                                          {return NE;}
>                                                           {return GT;}
\<                                                          {return LT;}
>=                                                          {return GTE;}
\<=                                                         {return LTE;}
&&                                                          {return AND;}
\|\|                                                        {return OR;}
while                                                       {return WHILE;}
repeat                                                      {return REPEAT;}
until                                                       {return UNTIL;}
{symbols}                                                   {return *yytext;}
{string}                                                    {
                                                                yylval.stringVal = strdup(yytext);
                                                                return STRING_VAL;
                                                            }
({alpha}|_)({alpha}|{digit}|_)*                             {
                                                                yylval.stringVal = strdup(yytext);
                                                                return ID;
                                                            }
{digit}+\.{digit}+                                          {
                                                                yylval.doubleVal = atof(yytext);
                                                                return DOUBLE_VAL;
                                                            }
{digit}+                                                    {
                                                                yylval.intVal = atoi(yytext);
                                                                return INT_VAL;
                                                            }
{whitespace}                                                ;
.                                                           yyerror("Invalid Character");
%%
int yywrap(void)
{
    return 1;
}