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

%token MATRIX INT FLOAT VOID MAIN NEQ EQ INCR DECR AND OR CONST IF ELSE WHILE FOR SUP INF SUPEQ INFEQ STRING
%token integer id 
%token fp /* float */

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

instr: call_function ';' { DBG(printf("Yacc : function\n")); }
       | loop '{' function_block '}' { DBG(printf("Yacc : loop\n")); }
       | declaration ';' { DBG(printf("Yacc : declaration\n")); }
       | assignment ';' { DBG(printf("Yacc : assigment\n")); }
       | increment ';' { DBG(printf("Yacc : increment\n")); }
       | decrement ';' { DBG(printf("Yacc : decrement\n")); }
       

assignment: id '=' value { DBG(printf("Yacc : assignement %s = ", $1)); }

increment: INCR id { DBG(printf("Yacc : incr %s\n", $2)); }
           | id INCR { DBG(printf("Yacc : %s incr \n", $1)); }

decrement: DECR id { DBG(printf("Yacc : decr %s \n", $2)); }
           | id DECR { DBG(printf("Yacc : %s decr \n", $1)); }
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

/*declaration of conditionnal operator*/
conditional_op: number EQ number { DBG(printf("Yacc : '==' conditionnal operator\n")); }
                | number NEQ number { DBG(printf("Yacc : '!=' conditionnal operator\n")); }
                | number SUP number { DBG(printf("Yacc : '>' conditionnal operator\n")); }
                | number INF number { DBG(printf("Yacc : '<' conditionnal operator\n")); }
                | number INFEQ number { DBG(printf("Yacc : '<=' conditionnal operator\n")); }
                | number SUPEQ number { DBG(printf("Yacc : '>=' conditionnal operator\n")); }
                | id EQ number { DBG(printf("Yacc : '==' conditionnal operator\n")); }
                | id NEQ number { DBG(printf("Yacc : '!=' conditionnal operator\n")); }
                | id SUP number { DBG(printf("Yacc : '>' conditionnal operator\n")); }
                | id INF number { DBG(printf("Yacc : '<' conditionnal operator\n")); }
                | id INFEQ number { DBG(printf("Yacc : '<=' conditionnal operator\n")); }
                | id SUPEQ number { DBG(printf("Yacc : '>=' conditionnal operator\n")); }
                | number EQ id { DBG(printf("Yacc : '==' conditionnal operator\n")); }
                | number NEQ id { DBG(printf("Yacc : '!=' conditionnal operator\n")); }
                | number SUP id { DBG(printf("Yacc : '>' conditionnal operator\n")); }
                | number INF id { DBG(printf("Yacc : '<' conditionnal operator\n")); }
                | number INFEQ id { DBG(printf("Yacc : '<=' conditionnal operator\n")); }
                | number SUPEQ id { DBG(printf("Yacc : '>=' conditionnal operator\n")); }
                | id EQ id { DBG(printf("Yacc : '==' conditionnal operator\n")); }
                | id NEQ id { DBG(printf("Yacc : '!=' conditionnal operator\n")); }
                | id SUP id { DBG(printf("Yacc : '>' conditionnal operator\n")); }
                | id INF id { DBG(printf("Yacc : '<' conditionnal operator\n")); }
                | id INFEQ id { DBG(printf("Yacc : '<=' conditionnal operator\n")); }
                | id SUPEQ id { DBG(printf("Yacc : '>=' conditionnal operator\n")); }

/*function declaration*/
call_function: id '(' parameters ')' { DBG(printf("Yacc : function %s \n", $1)); }

parameters: parameters ',' parameter 
            | parameter

parameter: id { DBG(printf("Yacc : parameter %s \n", $1)); }
           | number { DBG(printf("Yacc : number \n")); }
           | call_function
           | STRING
                
/*loop declaration*/
loop: loop_for
    | loop_while

loop_for: FOR '(' assignment ';' conditional_op ';' increment ')' { DBG(printf("Yacc : FOR loop \n")); }
        | FOR '(' declaration ';' conditional_op ';' increment ')' { DBG(printf("Yacc : FOR loop \n")); }
        | FOR '(' assignment ';' conditional_op ';' decrement ')' { DBG(printf("Yacc : FOR loop \n")); }
        | FOR '(' declaration ';' conditional_op ';' decrement ')' { DBG(printf("Yacc : FOR loop \n")); }

loop_while: WHILE '(' conditional_op ')' { DBG(printf("Yacc : WHILE loop \n")); }
%%

#ifndef LEXER_TEST_BUILD
int main(int argc, char** argv) {
    //yydebug = 1;
    return yyparse();
}
#endif
