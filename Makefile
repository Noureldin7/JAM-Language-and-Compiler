all: clean build run
build:
	cd source ; bison -d jam.y -o "../bin/jam.tab.c" ; flex -o "../bin/lex.yy.c" jam.l ; cd ../bin ; g++ lex.yy.c jam.tab.c ../source/utils/symbol_table.cpp ../source/utils/utils.cpp ../source/utils/quadruple_generator.cpp -o jam.out
clean:
	rm -f bin/*.out bin/*.tab.* bin/*.yy.c
run:
	./bin/jam.out "table_test.jam"