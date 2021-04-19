lex lex.l
yacc yacc.y
gcc y.tab.c -ll -w
./a.out input.cpp
