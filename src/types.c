#include "types.h"
#include <assert.h>
#include <stdio.h>

Type* new_type(TypeFamily t) {
    Type* tt = malloc(sizeof(Type));
    tt->tf = t;
    tt->arr_info = NULL;
    return tt;
}

Type* new_array_type(size_t size, Type* t) {
    Type* tt = new_type(ARRAY);
    tt->arr_info = malloc(sizeof(ArrayType));
    tt->arr_info->elem_t = t;
    tt->arr_info->size = size;
    return tt;
}

Type* new_matrix_type(size_t rows, size_t columns) {
    Type* tt = new_array_type(columns, new_type(FLOAT));
    tt->tf = MATRIX;
    if(columns == 1 || rows == 1) {
        tt->arr_info->size = columns == 1 ? rows : columns;
        return tt;
    }
    Type* tt2 = new_array_type(rows, tt);
    tt2->tf = MATRIX;

    return tt2;
}

void delete_type(Type* t) {
    if(t->arr_info)
        delete_type(t->arr_info->elem_t);
    free(t->arr_info);
    free(t);
}

void print_type(const Type* t) {
    switch(t->tf) {
        case INT:
            printf("int");
            break;
        case FLOAT:
            printf("float");
            break;
        case MATRIX:
            printf("matrix[%lu]", t->arr_info->size);
            if(t->arr_info->elem_t->tf == MATRIX)
            printf("[%lu]", t->arr_info->elem_t->arr_info->size);
            break;
        case ARRAY:
            printf("array");
            const Type* tt = t; 
            for(; tt->tf == ARRAY ; tt = tt->arr_info->elem_t) {
                printf("[%lu]", tt->arr_info->size);
            }
            printf(" (");
            print_type(tt);
            printf(")");
            break;
    }
}
