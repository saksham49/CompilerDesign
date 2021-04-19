#!/bin/bash

lex symTbl.l
yacc symTbl.y
gcc y.tab.c -ll -w
./a.out input.c
