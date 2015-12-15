#include "ir.h"

#include <stdio.h>
#include <string.h>

FILE* f;
char buf[128];
int sp;

void load_immediate(bool fp, int reg, value val) {
    /*if(rec->t->tf == FLOAT) {
        sprintf(buf, "%f", val.float_v);
        fprintf(f, "li.s $f0, %s\n", buf);
        store(0, rec->addr);
    }
    else {*/
    if (fp) {
        sprintf(buf, "%f", val.float_v);
        fprintf(f, "li.s $f%d, %s\n", reg, buf);
    } else {
        sprintf(buf, "%d", val.int_v);
        fprintf(f, "li $%d, %s\n", reg, buf);
    }
    //}
}

void load(int reg, TableRecord* rec) {
    sprintf(buf, "0x%x", rec->addr);
    if (rec->t->tf == FLOAT)
        fprintf(f, "l.s $f%d, %s($sp)\n", reg, buf);
    else
        fprintf(f, "lw $%d, %s($sp)\n", reg, buf);
}

void store(int reg, TableRecord* rec) {
    sprintf(buf, "0x%x", rec->addr);
    if (rec->t->tf == FLOAT)
        fprintf(f, "s.s $f%d, %s($sp)\n", reg, buf);
    else
        fprintf(f, "sw $%d, %s($sp)\n", reg, buf);
}

void convert_f_to_i(int reg_f, int reg_i) {
    fprintf(f, "cvt.w.s $%d, $f%d\n", reg_i, reg_f);
}

void convert_i_to_f(int reg_i, int reg_f) {
    fprintf(f, "cvt.s.w $%d, $f%d\n", reg_i, reg_f);
}

void number_addition(aQuad q) {
    if (!strcmp(q->arg1->ident, "<literal>"))
        load_immediate(q->arg1->t->tf == FLOAT, T0, q->arg1->val);
    else
        load(T0, q->arg1);
    if (!strcmp(q->arg2->ident, "<literal>"))
        load_immediate(q->arg2->t->tf == FLOAT, T1, q->arg2->val);
    else
        load(T1, q->arg2);
    if (q->arg2->t->tf == INT && q->arg1->t->tf == INT) {
        // Adding 2 ints
        fprintf(f, "add $t0, $t0, $t1\n");
    } else {
        // Float addition
        if (q->arg2->t->tf != q->arg1->t->tf) {
            // Float and int, must cast before
            if (q->arg1->t->tf == FLOAT)
                convert_i_to_f(T0, T0);
            else
                convert_i_to_f(T1, T1);
        }
        fprintf(f, "add.s $f%d, $f%d, $f1\n", T0, T0);
        if (q->res->t->tf == INT) {
            // Cast back to int before storing
            convert_f_to_i(0, T0);
        }
    }
    store(T0, q->res);
}

void number_substraction(aQuad q) {
    if (!strcmp(q->arg1->ident, "<literal>"))
        load_immediate(q->arg1->t->tf == FLOAT, T0, q->arg1->val);
    else
        load(T0, q->arg1);
    if (!strcmp(q->arg2->ident, "<literal>"))
        load_immediate(q->arg2->t->tf == FLOAT, T1, q->arg2->val);
    else
        load(T1, q->arg2);
    if (q->arg2->t->tf == INT && q->arg1->t->tf == INT) {
        // Substract 2 ints
        fprintf(f, "sub $t0, $t0, $t1\n");
    } else {
        // Float substract
        if (q->arg2->t->tf != q->arg1->t->tf) {
            // Float and int, must cast before
            if (q->arg1->t->tf == FLOAT)
                convert_i_to_f(T0, T0);
            else
                convert_i_to_f(T1, T1);
        }
        fprintf(f, "sub.s $f%d, $f%d, $f1\n", T0, T0);
        if (q->res->t->tf == INT) {
            // Cast back to int before storing
            convert_f_to_i(0, T0);
        }
    }
    store(T0, q->res);
}

void number_negation(aQuad q) {
    if(q->arg1->t->tf == INT) {
        load(T0, q->arg1);
        fprintf(f, "neg $t1, $t0\n");
        store(T1, q->res);
    }
    else {
        load(0, q->arg1);
        fprintf(f, "neg.s $f1, $f0\n");
        store(1, q->res);
    }
}

