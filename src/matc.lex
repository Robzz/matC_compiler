%{

#include "y.tab.h"
#include "debug.h"

extern void yyerror(char*);

%}

%option nounput
%option noinput

IDENT [a-zA-Z_][-a-zA-Z0-9_]*
SIGN [-+]?
DEC_INT_LITERAL [0-9]+
FLOAT_LITERAL [0-9]+\.[0-9]+
INLINE_COMMENT \/\/.*$
MULTILINE_COMMENT \/\*([^*]*\*[^/]*?)\/
STRING_LITERAL \"[^"]*\"

%%

{INLINE_COMMENT}          { DBG(printf("Lex : found comment, ignoring\n")); }
{MULTILINE_COMMENT}       { DBG(printf("Lex : found comment %s, ignoring\n", yytext)); }
{FLOAT_LITERAL}     { DBG(printf("Lex : float %s\n", yytext));
                      float f = strtof(yytext, NULL); 
                      yylval.f = f;
                      return fp; }
{STRING_LITERAL}          { DBG(printf("Lex : string literal : %s\n", yytext)); return STRING; }
{DEC_INT_LITERAL}   { DBG(printf("Lex : integer %s\n", yytext)); yylval.i = atoi(yytext); return integer; }
const     { DBG(printf("Lex : const\n")); return CONST; }
if        { DBG(printf("Lex : if\n")); return IF; }
else      { DBG(printf("Lex : else\n")); return ELSE; }
while     { DBG(printf("Lex : while\n")); return WHILE; }
for       { DBG(printf("Lex : for\n")); return FOR; }
matrix    { DBG(printf("Lex : matrix\n")); return MATRIX; }
int       { DBG(printf("Lex : int\n")); return INT; }
float     { DBG(printf("Lex : float\n")); return FLOAT; }
void      { DBG(printf("Lex : void\n")); return VOID; }
main      { DBG(printf("Lex : main\n")); return MAIN; }
{IDENT}   { DBG(printf("Lex : identifier : %s\n", yytext)); yylval.s = malloc((yyleng+1)*sizeof(char)); strcpy(yylval.s, yytext); return id; }
&&        { DBG(printf("Lex : operator &&\n")); return AND; }
\|\|      { DBG(printf("Lex : operator ||\n")); return OR; }
!=        { DBG(printf("Lex : operator !=\n")); return NEQ; }
==        { DBG(printf("Lex : operator ==\n")); return EQ; }
\>        { DBG(printf("Lex : operator >\n")); return SUP; }
\<        { DBG(printf("Lex : operator <\n")); return INF; }
\<=        { DBG(printf("Lex : operator <=\n")); return INFEQ; }
\>=        { DBG(printf("Lex : operator >=\n")); return SUPEQ; }
\+\+      { DBG(printf("Lex : operator ++\n")); return INCR; }
--        { DBG(printf("Lex : operator --\n")); return DECR; }
[-+*/~=(){};,.\[\]] { DBG(printf("Lex : token %c\n", *yytext)); return *yytext; }
[ \t\n]   ;
.         { DBG(printf("Lex : unknown token %c\n", *yytext)); yyerror("Unknown character\n"); }

%%
