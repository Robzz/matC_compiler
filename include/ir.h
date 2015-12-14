#ifndef IR_H
#define IR_H

#include "quad.h"

void load_immediate(bool fp, int addr, value val);

void store(int reg, int addr);

void print_num(TableRecord* rec);

void print_string();

int allocate_stack_frame(SymbolTable* s);

void ir_to_asm(char* out_file, listQuad l, SymbolTable* s, SymbolTable* strings);

#endif