void number_multiplication(aQuad q) {
    if (!strcmp(q->arg1->ident, "<literal>"))
        load_immediate(q->arg1->t->tf == FLOAT, T0, q->arg1->val);
    else
        load(T0, q->arg1);
    if (!strcmp(q->arg2->ident, "<literal>"))
        load_immediate(q->arg2->t->tf == FLOAT, T1, q->arg2->val);
    else
        load(T1, q->arg2);
    if (q->arg2->t->tf == INT && q->arg1->t->tf == INT) {
        // Adding 2 ints
        fprintf(f, "mul $t0, $t0, $t1\n");
    } else {
        // Float addition
        if (q->arg2->t->tf != q->arg1->t->tf) {
            // Float and int, must cast before
            if (q->arg1->t->tf == FLOAT)
                convert_i_to_f(T0, T0);
            else
                convert_i_to_f(T1, T1);
        }
        fprintf(f, "mul.s $f%d, $f%d, $f1\n", T0, T0);
        if (q->res->t->tf == INT) {
            // Cast back to int before storing
            convert_f_to_i(0, T0);
        }
    }
    store(T0, q->res);
}

void number_division(aQuad q) {
    if (!strcmp(q->arg1->ident, "<literal>"))
        load_immediate(q->arg1->t->tf == FLOAT, T0, q->arg1->val);
    else
        load(T0, q->arg1);
    if (!strcmp(q->arg2->ident, "<literal>"))
        load_immediate(q->arg2->t->tf == FLOAT, T1, q->arg2->val);
    else
        load(T1, q->arg2);
    if (q->arg2->t->tf == INT && q->arg1->t->tf == INT) {
        // Adding 2 ints
        fprintf(f, "div $t0, $t0, $t1\n");
    } else {
        // Float addition
        if (q->arg2->t->tf != q->arg1->t->tf) {
            // Float and int, must cast before
            if (q->arg1->t->tf == FLOAT)
                convert_i_to_f(T0, T0);
            else
                convert_i_to_f(T1, T1);
        }
        fprintf(f, "div.s $f%d, $f%d, $f1\n", T0, T0);
        if (q->res->t->tf == INT) {
            // Cast back to int before storing
            convert_f_to_i(0, T0);
        }
    }
    store(T0, q->res);
}

void int_modulus(aQuad q) {
    if (!strcmp(q->arg1->ident, "<literal>"))
        load_immediate(false, T0, q->arg1->val);
    else
        load(T0, q->arg1);
    if (!strcmp(q->arg2->ident, "<literal>"))
        load_immediate(false, T1, q->arg2->val);
    else
        load(T1, q->arg2);
    fprintf(f, "div $t0, $t1\n"
               "mfhi $t0\n");
    store(T0, q->res);
}

void print_num(TableRecord* rec) {
    value v;
    if (rec->t->tf == FLOAT) {
        v.int_v = 2;
        load_immediate(false, V0, v);
        load(12, rec);
        fprintf(f, "syscall\n");
    } else {
        v.int_v = 1;
        load_immediate(false, V0, v);
        load(A0, rec);
        fprintf(f, "syscall\n");
    }
}

void print_string(char* name) {
    value v;
    v.int_v = 4;
    load_immediate(false, V0, v);
    fprintf(f, "la $a0, %s\n"
            "syscall\n", name);
}

int allocate_stack_frame(SymbolTable* s) {
    int offset = 0;
    for (int i = 0; i != N_BUCKETS; ++i) {
        RecordList* l = s->buckets[i];
        if (!l->rec)
            continue;
        for (RecordList* it = l; it != NULL; it = it->next) {
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
    for (int i = 0; i != N_BUCKETS; ++i) {
        RecordList* it = strings->buckets[i];
        for (; it && it->rec != NULL; it = it->next) {
            fprintf(f, "%s: .asciiz \"%s\"\n", it->rec->ident, it->rec->val.str_v);
        }
    }
    fputs(".text\n", f);
    fputs("main:\n", f);
    for (aQuad it = l->head; it != NULL; it = it->next) {
        switch (it->op) {
            case OP_AFFECT:
                if(it->res->t->tf == MATRIX || it->res->t->tf == ARRAY) {
                    // TODO
                }
                else if (!strcmp("<literal>", it->arg1->ident)) {
                    load_immediate(it->res->t->tf == FLOAT ? true : false, T0, it->arg1->val);
                    store(T0, it->res);
                } else {
                    load(T0, it->arg1);
                    store(T0, it->res);
                }
                break;
            case OP_PRINT:
                print_num(it->arg1);
                break;
            case OP_PRINTF:
                print_string(it->arg1->ident);
                break;
            case OP_PLUS:
                number_addition(it);
                break;
            case OP_MINUS:
                number_substraction(it);
                break;
            case OP_UNARY_MINUS:
                number_negation(it);
                break;
            case OP_MUL:
                number_multiplication(it);
                break;
            case OP_DIV:
                number_division(it);
                break;
            case OP_MOD:
                int_modulus(it);
                break;
        }
    }

    fprintf(f, "li $v0,10\n"
            "syscall");
    fclose(f);
}
