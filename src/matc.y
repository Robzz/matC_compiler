%{
#include <stdio.h>

int yylex();

void yyerror(char* str) { printf("%s\n", str); };

#define YYDEBUG 1

%}

%union {
    int i;
    float f;
}

%token integer
%token fp /* float */

%type <i> integer;
%type <f> fp;

%%

file:
      | file S '\n'

S : integer { printf("int : %d\n", $1); }
    | fp { printf("float : %f\n", $1); }

%%

int main(int argc, char** argv) {
    // yydebug = 1;
    yyparse();
    return 0;
}
