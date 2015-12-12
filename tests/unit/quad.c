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
    TableRecord * rec1 = NULL;
    TableRecord * rec2 = NULL;
    TableRecord * rec3 = NULL;
    aQuad new = NULL;
    printf("init:");
    if (lookup_symbol(s, "il", &rec1) == true) {
        printf("1");
        if (lookup_symbol(s, "f1", &rec2) == true) {
            printf("2");
            if (lookup_symbol(s, "al", &rec3) == true) {
                printf("3");
                new = newQuad(rec1, rec2, '=', rec3);
                printQuad(new);
            }
        }

    }
    if (new != NULL) {
        list = addQuadHeadList(list, new);
        printList(list);
    }
    destroyHeadList(list);
    delete_symbol_table(s);

    return 0;
}

