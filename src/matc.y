%{
#include <stdio.h>
#include <stdlib.h>
#include "debug.h"
#include "types.h"
#include "symbol_table.h"
#include "quad.h"

SymbolTable* symtable;
TypeFamily lasttype;
RecordList* new_symbols;
listQuad list;

int yylex();
void lex_free();

void yyerror(char* str) {
    fprintf(stderr, str);
#ifdef LEXER_TEST_BUILD
    exit(1);
#endif
}

TypeFamily typename_to_typefamily(int token);

%}

%union {
    int i;
    float f;
    char* s;
    struct {
        TableRecord * result;
        struct quad * code;
    }codegen;
}
 
%token <codegen> MATRIX_TKN INT_TKN FLOAT_TKN VOID NEQ EQ INCR DECR AND OR CONST OPPAR CLPAR OPBRACKET CLBRACKET
%token <codegen> IF ELSE WHILE FOR SUP INF SUPEQ INFEQ STRING RETURN MINUS PLUS MULT DIV TILDE MOD AFFECT
%token <i> integer 
%token <s> id 
%token <f> fp
        
%type <i> type_name;
%type <codegen> expr matrix_extraction function_call boolean_expr increment decrement value number
%type <codegen> matrix_value matrix_line line_list arithmetic_expr

%left '[' ']'
%left MULT DIV
%left PLUS MINUS
%left MOD
%left UNARY TILDE '!'
%left EQ NEQ SUPEQ INFEQ '<' '>'
%left OR AND

%%

program: instr_list

instr_list: instr_list instr
           | instr

type_name: MATRIX_TKN { $$ = MATRIX_TKN; }
           | INT_TKN { $$ = INT_TKN; }
           | FLOAT_TKN { $$ = FLOAT_TKN; }
           | VOID { $$ = 42; }

statement: primary_statement ';'
           | loop { DBG(printf("Yacc : loop statement\n")); }
           | condition { DBG(printf("Yacc : conditional statement\n")); }

primary_statement: expr { DBG(printf("Yacc : expression statement\n")); }
                   | assignment { DBG(printf("Yacc : assignment statement\n")); }
                   | matrix_element_assignment { DBG(printf("Yacc : matrix element assigment\n")); }
                   | declaration { DBG(printf("Yacc : declaration statement\n")); }
                   | return

statement_list: statement
                | statement_list statement

return: RETURN expr { DBG(printf("Yacc : return statement\n")); }

/* Literal values */
number : integer 
                {  DBG(printf("Yacc : int %d\n", $1));
                    $$.result->value.int_v=$1;
                }
         | fp 
              { DBG(printf("Yacc : float %f\n", $1)); 
                $$.result->value.float_v=$1;
              }

number_list: number
           | number_list ',' number

value: number 
       | matrix_value 

matrix_value: matrix_line
              | OPBRACKET line_list CLBRACKET

              matrix_line: OPBRACKET number_list CLBRACKET { DBG(printf("Yacc : matrix line")); }

matrix_extraction: expr '[' interval_list ']' { printf("Yacc : matrix extraction\n"); }

interval_list: interval_list ';' interval
               | interval

interval: '*'
          | integer
          | integer '.' '.' integer

/* */
block: OPBRACKET statement_list CLBRACKET

instr: statement
       | fn_decl

/* Function declaration */

fn_decl: type_name id OPPAR fn_decl_param_list CLPAR block { DBG(printf("Yacc : declaring function\n")); }

fn_decl_param_list: 
                    | fn_decl_param_list ',' type_name id
                    | type_name id

/* assignement */
assignment: id AFFECT expr { DBG(printf("Yacc : assignement %s\n", $1)); }

matrix_element_assignment: matrix_extraction AFFECT expr

/* Declarations and initializations */
declaration: type_name decl_list { 
    for(RecordList* it = new_symbols ; it != NULL ; it = it->next) {
        TypeFamily tf = typename_to_typefamily($1);
        if(tf != MATRIX && tf != FLOAT) {
            Type* t = it->rec->t;
            while(t->arr_info) {
                t = t->arr_info->elem_t;
            }
            t->tf = tf;
        }
        add_symbol(symtable, it->rec);
        $$.result=it->rec;
    }

    // "Clear" the list
    new_symbols->rec = NULL;
    new_symbols->next = NULL;
}

