#ifndef IR_H
#define IR_H

#include "quad.h"

#define ZERO 0
#define AT   1
#define V0   2
#define V1   3
#define A0   4
#define A1   5
#define A2   6
#define A3   7
#define T0   8
#define T1   9
#define T2   10
#define T3   11
#define T4   12
#define T5   13
#define T6   14
#define T7   15
#define S0   16
#define S1   17
#define S2   18
#define S3   19
#define S4   20
#define S5   21
#define S6   22
#define S7   23
#define T8   24
#define T9   25
#define K0   26
#define K1   27
#define GP   28
#define SP   29
#define FP   30
#define RA   31

void load_immediate(bool fp, int reg, value val);

void load(int reg, TableRecord* rec);

void store(int reg, TableRecord* rec);

void convert_f_to_i(int reg_f, int reg_i);

void convert_i_to_f(int reg_i, int reg_f);

void number_addition(aQuad q);

void number_substraction(aQuad q);

void number_multiplication(aQuad q);

void number_division(aQuad q);

void number_modulo(aQuad q);

void print_num(TableRecord* rec);

void print_string();

int allocate_stack_frame(SymbolTable* s);

void ir_to_asm(char* out_file, listQuad l, SymbolTable* s, SymbolTable* strings);

#endif
