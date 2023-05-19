%{
    #include "../source/utils/symbol_table.hpp"
    #include <stdlib.h>
    // void yyerror(char const*);
    #include "../source/utils/utils.hpp"
    #include "jam.tab.h"
%}
%option yylineno
digit           [0-9]
symbols         [-+*/=&^!|(){};:,\.]
whitespace      [ \t\n\r]
alpha           [a-zA-z]  
string          \"({digit}|\.|{alpha})*\"
%%
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
for                                                         {return FOR;}
while                                                       {return WHILE;}
repeat                                                      {return REPEAT;}
until                                                       {return UNTIL;}
if                                                          {return IF;}
else                                                        {return ELSE;}
switch                                                      {return SWITCH;}
case                                                        {return CASE;}
break                                                       {return BREAK;}
default                                                     {return DEFAULT;}
void                                                        {return VOID;}
return                                                      {return RETURN;}
enum                                                        {return ENUM;}
(ඞ[^\n\r]*)                                                 ;
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
                                                                yylval.stringVal = strdup(yytext);
                                                                return DOUBLE_VAL;
                                                            }
{digit}+                                                    {
                                                                yylval.stringVal = strdup(yytext);
                                                                return INT_VAL;
                                                            }
{whitespace}                                                ;
.                                                           yyerror("Invalid Character");
%%
int yywrap(void)
{
    return 1;
}