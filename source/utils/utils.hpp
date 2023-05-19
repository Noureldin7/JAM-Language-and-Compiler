#include <string>
using namespace std;
// static private for label and temp names
#ifndef utils_H__
#define utils_H__
void yyerror(char const *s);
static int jal_label_count;
static int laj_label_count;
static int temp_count;
// implement generate_label and generate_temp
string generate_jal_label();
string generate_laj_label();
string generate_temp();
#endif