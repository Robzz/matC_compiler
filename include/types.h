#ifndef TYPES_H
#define TYPES_H

#ifndef NULL
#define NULL 0
#endif

#include <stdlib.h>

typedef enum { false, true } bool;

typedef enum { INT, FLOAT, MATRIX, ARRAY } TypeFamily;

struct Type_s;

typedef struct {
    struct Type_s* elem_t;
    size_t size;
} ArrayType;

typedef struct Type_s {
    TypeFamily tf;
    ArrayType* arr_info;    
} Type;

Type* new_type(TypeFamily t);
Type* new_array_type(size_t size, Type *t);
Type* new_matrix_type(size_t rows, size_t columns);

void delete_type(Type* t);

void print_type(const Type* t);

Type* type_of_str(const char* str);

#endif
