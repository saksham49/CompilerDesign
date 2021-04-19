
%{
#include<string.h>
#include<stdio.h>
#define YYSTYPE char *
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
int line = 0;

%}
alpha [A-Za-z]
digit [0-9]
%option yylineno
%%
"//".*\n ;
"/\*"(.|\n)*"\*/" ;
[ \t\n] {yylval = strdup(yytext);}
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
"return" {yylval = strdup(yytext);return T_RETURN;}
{digit}+    {yylval = strdup(yytext);return T_NUM;}
{digit}+"."{digit}+ {yylval = strdup(yytext);return T_NUM;}
("+"|"-"){digit}+"."{digit}+("e"|"E")("+"|"-"){digit}+ {yylval = strdup(yytext);return T_NUM;}
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
"+"     {yylval = strdup(yytext);return T_plus;}
"-"     {yylval = strdup(yytext);return T_min;}
"*"     {yylval = strdup(yytext);return T_mul;}
"/"     {yylval = strdup(yytext);return T_div;}
"%"     {yylval = strdup(yytext);return T_perc;}
"++"    {yylval = strdup(yytext);return T_incr;}
"--"    {yylval = strdup(yytext);return T_decr;}
"!"     {yylval = strdup(yytext);return T_neq;}
"||"    {yylval = strdup(yytext);return T_or;}
"&&"    {yylval = strdup(yytext);return T_and;}
";"     {yylval = strdup(yytext);return T_sc;}
","     {yylval = strdup(yytext);return T_com;}
"."     {yylval = strdup(yytext);return T_fs;}
"[]"    {yylval = strdup(yytext);return T_sb;}
"["     {yylval = strdup(yytext);return T_osb;}
"]"     {yylval = strdup(yytext);return T_csb;}
"()"    {yylval = strdup(yytext);return T_ob;}
"("     {yylval = strdup(yytext);return T_oob;}
")"     {yylval = strdup(yytext);return T_cob;}
"{}"    {yylval = strdup(yytext);return T_cb;}
"{"     {yylval = strdup(yytext);return T_ocb;}
"}"     {yylval = strdup(yytext);return T_ccb;}


.    return yytext[0];

%%
