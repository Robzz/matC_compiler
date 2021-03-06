#include "symbol_table.h"
#include <stdio.h>
#include <assert.h>

int main(int argc, char** argv) {
    SymbolTable* s = new_symbol_table();
    Type *i = new_type(INT),
         *f = new_type(FLOAT),
         *a1 = new_array_type(5, new_type(FLOAT)),
         *m1 = new_matrix_type(1,3),
         *m2 = new_matrix_type(4, 5);
    add_symbol(s, new_record("i1", i));
    add_symbol(s, new_record("f1", f));
    add_symbol(s, new_record("a1", a1));
    add_symbol(s, new_record("m1", m1));
    add_symbol(s, new_record("m2", m2));

    print_symbol_table(s);

    assert(lookup_symbol(s, "i1", NULL));
    assert(lookup_symbol(s, "f1", NULL));
    assert(lookup_symbol(s, "a1", NULL));
    assert(lookup_symbol(s, "m1", NULL));
    assert(lookup_symbol(s, "m2", NULL));

    delete_symbol_table(s);

    return 0;
}
