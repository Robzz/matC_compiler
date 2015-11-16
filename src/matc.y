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

%left '[' ']'
%left '*' '/'
%left '+' '-'
%left '%'
%left UNARY '~' '!'
%left EQ NEQ SUPEQ INFEQ '<' '>'
%left OR AND

%%

program: INT MAIN '(' ')' '{' block '}' { DBG(printf("Yacc : main function\n")); }

type_name: MATRIX
           | INT
           | FLOAT
           | VOID

statement: expr { DBG(printf("Yacc : expression statement\n")); }
           | assignment { DBG(printf("Yacc : assignment statement\n")); }
           | declaration

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

matrix_extraction: expr '[' interval_list ']' { printf("Yacc : matrix extraction\n"); }

interval_list: interval_list ';' interval
               | interval

interval: '*'
          | integer
          | integer '.' '.' integer

/* */
block: block instr { DBG(printf("Yacc : instruction\n")); }
                |

instr: loop '{' block '}' { DBG(printf("Yacc : loop\n")); }
       | condition { DBG(printf("Yacc : conditional\n")); }
       | declaration ';' { DBG(printf("Yacc : declaration\n")); }
       | assignment ';' { DBG(printf("Yacc : assigment\n")); }
       | matrix_element_assignment ';' { DBG(printf("Yacc : matrix element assigment\n")); }
       | expr ';'
       
/* assignement */
assignment: id '=' expr { DBG(printf("Yacc : assignement %s\n", $1)); }

matrix_element_assignment: matrix_extraction '=' expr

/* Declarations and initializations */
declaration: type_name decl_list

decl_list: decl_or_init
           | decl_list ',' decl_or_init

decl_or_init: decl_id
              | initialization

decl_id: id { DBG(printf("Yacc : declaring variable %s\n", $1)); }
         | id '[' integer ']' { DBG(printf("Yacc : declaring 1D matrix %s (size %d)\n", $1, $3)); }
         | id '[' integer ']' '[' integer ']' { DBG(printf("Yacc : declaring 2D matrix %s (size (%d,%d))\n", $1, $3, $6)); }

initialization: decl_id '=' expr { DBG(printf("Yacc : initializing variable\n")); }

line_list: matrix_line
           | line_list ',' matrix_line

/* expressions */
expr: STRING
      | '(' expr ')'
      | id
      | value
      | matrix_extraction
      | function_call
      | arithmetic_expr
      | boolean_expr
      | increment
      | decrement

increment: INCR id { DBG(printf("Yacc : incr %s\n", $2)); }
           | id INCR { DBG(printf("Yacc : %s incr \n", $1)); }

decrement: DECR id { DBG(printf("Yacc : decr %s \n", $2)); }
           | id DECR { DBG(printf("Yacc : %s decr \n", $1)); }

arithmetic_expr: expr '+' expr
                 | expr '-' expr
                 | expr '*' expr
                 | expr '/' expr
                 | expr '%' expr
                 | '-' expr %prec UNARY
                 | '+' expr %prec UNARY
                 | '~' expr %prec UNARY

boolean_expr: expr AND expr { DBG(printf("Yacc : AND expression\n")); }
              | expr OR expr { DBG(printf("Yacc : OR expression\n")); }
              | '!' expr { DBG(printf("Yacc : NOT expression\n")); }
              | expr EQ expr { DBG(printf("Yacc : comparison expression\n")); }
              | expr NEQ expr { DBG(printf("Yacc : comparison expression\n")); }
              | expr INFEQ expr { DBG(printf("Yacc : comparison expression\n")); }
              | expr SUPEQ expr { DBG(printf("Yacc : comparison expression\n")); }
              | expr '>' expr { DBG(printf("Yacc : comparison expression\n")); }
              | expr '<' expr { DBG(printf("Yacc : comparison expression\n")); }

/* condition declaration */
condition: IF '(' expr ')' '{' block '}'
           | IF '(' expr ')' '{' block '}' ELSE '{' block '}'

/* function call */
function_call: id '(' parameter_list ')' { DBG(printf("Yacc : calling function %s\n", $1)); }

parameter_list: 
                | expr
                | parameter_list ',' expr

/*loop declaration*/
loop: loop_for
    | loop_while

loop_for: FOR '(' statement ';' expr ';' statement ')' { DBG(printf("Yacc : FOR loop \n")); }

loop_while: WHILE '(' expr ')' { DBG(printf("Yacc : WHILE loop \n")); }
%%

#ifndef LEXER_TEST_BUILD
int main(int argc, char** argv) {
#ifdef DENBUG
    yydebug = 0;
#endif
    return yyparse();
}
#endif
