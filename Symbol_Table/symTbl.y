%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #define YYSTYPE char *
  int yylex();
  void yyerror(char *);
  void lookup(char *,int,char,char*,char* );
  //void insert(char *,int,char,char*,char* );
  void update(char *,int,char *);
  void search_id(char *,int );
  extern FILE *yyin;
  extern int yylineno;
  extern char *yytext;
  typedef struct symbol_table
  {
    int line;
    char name[31];
    char type;
    char *value;
    char *datatype;
  }ST;
  int struct_index = 0;
  ST st[10000];
  char x[10];
%}
%start S
%token T_IDENTIFIER T_NUM T_lt T_gt T_lteq T_gteq T_neq T_eqeq T_plus T_min T_mul T_div T_and T_or T_incr T_decr T_not T_eq T_WHILE T_INT T_DOUBLE T_CHAR T_FLOAT 
T_VOID T_HEADER T_MAIN T_RETURN T_INCLUDE T_BREAK T_CONTINUE T_IF T_ELSE T_COUT T_STRING T_FOR T_ENDL T_perc T_sc T_com T_fs T_sb T_osb T_csb T_ob T_oob T_cob T_cb T_ocb T_ccb T_everything


%left T_lt T_gt
%left T_plus T_min
%left T_mul T_div

%%
S
      : START {printf("\n\n\nINPUT ACCEPTED.\n");}
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
      : T_ocb C T_ccb
      ;

C
      : C statement T_sc 
      | C LOOPS 
      | statement T_sc 
      | LOOPS 
      ;

LOOPS
      : T_WHILE T_oob COND T_cob LOOPBODY 
      | T_FOR T_oob ASSIGN_EXPR T_sc COND T_sc statement T_cob LOOPBODY 
      | T_IF T_oob COND T_cob LOOPBODY
      | T_IF T_oob COND T_cob LOOPBODY T_ELSE LOOPBODY
      ;


LOOPBODY
      : T_ocb LOOPC T_ccb 
      | T_sc
      | statement T_sc
      ;

LOOPC
      : LOOPC statement T_sc 
      | LOOPC LOOPS 
      | statement T_sc 
      | LOOPS 
      ;

statement
      : ASSIGN_EXPR 
      | EXP 
      | PRINT
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
      : T_IDENTIFIER T_eq EXP {search_id($1,@1.last_line);update($1,@1.last_line,$3); printf("This is assign without type\n");}
      | TYPE T_IDENTIFIER T_eq EXP {lookup($2,@1.last_line,'I',NULL,$1);update($2,@1.last_line,$4); printf("This is assign with type\n");}
      ;

EXP
      : ADDSUB {printf(" This is ADDSUB %s\n",$$);}
      | EXP T_lt ADDSUB {sprintf($$,"%d",atoi($1)<atoi($3)); printf("This is less than expression\n");}
      | EXP T_gt ADDSUB {sprintf($$,"%d",atoi($1)>atoi($3));printf("This is greater than expression\n");}
      ;
      
ADDSUB
      : TERM {printf("This is term\n");}
      | EXP T_plus TERM {sprintf($$,"%d",atoi($1)+atoi($3)); printf("This is addition %s\n", $$);}
      | EXP T_min TERM {sprintf($$,"%d",atoi($1)-atoi($3)); printf("This is minus \n");}
      ;

TERM
      : FACTOR {printf("This is Factor\n");}
      | TERM T_mul FACTOR {sprintf($$,"%d",atoi($1)*atoi($3));printf("This is multiplication\n");}
      | TERM T_div FACTOR {sprintf($$,"%d",atoi($1)/atoi($3)); printf("This is division\n");}
      ;
      
FACTOR
      : LIT  {printf("This is LIT\n");}
      | T_oob EXP T_cob {$$=$2; printf("This is EXp with brackets %s\n", $$);}
      ;


PRINT
      : T_COUT T_lt T_lt T_STRING
      | T_COUT T_lt T_lt T_STRING T_lt T_lt T_ENDL
      
LIT
      : T_IDENTIFIER {search_id($1,@1.last_line);sprintf($$,"%d",get_val($1));printf("This is T_IDENTIFIER\n");}
      | T_NUM {printf("This is number %s\n", $1);}
      ;
TYPE
      : T_INT 
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

bin_boolop
      : T_and 
      | T_or 
      ;

un_boolop
      : T_not
      ;


%%

#include "lex.yy.c"

int main(int argc,char *argv[])
{
  yyin = fopen(argv[1],"r");
  if(!yyparse())  //yyparse-> 0 if success
  {
  	printf("Parsing Complete\n");
    printf("Number of entries in the symbol table = %d\n\n",struct_index);
    printf("-----------------------------------Symbol Table-----------------------------------\n\n");
    printf("S.No\t  Token  \t Line Number \t Category \t DataType \t Value \n");
    for(int i = 0;i < struct_index;i++)
    {
      char *ty;
      if(st[i].type=='I')
      {
        ty="identifier";
        printf("%-4d\t  %-7s\t   %-10d \t %-9s\t  %-7s\t   %-5s\n",i+1,st[i].name,st[i].line,ty,st[i].datatype,st[i].value);
      }
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
void lookup(char *token,int line,char type,char *value,char *datatype)
{
  //printf("Token %s line number %d\n",token,line);
  int flag = 0;
  for(int i = 0;i < struct_index;i++)
  {
    if(!strcmp(st[i].name,token))
    {
      flag = 1;
      if(st[i].line != line)
      {
        st[i].line = line;
      }
    }
  }
  
  //Insert
  if(flag == 0)
  {
    strcpy(st[struct_index].name,token);
    st[struct_index].type=type;
    if(value==NULL)
        st[struct_index].value=NULL;
    else
        strcpy(st[struct_index].value,value);
        
    if(datatype==NULL)
        st[struct_index].datatype=NULL;
    else
        st[struct_index].datatype=datatype;
        
    st[struct_index].line = line;
    struct_index++;
  }
}

void insert(char *token,int line,char type, char* value, char *datatype)
{
  printf("start");
  strcpy(st[struct_index].name,token);
  st[struct_index].type=type;
  strcpy(st[struct_index].value,value);
  strcpy(st[struct_index].datatype,datatype);
  st[struct_index].line = line;
  struct_index++;
  printf("end");
}

void search_id(char *token,int lineno)
{
  int flag = 0;
  for(int i = 0;i < struct_index;i++)
  {
    if(!strcmp(st[i].name,token))
    {
      flag = 1;
      return;
    }
  }
  if(flag == 0)
  {
    printf("Error at line %d : %s is not defined\n",lineno,token);
    exit(0);
  }
}

void update(char *token,int lineno,char *value)
{
  int flag = 0;
  
  for(int i = 0;i < struct_index;i++)
  {
    if(!strcmp(st[i].name,token))
    {
      flag = 1;
      st[i].value = (char*)malloc(sizeof(char)*strlen(value));
      //sprintf(st[i].value,"%s",value);
      strcpy(st[i].value,value);
      st[i].line = lineno;
      return;
    }
  }
  if(flag == 0)
  {
    printf("Error at line %d : %s is not defined\n",lineno,token);
    exit(0);
  }
}

int get_val(char *token)
{
  int flag = 0;
	//printf("please tell me you come here\n");
  for(int i = 0;i < struct_index;i++)
  {
    if(!strcmp(st[i].name,token))
    {
      flag = 1;
		//printf("here %s?\n", token);
		//printf("%d\n",atoi(st[i].value));
      return atoi(st[i].value);
    }
  }
  if(flag == 0)
  {
    printf("Error at line : %s is not defined\n",token);
    exit(0);
  }
}
