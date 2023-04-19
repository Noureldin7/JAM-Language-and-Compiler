cd bin
bison -d bas.y     
flex bas.l
g++ lex.yy.c bas.tab.c -o bas.exe
bas.exe "../program.jam"