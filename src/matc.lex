%{

#include "y.tab.h"

extern void yyerror(char*);

%}

%option nounput
%option noinput

IDENT [a-zA-Z_][-a-zA-Z0-9_]*
SIGN [-+]?
DEC_INT_LITERAL [0-9]+
FLOAT_LITERAL [0-9]+\.[0-9]+
MATRIX matrix
INT int
FLOAT float
VOID void
MAIN main

%%

{SIGN}{FLOAT_LITERAL}     { printf("Lex : float %s\n", yytext);
                            float f = strtof(yytext, NULL); 
                            yylval.f = f;
                            return fp; }
{SIGN}{DEC_INT_LITERAL}   { printf("Lex : integer %s\n", yytext); yylval.i = atoi(yytext); return integer; }
{MATRIX}    { printf("Lex : matrix\n"); return MATRIX; }
{INT}       { return INT; }
{FLOAT}     { return FLOAT; }
{VOID}      { return VOID; }
{MAIN}      { return MAIN; }
{IDENT}     { printf("Lex : identifier : %s\n", yytext); yylval.s = malloc((yyleng+1)*sizeof(char)); strcpy(yylval.s, yytext); return id; }
[-+*/~=(){};,.\[\]] { return *yytext; }
[ \t]               ;
.                   { printf("Lex : Unknown character %c\n", *yytext); };

%%
