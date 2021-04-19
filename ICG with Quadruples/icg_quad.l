%{
    #include<string.h>
    #include<stdio.h>
    int line = 0;
    #define YYSTYPE char *
%}

alpha [A-Za-z_]
digit [0-9]
%option yylineno
%%
"//".*\n ;
"/\*"(.|\n)*"\*/" ;
[ \t\n] {yylval = strdup(yytext);}
":" {yylval = strdup(yytext);return T_colon;}
"?" {yylval = strdup(yytext);return T_ques;}
"while" {yylval = strdup(yytext);return T_WHILE;}
"for" {yylval = strdup(yytext);return T_FOR;}
"if" {yylval = strdup(yytext);return T_IF;}
"else" {yylval = strdup(yytext);return T_ELSE;}
"cout" {yylval = strdup(yytext);return T_COUT;}
"endl" {yylval = strdup(yytext);return T_ENDL;}
"break" {yylval = strdup(yytext);return T_BREAK;}
"continue" {yylval = strdup(yytext);return T_CONTINUE;}
"int" {yylval = strdup(yytext);return T_INT;}
"double" {yylval = strdup(yytext);return T_DOUBLE;}
"float" {yylval = strdup(yytext);return T_FLOAT;}
"char" {yylval = strdup(yytext);return T_CHAR;}
"void" {yylval = strdup(yytext);return T_VOID;}
"#include" {yylval = strdup(yytext);return T_INCLUDE;}
"main()" {yylval = strdup(yytext);return T_MAIN;}
{digit}+    {yylval = strdup(yytext);return T_NUM;}
{digit}+.{digit}+ {yylval = strdup(yytext);return T_FLOAT;}
{alpha}({alpha}|{digit})* {yylval = strdup(yytext);return T_IDENTIFIER;}
{alpha}({alpha}|{digit})*"\.h"?  {yylval = strdup(yytext);return T_HEADER;}
\".*\" {yylval = strdup(yytext);return T_STRING;}
"<" {yylval = strdup(yytext);return T_lt;}
">"     {yylval = strdup(yytext);return T_gt;}
"="     {yylval = strdup(yytext);return T_eq;}
"<="    {yylval = strdup(yytext);return T_lteq;}
">="    {yylval = strdup(yytext);return T_gteq;}
"=="    {yylval = strdup(yytext);return T_eqeq;}
"!="    {yylval = strdup(yytext);return T_neq;}
"+"     {yylval = strdup(yytext);return T_pl;}
"-"     {yylval = strdup(yytext);return T_min;}
"*"     {yylval = strdup(yytext);return T_mul;}
"/"     {yylval = strdup(yytext);return T_div;}
"++"    {yylval = strdup(yytext);return T_incr;}
"--"    {yylval = strdup(yytext);return T_decr;}
"!"     {yylval = strdup(yytext);return T_noteq;}
"||"    {yylval = strdup(yytext);return T_or;}
"&&"    {yylval = strdup(yytext);return T_and;}


.    return yytext[0];

%%
