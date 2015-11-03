%{
#include <stdio.h>

int yylex();

void yyerror(char* str) { printf("%s\n", str); };

#define YYDEBUG 1

%}

%union {
    int i;
    float f;
    char* s;
}

%token MATRIX
%token INT
%token FLOAT
%token VOID
%token MAIN

%token integer
%token fp /* float */
%token id

%type <i> integer;
%type <f> fp;
%type <s> id;

%%

program: INT MAIN '(' ')' '{' function_block '}' { printf("Found main function\n"); }

function_block: function_block instr { printf("Got instruction\n"); }
                |

instr: declaration ';' { printf("Declaration\n"); }
       | assignment ';' { printf("Assigment\n"); }
       | initialized_declaration ';' { printf("Declare and initialize\n"); }

declaration: type_name id
             | matrix_declaration

matrix_declaration: MATRIX id '[' integer ']'
                    | MATRIX id '[' integer ']' '[' integer ']'

assignment: id '=' value

initialized_declaration : type_name id '=' value { printf("Declare and initialize\n"); }

type_name: INT
           | FLOAT
           | VOID
           | id { printf("Identifier : %s\n", $1); }

value: number
       | matrix_value

matrix_value: 

number : integer { printf("int : %d\n", $1); }
         | fp { printf("float : %f\n", $1); }

%%

int main(int argc, char** argv) {
//    yydebug = 1;
    return yyparse();
}
