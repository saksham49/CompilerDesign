%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include<regex.h>
#define YYSTYPE char *

int yylex();
extern FILE *yyin;
extern int yylineno;
extern char *yytext;
void check_table_add(char *, int , char * , char *, char *);
char* check_length(char *, int);

typedef struct symbol_table {
	int line;
	char name[31];
	char type[31];
	char value[31];
	char datatype[31];
	int level;
}ST;

int struct_index = 0;
ST st[10000];
int nested = 0;
int error_count = 0;
%}

%token T_IDENTIFIER T_NUM T_lt T_gt T_lteq T_gteq T_neq T_eqeq T_plus T_min T_mul T_div T_and T_or T_incr T_decr T_not T_eq T_WHILE T_INT T_DOUBLE T_CHAR T_FLOAT T_VOID T_HEADER T_MAIN T_RETURN T_INCLUDE T_BREAK T_CONTINUE T_IF T_ELSE T_COUT T_STRING T_FOR T_ENDL T_perc T_sc T_com T_fs T_sb T_osb T_csb T_ob T_oob T_cob T_cb T_ocb T_ccb T_everything

%%

S
      : START
      ;

START
      : T_INCLUDE T_lt T_HEADER T_gt MAIN
      | T_INCLUDE "\"" T_HEADER "\"" MAIN
      ;

MAIN
      : T_VOID T_MAIN T_ob BODY
      | T_INT T_MAIN T_ob BODY
      ;

BODY
      : LEFT C RIGHT C
 	  | LEFT C RIGHT
 	  | %empty
 	  | error 
      ;

C
      : C statement T_sc
      | C LOOPS
      | statement T_sc
      | LOOPS
      | error 
      ;

LOOPS
      : T_WHILE T_oob COND T_cob LOOPBODY
      | T_FOR T_oob ASSIGN_EXPR T_sc COND T_sc statement T_cob LOOPBODY
      | T_IF T_oob COND T_cob LOOPBODY 
      | T_IF T_oob COND T_cob LOOPBODY T_ELSE LOOPBODY 
      | error 
      ;

LOOPBODY
  	  : LEFT C RIGHT
  	  | T_sc
  	  | statement T_sc
  	  | error
  	  ;

statement
      : ASSIGN_EXPR
      | ARITH_EXPR
      | TERNARY_EXPR
      | PRINT
      | T_RETURN
      ;

COND
      : LIT RELOP LIT
      | LIT
      | LIT RELOP LIT bin_boolop LIT RELOP LIT
      | un_boolop T_oob LIT RELOP LIT T_cob
      | un_boolop LIT RELOP LIT
      | LIT bin_boolop LIT
      | un_boolop T_oob LIT T_cob
      | un_boolop LIT
      ;

ASSIGN_EXPR
      : T_IDENTIFIER T_eq ARITH_EXPR {char identifier[31];strcpy(identifier,check_length($1, @1.last_line));check_table_add(identifier, @1.last_line, "I", "int", NULL);}
      | TYPE T_IDENTIFIER T_eq ARITH_EXPR {char identifier[31];strcpy(identifier,check_length($2, @1.last_line));check_table_add(identifier, @1.last_line, "I", $1, NULL);}
      ;

ARITH_EXPR
      : LIT
      | LIT bin_arop ARITH_EXPR
      | LIT bin_boolop ARITH_EXPR
      | LIT un_arop
      | un_arop ARITH_EXPR
      | un_boolop ARITH_EXPR
      ;

TERNARY_EXPR
      : T_oob COND T_cob '?' statement ':' statement
      ;

PRINT
      : T_COUT T_lt T_lt T_STRING 
      | T_COUT T_lt T_lt T_STRING T_lt T_lt T_ENDL 
      | T_COUT T_lt T_lt T_NUM 
      | T_COUT T_lt T_lt T_NUM T_lt T_lt T_ENDL
      | T_COUT T_lt T_lt T_IDENTIFIER {char identifier[31];strcpy(identifier,check_length($4, @1.last_line));}
      | T_COUT T_lt T_lt T_IDENTIFIER T_lt T_lt T_ENDL {char identifier[31];strcpy(identifier,check_length($4, @1.last_line));}
      ;
LIT
      : T_IDENTIFIER {char identifier[31];strcpy(identifier,check_length($1, @1.last_line));check_table_add(identifier, @1.last_line, "I", NULL, NULL);}
      | T_NUM
      ;
TYPE
      : T_INT 
      | T_DOUBLE 
      | T_CHAR 
      | T_FLOAT 
      ;
RELOP
      : T_lt 
      | T_gt 
      | T_lteq 
      | T_gteq 
      | T_neq 
      | T_eqeq
      ;

bin_arop
      : T_plus 
      | T_min 
      | T_mul 
      | T_div 
      | T_perc
      ;

bin_boolop
      : T_and 
      | T_or
      ;

un_arop
      : T_incr 
      | T_decr
      ;

un_boolop
      : T_not
      ;

LEFT
	: T_ocb {nested++;}
	;
RIGHT
	: T_ccb {nested--;}
	;

%%

#include "lex.yy.c"

int yyerror(char *s){
  printf("Error: %s at line %d \n",yytext,yylineno);
//printf("Error :%s at %d \n",yytext,yylineno);
}

int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");
	yyparse();
	if(error_count == 0) {
		printf("No errors\n");
	}
	printf("Parsing Complete\n");
	printf("Number of entries in the symbol table = %d\n\n", struct_index);
	printf("- - - - - - - - - - - - - - - - - Symbol Table - - - - - - - - - - - - - - - - -\n\n");
	printf("S.No\t  Token  \t Line Number \t Category \t DataType \t Level \n");

	for(int i=0; i<struct_index; i++) {
		char *ty;
		if(!strcmp(st[i].type, "I")) {
			ty = "identififer";
			printf("%-4d\t  %-7s\t %-10d\t %-9s\t %-7s\t %-5d\n", i+1, st[i].name, st[i].line, ty,st[i].datatype, st[i].level);
		}
	}
	fclose(yyin);
	return 0;
}

void check_table_add(char *tok, int line, char *cat, char *type, char *value) 
{
	int flag = 0;
	int i = 0;
	for(i=0; i<struct_index; i++) {
		if(!strcmp(st[i].name, tok)) {
	  		flag = 1;
		}
	}
 	if(flag==1) {
    	return;
    }
	i = struct_index;
	st[i].line = line;
	strcpy(st[i].name, tok);
	strcpy(st[i].type, cat);
	if(type == NULL) {
		strcpy(st[i].datatype, "NULL");
	}
	else {
		strcpy(st[i].datatype, type);
	}
	strcpy(st[i].value, "NULL");
	st[i].level = nested;
	struct_index += 1;
	return;
}

char* check_length(char* tok, int line) {
	int length = strlen(tok);
	char* identifier = (char *)malloc(sizeof(char)*31);
	if(length > 31) {
		error_count++;
		for(int letter=0; letter<31; letter++){
			identifier[letter] = tok[letter];
		}
		printf("ERROR Invalid Identifier Length at %d, truncated for use\n", line);
	}
	else {
		for(int letter=0; letter<length; letter++){
			identifier[letter] = tok[letter];
		}
	}
	//printf("%s\n", identifier);
	return identifier;
}
