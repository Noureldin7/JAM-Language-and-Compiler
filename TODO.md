- # Questions to Ask TA
	1. Is using C++ acceptable?
	2. Will we execute code on values?

		i.e will we keep track of changing values of variables?
- # Up Next
	- [ ] Implement symbol table
		1. vector<unordered_map<string, symbol>>
		2. function print()
		3. function create_scope()
		4. function pop_scope()
		5. function insert_symbol()
		6. function lookup_symbol()
		7. function remove_symbol()
	- [ ] Implement symbol class
		1. string name
		2. enum type
		3. void* value
		4. bool is_const
		5. function print()
		6. destructor to delete void* value

	- Concerning labels:
		- We will split labels into two categories, each with its own labeling scheme:
			1. Labels that are the target of an upcoming jump (JAL)
			2. jumps that target an upcoming label (LAJ)
		- For JAL:
			- write a label name on a separate line
			- forward the label name to the code block that writes the jump
			- e.g:
				```
				repeat{ -> L1: //Next label would be L2
					// code
				} until(cond) -> jmp_if_not cond, L1
				```
		- For LAJ:
			- advance the label name
			- use the new label name in jmp
			- forward it to the code block that writes the label
			- e.g:
				-	```
					if (cond) { -> jmp_if_not cond, J1
						// code
					} -> jmp J2
					else { -> J1:
						// code
					} -> J2:
					```
				-	```
					switch(X){
					case 2:
						eq X, 2
						jmp_if_not cond, l1
						jmp end
						l1:
						jmp_if_not cond, l2
					case 3:
						jmp end
						l2:
						jmp_if_not cond, l3
					case 4:
					}
						jmp end
						l3:
						end:
					```


- # Done
	- ## Nour
		1. While & repeat until loops
		2. Assignment statements
	- ## John
		1. for loop
		2. const & vars
	- ## Tare2
		1. if else
		2. switch
	- ## Nashar
		1. Functions
		2. Enums

<!-- - [ ] Quadruple class
	>***"There should be some data structure to hold all quadruples (ordered) to write to file later" - Mostafa El-Nashar, 2023***

	>_"Why later you might ask? because." - Mostafa El-Nashar, 2023_
	1. enum operation
		- ADD
		- SUB
		- MUL
		- DIV
		- ASSIGN
		- COPY
		- JMP
		- JMP_IF Cond, Label
		- 
		- PARAM
		- CALL
		- RETURN
	2. string arg1
	3. string arg2
	4. string result
	5. string label // for labeled quadruples (if the quadruple is the target of a jump)
	6. function write_to_file() -->