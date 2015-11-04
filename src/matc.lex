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
INLINE_COMMENT \/\/.*$
MULTILINE_COMMENT \/\*([^*]*\*[^/]*?)\/
STRING_LITERAL \"[^"]*\"

%%

{INLINE_COMMENT}          { printf("Lex : found comment, ignoring\n"); }
{MULTILINE_COMMENT}       { printf("Lex : found comment %s, ignoring\n", yytext); }
{SIGN}{FLOAT_LITERAL}     { printf("Lex : float %s\n", yytext);
                            float f = strtof(yytext, NULL); 
                            yylval.f = f;
                            return fp; }
{STRING_LITERAL}          { printf("Found string literal : %s\n", yytext); }
{SIGN}{DEC_INT_LITERAL}   { printf("Lex : integer %s\n", yytext); yylval.i = atoi(yytext); return integer; }
{MATRIX}    { printf("Lex : matrix\n"); return MATRIX; }
{INT}       { return INT; }
{FLOAT}     { return FLOAT; }
{VOID}      { return VOID; }
{MAIN}      { return MAIN; }
{IDENT}     { printf("Lex : identifier : %s\n", yytext); yylval.s = malloc((yyleng+1)*sizeof(char)); strcpy(yylval.s, yytext); return id; }
[-+*/~=(){};,.\[\]] { return *yytext; }
[ \t]               ;
.                   { yyerror("Unknown character\n");; }

%%

#ifdef LEXER_TEST_BUILD
int main(int argc, char** argv) {
    while(yylex()) { }
    return 0;
}
#endif
