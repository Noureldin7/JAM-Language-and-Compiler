all: clean build run
build:
	cd bin ; bison -d bas.y ; flex bas.l ; g++ lex.yy.c bas.tab.c -o bas.out
clean:
	rm -f bin/*.out bin/*.tab.* bin/*.yy.c
run:
	./bin/bas.out "program.jam"