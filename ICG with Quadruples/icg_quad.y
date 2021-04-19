%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <ctype.h>
  int top=-1;
  void yyerror(char *);
  extern FILE *yyin;
  #define YYSTYPE char*
  typedef struct quadruples
  {
    char *op;
    char *arg1;
    char *arg2;
    char *res;
  }quad;
  int quadlen = 0;
  quad q[100];
%}

%start S
%token T_IDENTIFIER T_NUM T_lt T_gt T_lteq T_gteq T_neq T_noteq T_eqeq T_and T_or T_incr T_decr T_not T_eq T_WHILE T_INT T_DOUBLE T_CHAR T_FLOAT T_VOID T_HEADER T_MAIN T_INCLUDE T_BREAK T_CONTINUE T_IF T_ELSE T_COUT T_STRING T_FOR T_ENDL T_ques T_colon

%token T_pl T_min T_mul T_div
%left T_lt T_gt
%left T_pl T_min
%left T_mul T_div

%%
S
      : START {printf("Input accepted.\n");}
      ;

START
      : T_INCLUDE T_lt T_HEADER T_gt MAIN
      | T_INCLUDE "\"" T_HEADER "\"" MAIN
      ;

MAIN
      : T_VOID T_MAIN BODY
      | T_INT T_MAIN BODY
      ;

BODY
      : '{' C '}'
      ;

C
      : C statement ';'
      | C LOOPS
      | statement ';'
      | LOOPS
      | error
      ;

LOOPS
      : T_WHILE {while1();} '(' COND ')'{while2();} LOOPBODY{while3();}
      | T_IF '(' COND ')' {ifelse1();} LOOPBODY{ifelse2();} T_ELSE LOOPBODY{ifelse3();}
      ;

LOOPBODY
  	  : '{' LOOPC '}'
  	  | ';'
  	  | statement ';'
  	  ;

LOOPC
      : LOOPC statement ';'
      | LOOPC LOOPS
      | statement ';'
      | LOOPS
      ;

statement
      : ASSIGN_EXPR
      | EXP
      | PRINT
      ;

COND  : B {codegen_assigna();}
      | B T_and{codegen_assigna();} COND
      | B {codegen_assigna();}T_or COND
      | T_not B{codegen_assigna();}
      ;

B : V T_eq{push();}T_eq{push();} LIT
  | V T_gt{push();}F
  | V T_lt{push();}F
  | V T_not{push();} T_eq{push();} LIT
  |'(' B ')'
  | V {pushab();}
  ;

F :T_eq{push();}LIT
  |LIT{pusha();}
  ;

V : T_IDENTIFIER{push();}
  ;



ASSIGN_EXPR
      : LIT {push();} T_eq {push();} EXP {codegen_assign();}
      | TYPE LIT {push();} T_eq {push();} EXP {codegen_assign();}
      ;

EXP
	  : ADDSUB
	  | EXP T_lt {push();} ADDSUB {codegen();}
	  | EXP T_gt {push();} ADDSUB {codegen();}
	  ;

ADDSUB
      : TERM
      | EXP T_pl {push();} TERM {codegen();}
      | EXP T_min {push();} TERM {codegen();}
      ;

TERM
	  : FACTOR
      | TERM T_mul {push();} FACTOR {codegen();}
      | TERM T_div {push();} FACTOR {codegen();}
      ;

FACTOR
	  : LIT
	  | '(' EXP ')'
  	;

PRINT
      : T_COUT T_lt T_lt PRINT_STUFF
	  | T_COUT T_lt T_lt PRINT_STUFF PRINT
	  | T_lt T_lt PRINT_STUFF
	  | T_lt T_lt PRINT_STUFF PRINT	
      ;

PRINT_STUFF
	: T_STRING
	| T_IDENTIFIER
	| T_NUM
	| T_ENDL
	;

LIT
      : T_IDENTIFIER {push();}
      | T_NUM {push();}
      ;
TYPE
      : T_INT
      | T_CHAR
      | T_FLOAT
      ;


%%

#include "lex.yy.c"
#include<ctype.h>
char st[100][100];

char i_[2]="0";
int temp_i=0;
char tmp_i[3];
char temp[2]="t";
int label[20];
int lnum=0;
int ltop=0;
int abcd=0;
int l_while=0;
int l_for=0;
int flag_set = 1;

int main(int argc,char *argv[])
{

  yyin = fopen("input.c","r");
  if(!yyparse())  //yyparse-> 0 if success
  {
    printf("Parsing Complete\n");
    printf("---------------------Quadruples-------------------------\n\n");
    printf("Operator \t Arg1 \t\t Arg2 \t\t Result \n");
    int i;
    for(i=0;i<quadlen;i++)
    {
        printf("%-8s \t %-8s \t %-8s \t %-6s \n",q[i].op,q[i].arg1,q[i].arg2,q[i].res);
    }
  }
  else
  {
    printf("Parsing failed\n");
  }

  fclose(yyin);
  return 0;
}

void yyerror(char *s)
{
  printf("Error :%s at %d \n",yytext,yylineno);
}

push()
{
strcpy(st[++top],yytext);
}
pusha()
{
strcpy(st[++top],"  ");
}
pushx()
{
strcpy(st[++top],"x ");
}
pushab()
{
strcpy(st[++top],"  ");
strcpy(st[++top],"  ");
strcpy(st[++top],"  ");
}

