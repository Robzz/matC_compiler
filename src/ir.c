#include "ir.h"

#include <stdio.h>

FILE* f;
char buf[128];
int sp;

void load_immediate(bool fp, int addr, value val) {
    if(fp) {
        sprintf(buf, "%f", val.float_v);
        fprintf(f, "li.s $f0, %s\n", buf);
        store(0, addr);
    }
    else {
        sprintf(buf, "%d", val.int_v);
        fprintf(f, "li $t0, %s\n", buf);
        store(0, addr);
    }
}

void store(int reg, int addr) {
    sprintf(buf, "0x%x", addr);
    fprintf(f, "sw $t%d, %s($sp)\n", reg, buf);
}

void print_num(TableRecord* rec) {
    if(rec->t->tf == FLOAT) {
        fprintf(f, "li $v0,2\n"
                   "l.s $f12, %d($sp)\n"
                   "syscall\n", rec->addr);
    }
    else {
        fprintf(f, "li $v0,1\n"
                   "lw $a0, %d($sp)\n"
                   "syscall\n", rec->addr);
    }
}

void print_string(char* name) {
    fprintf(f, "li $v0, 4\n"
               "la $a0, %s\n"
               "syscall\n", name);
}

int allocate_stack_frame(SymbolTable* s) {
    int offset = 0;
    for(int i = 0 ; i != N_BUCKETS ; ++i) {
        RecordList* l = s->buckets[i];
        if(!l->rec)
            continue;
        for(RecordList* it = l ; it != NULL ; it = it->next) {
            it->rec->addr = offset;
            offset += type_size(it->rec->t);
        }
    }
    return offset;
}

void ir_to_asm(char* out_file, listQuad l, SymbolTable* s, SymbolTable* strings) {
    f = fopen(out_file, "w");
    sp = 0x7fffffff - allocate_stack_frame(s);
    printf("Strings :\n");
    print_symbol_table(strings);

    fputs(".data\n", f);
    for(int i = 0 ; i != N_BUCKETS ; ++i) {
        RecordList* it = strings->buckets[i];
        for(; it && it->rec != NULL ; it = it->next) {
            fprintf(f, "%s: .asciiz \"%s\"\n", it->rec->ident, it->rec->val.str_v);
        }
    }
    fputs(".text\n", f);
    fputs("main:\n", f);
    for(aQuad it = l->head ; it != NULL ; it = it->next) {
        switch(it->op) {
            case OP_AFFECT:
                load_immediate(false, it->res->addr, it->arg1->val);
                break;
            case OP_PRINT:
                print_num(it->arg1);
                break;
            case OP_PRINTF:
                print_string(it->arg1->ident);
                break;
        }

        // Free anonymous symbols
        if(it->arg1 && it->arg1->t->tf != STRING && !lookup_symbol(s, it->arg1->ident, NULL))
            delete_record(it->arg1);
        if(it->arg2 && !lookup_symbol(s, it->arg2->ident, NULL))
            delete_record(it->arg2);
        if(it->res && !lookup_symbol(s, it->res->ident, NULL))
            delete_record(it->res);
    }

    fclose(f);
}
