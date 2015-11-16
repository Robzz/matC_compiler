#ifndef TYPES_H
#define TYPES_H

typedef enum { false, true } bool;

typedef enum { Int, Float, Matrix, Array } TypeFamily;

typedef struct {
    TypeFamily tf;
    union {
        int i;
        float f;
        void* a;
    };
} Type;

#endif
