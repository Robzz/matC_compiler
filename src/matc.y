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

declaration: type_name decl_list

decl_list: decl_id
           | decl_list ',' decl_id

decl_id: id { printf("Declaring variable %s\n", $1); }
         | id '[' integer ']' { printf("Declaring 1D matrix %s (size %d)\n", $1, $3); }
         | id '[' integer ']' '[' integer ']' { printf("Declaring 2D matrix %s (size (%d,%d))\n", $1, $3, $6); }

assignment: id '=' value

initialized_declaration : type_name decl_list '=' value_list { printf("Declare and initialize\n"); }

value_list: value
           | value_list ',' value

type_name: MATRIX
           | INT
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
