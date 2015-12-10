#include "types.h"
#include <stdio.h>

int main(int argc, char** argv) {
    Type *i = new_type(INT),
         *f = new_type(FLOAT),
         *a1 = new_array_type(5, new_type(FLOAT)),
         *m1 = new_matrix_type(1,3),
         *m2 = new_matrix_type(4, 5);
    print_type(i);
    printf("\n");
    print_type(f);
    printf("\n");
    print_type(a1);
    printf("\n");
    print_type(m1);
    printf("\n");
    print_type(m2);
    printf("\n");

    return 0;
}