void add_to_structure(char* op, char* arg1, char* arg2, char* res)
{
	q[quadlen].op = (char*)malloc(sizeof(char)*100);
	q[quadlen].arg1 = (char*)malloc(sizeof(char)*100);
	q[quadlen].arg2 = (char*)malloc(sizeof(char)*100);
	q[quadlen].res = (char*)malloc(sizeof(char)*100);
	strcpy(q[quadlen].op, op);
	strcpy(q[quadlen].arg1,arg1);
	strcpy(q[quadlen].arg2,arg2);
	strcpy(q[quadlen].res,res);
}

codegen()
{

 	strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
    printf("%s = %s %s %s\n",temp,st[top-2],st[top-1],st[top]);
	add_to_structure(st[top-1],st[top-2],st[top],temp);
    quadlen++;
    top-=2;
    strcpy(st[top],temp);

	temp_i++;

}
codegen_assigna()
{
strcpy(temp,"T");
	sprintf(tmp_i, "%d", temp_i);
	strcat(temp,tmp_i);

	printf("%s = %s %s %s %s\n",temp,st[top-3],st[top-2],st[top-1],st[top]);
	//printf("%d\n",strlen(st[top]));
	if(strlen(st[top])==1)
	{
		//printf("hello");
		
		char t[20];
		//printf("hello");
		strcpy(t,st[top-2]);
		strcat(t,st[top-1]);
		add_to_structure(t,st[top-3],st[top],temp);
		quadlen++;
		
	}
	else
	{
		add_to_structure(st[top-2],st[top-3],st[top-1],temp);
		quadlen++;
	}
	top-=4;
	temp_i++;
	strcpy(st[++top],temp);

}

codegen_umin()
{
 strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
    printf("%s = -%s\n",temp,st[top]);
	add_to_structure("-",st[top-2],"NULL",temp);
    quadlen++;
    top--;
    strcpy(st[top],temp);
    temp_i++;
}
codegen_assign()
{
    printf("%s = %s\n",st[top-3],st[top]);
    q[quadlen].op = (char*)malloc(sizeof(char));
    q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(st[top]));
    q[quadlen].arg2 = "NULL";
    q[quadlen].res = (char*)malloc(sizeof(char)*strlen(st[top-3]));
    strcpy(q[quadlen].op,"=");
    strcpy(q[quadlen].arg1,st[top]);
    strcpy(q[quadlen].res,st[top-3]);
    quadlen++;
    top-=2;
}



ifelse1()
{
       lnum++;
    strcpy(temp,"T");
    sprintf(tmp_i, "%d", temp_i);
    strcat(temp,tmp_i);
    printf("%s = not %s\n",temp,st[top]);
	add_to_structure("not",st[top],"NULL",temp);
    quadlen++;
    printf("if %s goto L%d\n",temp,lnum);
    char x[10];
    sprintf(x,"%d",lnum);
    char l[]="L";
	add_to_structure("if",temp,"NULL",strcat(l,x));
    quadlen++;
    temp_i++;
    label[++ltop]=lnum;
}


ifelse2()
{ int x;
    lnum++;
    x=label[ltop--];
    printf("goto L%d\n",lnum);
    char jug[10];
    sprintf(jug,"%d",lnum);
    char l[]="L";
	add_to_structure("goto","NULL","NULL",strcat(l,jug));
    quadlen++;
    printf("L%d: \n",x);
    char jug1[10];
    sprintf(jug1,"%d",x);
    char l1[]="L";
	add_to_structure("Label","NULL","NULL",strcat(l1,jug1));
    quadlen++;
    label[++ltop]=lnum;
}

ifelse3()
{
	int y;
	y=label[ltop--];
	printf("L%d: \n",y);
    char x[10];
    sprintf(x,"%d",y);
    char l[]="L";
	add_to_structure("Label","NULL","NULL",strcat(l,x));
    quadlen++;
	lnum++;
}


while1()
{
 l_while = lnum;
    printf("L%d: \n",lnum++); 
    char x[10];
    sprintf(x,"%d",lnum-1);
    char l[]="L";
    add_to_structure("Label","NULL","NULL",strcat(l,x));
    quadlen++;
}

while2()
{
 strcpy(temp,"T");
 sprintf(tmp_i, "%d", temp_i);
 strcat(temp,tmp_i);
 printf("%s = not %s\n",temp,st[top]);
	add_to_structure("not",st[top],"NULL",temp);
    quadlen++;
    printf("if %s goto L%d\n",temp,lnum);
    char x[10];
    sprintf(x,"%d",lnum);char l[]="L";
	add_to_structure("if",temp,"NULL",strcat(l,x));
    quadlen++;
 	temp_i++;
 }

while3()
{
printf("goto L%d \n",l_while);
    char x[10];
    sprintf(x,"%d",l_while);
    char l[]="L";
	add_to_structure("goto","NULL","NULL",strcat(l,x));
    quadlen++;
    printf("L%d: \n",lnum++);
    char x1[10];
    sprintf(x1,"%d",lnum-1);
    char l1[]="L";
	add_to_structure("Label","NULL","NULL",strcat(l1,x1));
    quadlen++;
}
