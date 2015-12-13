#ifndef TYPES_H
#define TYPES_H

#ifndef NULL
#define NULL 0
#endif

#include <stdlib.h>

typedef enum { false, true } bool;

typedef enum { INT, FLOAT, MATRIX, ARRAY } TypeFamily;

struct Type_s;

/* The type contained in an array */
typedef struct {
    struct Type_s* elem_t;
    size_t size;
} ArrayType;

/* A matC type */
typedef struct Type_s {
    TypeFamily tf;
    ArrayType* arr_info;    
} Type;

/* Create a new type */
Type* new_type(TypeFamily t);
/* Create a new array type */
Type* new_array_type(size_t size, Type *t);
/* Create a new matrix type of specified dimensions.
 * If rows == 1 or columns == 1, the matrix is 1D. */
Type* new_matrix_type(size_t rows, size_t columns);

/* Delete a type */
void delete_type(Type* t);

/* Print a type */
void print_type(const Type* t);

/* Convert the name of a type to the actual type */
Type* type_of_str(const char* str);

#endif
