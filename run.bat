cd bin
bison -d bas.y     
flex bas.l
gcc lex.yy.c bas.tab.c -o bas.exe
bas.exe "../program.jam"