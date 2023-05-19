#include "utils.hpp"
void yyerror(char const *s){
    extern int yylineno;
    fprintf(stderr, "%s near line %d\n",s,yylineno);
    exit(-1);
}
void yywarn(char const *s){
    extern int yylineno;
    fprintf(stderr, "%s near line %d\n",s,yylineno);
    // exit(-1);
}
// implement generate_label and generate_temp
string generate_jal_label()
{
    string label =  "J"+to_string(jal_label_count);
    jal_label_count++;
    return label;
}
string generate_laj_label()
{
    return "L"+to_string(laj_label_count++);
}
string generate_temp()
{
    return "t"+to_string(temp_count++);
}