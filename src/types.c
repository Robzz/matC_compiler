#include "debug.h"
#include "types.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>


Type* new_type(TypeFamily t) {
    Type* tt = malloc(sizeof(Type));
    tt->tf = t;
    tt->arr_info = NULL;
    return tt;
}

Type* copy_type(Type* t) {
    Type* t2 = malloc(sizeof(Type));
    t2->tf = t->tf;
    if(t->arr_info) {
        t2->arr_info = malloc(sizeof(ArrayType));
        t2->arr_info->size = t->arr_info->size;
        t2->arr_info->elem_t = copy_type(t->arr_info->elem_t);
    }
    return t2;
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
    if(t) {
        if(t->arr_info) {
            delete_type(t->arr_info->elem_t);
            free(t->arr_info);
        }
        free(t);
    }
}

char* type_name(TypeFamily tf) {
    switch(tf) {
        case INT:
            return "int";
        case FLOAT:
            return "float";
        case MATRIX:
            return "matrix";
        case ARRAY:
            return "array";
        case STRING:
            return "string";
    }
    return (char*)(UNREACHABLE());
}

void print_type(const Type* t) {
    if(!t) {
        printf("none");
        return;
    }
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
        case STRING:
            printf("string");
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

size_t type_size(Type* t) {
    if(t->tf == INT || t->tf == FLOAT)
        return 4;
    else {
        return t->arr_info->size * type_size(t->arr_info->elem_t);
    }
}

Type* type_of_str(const char* str) {
    TypeFamily tf;
    if(!strcmp(str, "int")) 
        tf = INT; 
    else if(!strcmp(str, "float"))
        tf = FLOAT; 
    else if(!strcmp(str, "matrix"))
        tf = MATRIX; 
    else
        return NULL;
    Type* t = new_type(tf);

    return t;
}