decl_list: decl_or_init
           | decl_list ',' decl_or_init

decl_or_init: decl_id
              | initialization

decl_id: id { DBG(printf("Yacc : declaring variable %s\n", $1));
              // add_symbol(symtable, new_type(FLOAT)));
              list_add_record(new_symbols, new_record($1, new_type(FLOAT))); } /* TODO : this is SHIT. Not the real type */
         | id '[' integer ']' { DBG(printf("Y   acc : declaring 1D matrix %s (size %d)\n", $1, $3));
                                // add_symbol(symtable, new_record($1, new_matrix_type(1, $3))); 
                                list_add_record(new_symbols, new_record($1, new_matrix_type(1, $3))); }
         | id '[' integer ']' '[' integer ']' { DBG(printf("Yacc : declaring 2D matrix %s (size (%d,%d))\n", $1, $3, $6));
                                                // add_symbol(symtable, new_record($1, new_matrix_type($3, $6)));
                                                list_add_record(new_symbols, new_record($1, new_matrix_type($3, $6))); }

initialization: decl_id AFFECT expr { DBG(printf("Yacc : initializing variable\n")); }

line_list: matrix_line
           | line_list ',' matrix_line

/* expressions */
expr: STRING                
      | OPPAR expr CLPAR
      | id      
                {  
                TableRecord * tmp;
                if (lookup_symbol(symtable, $1, &tmp) == true) {
                    $$.result=tmp;
                }
                $$.code=NULL;
                }
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

arithmetic_expr: expr PLUS expr
                                    {
                                      if($1.result->t->tf  == $3.result->t->tf){
                                        if($1.result->t->tf == INT){
                                          $$.result->value.int_v=$1.result->value.int_v + $3.result->value.int_v;
                                        }
                                        if($1.result->t->tf == FLOAT){
                                          $$.result->value.float_v=$1.result->value.float_v + $3.result->value.float_v;
                                        }
                                      }
                                        aQuad new = newQuad($1.result, $2.result, OP_PLUS, $3.result);
                                        list = addQuadTailList(list, new);
                                    }
                 | expr MINUS expr 
                 | expr MULT expr
                 | expr DIV expr
                 | expr MOD expr
                 | MINUS expr %prec UNARY
                 | PLUS expr %prec UNARY
                 | TILDE expr %prec UNARY
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
condition: IF OPPAR expr CLPAR block
           | IF OPPAR expr CLPAR block ELSE block

/* function call */
function_call: id OPPAR parameter_list CLPAR { DBG(printf("Yacc : calling function %s\n", $1)); }

parameter_list: 
                | expr
                | parameter_list ',' expr

/*loop declaration*/
loop: loop_for block { DBG(printf("Yacc : parsed loop \n")); }
    | loop_while block { DBG(printf("Yacc : parsed loop \n")); }

loop_for: FOR OPPAR primary_statement ';' expr ';' primary_statement CLPAR { DBG(printf("Yacc : FOR loop \n")); }

loop_while: WHILE OPPAR expr CLPAR { DBG(printf("Yacc : WHILE loop \n")); }
%%

TypeFamily typename_to_typefamily(int token) {
    return token == MATRIX_TKN ? MATRIX :
           token == INT_TKN ?    INT :
           token == FLOAT_TKN ?  FLOAT :
                                 UNREACHABLE();
}

#ifndef LEXER_TEST_BUILD
int main(int argc, char** argv) {
#ifdef DEBUG
    yydebug = 1;
#endif
    symtable = new_symbol_table();
    new_symbols = new_record_list();
    list = newQuadList();
    int r = yyparse();
    printf("content symbol table : \n");
    print_symbol_table(symtable);
    printf("content quad list : \n");
    printList(list);
    destroyList(list);
    delete_symbol_table(symtable);
    lex_free();
    return r;
}
#endif
