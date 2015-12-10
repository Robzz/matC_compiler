#ifndef AST_H
#define AST_H

#include "matrix.h"

typedef enum { Int, Float, Mat, None } ValueType;

typedef enum { Declaration, Assignment } NodeType;

typedef struct {
    ValueType t;
    union {
        int i;
        float f;
        Matrix m;
    };
} Value;

typedef struct {
    int sym;
    Value val;
} AssignmentNode;

typedef struct {
    int sym;
    Value val;
} DeclarationNode;

typedef union {
    DeclarationNode decl;
    AssignmentNode  assign;
} Node;

typedef struct {
    NodeType t;
    Node n;
} AstNode;


#endif
