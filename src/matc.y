%{
#include <stdio.h>
#include <stdlib.h>
#include "debug.h"

int yylex();

void yyerror(char* str) {
    fprintf(stderr, str);
#ifdef LEXER_TEST_BUILD
    exit(1);
#endif
}

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
%token NEQ
%token EQ
%token INCR
%token DECR
%token AND
%token OR
%token CONST
%token IF
%token ELSE
%token WHILE
%token FOR

%token integer
%token fp /* float */
%token id

%type <i> integer;
%type <f> fp;
%type <s> id;

%%

program: INT MAIN '(' ')' '{' function_block '}' { DBG(printf("Yacc : main function\n")); }

type_name: MATRIX
           | INT
           | FLOAT
           | VOID

/* Literal values */
number : integer { DBG(printf("Yacc : int %d\n", $1)); }
         | fp { DBG(printf("Yacc : float %f\n", $1)); }

number_list: number
           | number_list ',' number

value: number
       | matrix_value

matrix_value: matrix_line
              | '{' line_list '}'

matrix_line: '{' number_list '}'

/* */
function_block: function_block instr { DBG(printf("Yacc : instruction\n")); }
                |

instr: declaration ';' { DBG(printf("Yacc : declaration\n")); }
       | assignment ';' { DBG(printf("Yacc : assigment\n")); }

assignment: id '=' value

/* Declarations and initializations */
declaration: type_name decl_list

decl_list: decl_or_init
           | decl_list ',' decl_or_init

decl_or_init: decl_id
              | initialization

decl_id: id { DBG(printf("Yacc : declaring variable %s\n", $1)); }
         | id '[' integer ']' { DBG(printf("Yacc : declaring 1D matrix %s (size %d)\n", $1, $3)); }
         | id '[' integer ']' '[' integer ']' { DBG(printf("Yacc : declaring 2D matrix %s (size (%d,%d))\n", $1, $3, $6)); }

initialization: decl_id '=' value { DBG(printf("Yacc : initializing variable\n")); }

line_list: matrix_line
           | line_list ',' matrix_line

%%

#ifndef LEXER_TEST_BUILD
int main(int argc, char** argv) {
    //yydebug = 1;
    return yyparse();
}
#endif
