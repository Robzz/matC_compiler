%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "debug.h"
#include "types.h"
#include "symbol_table.h"
#include "quad.h"
#include "ir.h"

SymbolTable* symtable;
SymbolTable* static_strings;
TypeFamily lasttype;
RecordList* new_symbols;
RecordList* temp_syms;
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
    } codegen;
    RecordList* l;
}
 
%token <codegen> MATRIX_TKN INT_TKN FLOAT_TKN VOID NEQ EQ INCR DECR AND OR CONST OPPAR CLPAR OPBRACKET CLBRACKET
%token <codegen> IF ELSE WHILE FOR SUP INF SUPEQ INFEQ RETURN MINUS PLUS MULT DIV TILDE MOD AFFECT
%token <i> integer 
%token <s> id 
%token <f> fp
%token <s> string;

%type <l> parameter_list
%type <i> type_name;
%type <codegen> expr matrix_extraction function_call boolean_expr increment decrement value number
%type <codegen> matrix_value matrix_line line_list arithmetic_expr decl_id initialization

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
number : integer {  
        DBG(printf("Yacc : int %d\n", $1));
        $$.result = new_record("<literal>", new_type(INT));
        $$.result->val.int_v = $1;
        $$.code = NULL;
    }
         | fp {
        DBG(printf("Yacc : float %f\n", $1)); 
        $$.result = new_record("<literal>", new_type(FLOAT));
        $$.result->val.float_v = $1;
        $$.code = NULL;
    }

number_list: number
           | number_list ',' number

value: number { $$ = $1; }
       | matrix_value { $$.result = NULL ; $$.code = NULL; }

matrix_value: matrix_line
              | OPBRACKET line_list CLBRACKET

matrix_line: OPBRACKET number_list CLBRACKET { DBG(printf("Yacc : matrix line\n")); }

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

fn_decl: type_name id OPPAR fn_decl_param_list CLPAR block {
        DBG(printf("Yacc : declaring function\n"));
        free($2);
    }

fn_decl_param_list:
                    | fn_decl_param_list ',' type_name id { free($4); }
                    | type_name id { free($2); }

/* assignement */
assignment: id AFFECT expr {
        DBG(printf("Yacc : assignement %s\n", $1));
        free($1);
    }

matrix_element_assignment: matrix_extraction AFFECT expr

/* Declarations and initializations */
declaration: type_name decl_list { 
    // Correct the types for non-array elements
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
    }

    // "Clear" the list
    new_symbols->rec = NULL;
    new_symbols->next = NULL;
}

decl_list: decl_or_init
           | decl_list ',' decl_or_init

decl_or_init: decl_id
              | initialization

decl_id: id {
        DBG(printf("Yacc : declaring variable %s\n", $1));
        // Types are wrong, they're fixed in the declaration rule
        TableRecord* rec = new_record($1, new_type(FLOAT));
        list_add_record(new_symbols, rec);
        $$.result = rec;
        $$.code = NULL;
    }
         | id '[' integer ']' {
        DBG(printf("Yacc : declaring 1D matrix %s (size %d)\n", $1, $3));
        list_add_record(new_symbols, new_record($1, new_matrix_type(1, $3)));
        $$.result = list_search_record(new_symbols, $1);
        $$.code = NULL;
    }
         | id '[' integer ']' '[' integer ']' {
        DBG(printf("Yacc : declaring 2D matrix %s (size (%d,%d))\n", $1, $3, $6));
        list_add_record(new_symbols, new_record($1, new_matrix_type($3, $6)));
        $$.result = list_search_record(new_symbols, $1);
        $$.code = NULL;
}

initialization: decl_id AFFECT expr {
        DBG(printf("Yacc : initializing variable\n"));
        aQuad q = newQuad($3.result, NULL, OP_AFFECT, $1.result);
        addQuadTailList(list, q);
        $$ = $1;
    }

line_list: matrix_line
           | line_list ',' matrix_line

/* expressions */
expr: OPPAR expr CLPAR { $$ = $2; }
      | id {
        TableRecord * tmp;
        lookup_symbol(symtable, $1, &tmp);
        $$.result = tmp;
        $$.code=NULL;
        free($1);
    }
      | value { $$ = $1; }
      | matrix_extraction
      | function_call { $$ = $1; }
      | arithmetic_expr { $$ = $1; }
      | boolean_expr
      | increment
      | decrement

increment: INCR id {
        DBG(printf("Yacc : incr %s\n", $2));
        free($2);
    }
           | id INCR {
        DBG(printf("Yacc : %s incr \n", $1));
        free($1);
    }

decrement: DECR id {
        DBG(printf("Yacc : decr %s \n", $2));
        free($2);
    }
           | id DECR {
        DBG(printf("Yacc : %s decr \n", $1));
        free($1);
    }

arithmetic_expr: expr PLUS expr {
        /*
        if($1.result->t->tf == $3.result->t->tf) {
            if($1.result->t->tf == INT){
                $$.result->val.int_v=$1.result->val.int_v + $3.result->val.int_v;
            }
            if($1.result->t->tf == FLOAT){
                $$.result->val.float_v=$1.result->val.float_v + $3.result->val.float_v;
            }
        }*/
        TableRecord* dest = new_record("<temp>", NULL);
        list_add_record(temp_syms, dest);
        aQuad new = newQuad($1.result, $3.result, OP_PLUS, dest);
        $$.code = new;
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
function_call: id OPPAR string CLPAR {
        static int nstrings = 0;
        if(strcmp("printf", $1)) {
            // Error : only printf accepts strings
        }
        else {
            // TODO : check if the string already exists to avoid unneeded duplication
            ++nstrings;
            int n_chars = 6;
            for(int i = nstrings ; i != 0 ; i /= 10)
                ++n_chars;
            char* str_name = malloc(n_chars * sizeof(char));
            sprintf(str_name, "str_%d", nstrings);
            TableRecord* rec = new_record(str_name, new_type(STRING));
            rec->val.str_v = $3;
            add_symbol(static_strings, rec);
            aQuad q = newQuad(rec, NULL, OP_PRINTF, NULL);
            addQuadTailList(list, q);
        }
        free($1);
}
               | id OPPAR parameter_list CLPAR {
        DBG(printf("Yacc : calling function %s\n", $1));
        // TODO : check parameters validity
        if(!strcmp("print", $1)) {
            aQuad q = newQuad($3->rec, NULL, OP_PRINT, NULL);
            addQuadTailList(list, q);
        }
        free($3);
        free($1);
    }

parameter_list: { $$ = NULL; }
                | expr {
        $$ = new_record_list();
        list_add_record($$, $1.result);
}
                | parameter_list ',' expr {
        list_add_record($1, $3.result);
        $$ = $1;
    }

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
//    yydebug = 1;
#endif
    symtable = new_symbol_table();
    static_strings = new_symbol_table();
    new_symbols = new_record_list();
    list = newQuadList();
    int r = yyparse();
    printf("content symbol table : \n");
    print_symbol_table(symtable);
    printf("content quad list : \n");
    printList(list);

    ir_to_asm("out.s", list, symtable, static_strings);

    destroyList(list);
    delete_record_list(new_symbols);
    delete_record_list(temp_syms);
    delete_symbol_table(symtable);
    delete_symbol_table(static_strings);
    lex_free();
    return r;
}
#endif
