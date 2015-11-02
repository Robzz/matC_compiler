%{

#include "y.tab.h"

extern void yyerror(char*);

%}

%option nounput
%option noinput

INT_LITERAL [1-9][0-9]*
FLOAT_LITERAL {INT_LITERAL}\.{INT_LITERAL}
%%

{INT_LITERAL}       { printf("Lex : integer %s\n", yytext); yylval.i = atoi(yytext); return integer; }
{FLOAT_LITERAL}     { printf("Lex : float %s\n", yytext); yylval.f = atof(yytext); return fp; }
[-+*/~=][(){};.]|\n { return *yytext; }
[ \t]               ;
.                   { yyerror("Unknown character"); };

%%
