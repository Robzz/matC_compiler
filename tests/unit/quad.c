#include "quad.h"
#include <stdio.h>

int main(int argc, char** argv) {
    SymbolTable* s = new_symbol_table();
    Type *i = new_type(INT),
            *f = new_type(FLOAT),
            *a1 = new_array_type(5, new_type(FLOAT)),
            *m1 = new_matrix_type(1, 3),
            *m2 = new_matrix_type(4, 5);
    add_symbol(s, new_record("i1", i));
    add_symbol(s, new_record("f1", f));
    add_symbol(s, new_record("a1", a1));

    print_symbol_table(s);
    listQuad list = newQuadList();
    TableRecord* rec1 = list_search_record(s->buckets[0], "il");
    TableRecord* rec2 = list_search_record(s->buckets[1], "f1");
    TableRecord* rec3 = list_search_record(s->buckets[2], "al");
    aQuad new = newQuad(rec1, rec2, '=', rec3);
    list = addQuadHeadList(list, new);
    destroyHeadList(list);
    delete_symbol_table(s);

    return 0;
}

