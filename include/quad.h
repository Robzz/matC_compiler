/* 
 * File:   quad.h
 * Author: dragorane
 *
 * struct for quad
 */
#ifndef QUAD_H
#define QUAD_H
#include "symbol_table.h"

typedef struct quad{
    int label;
    char op;
    SymbolTable arg1;
    SymbolTable arg2;
    SymbolTable res;
    struct quad* next;
} * aQuad;

typedef struct quad_list{
    aQuad head;
    int number;
} * listQuad;

/*
 * Generate a new quad
 */
aQuad newQuad(SymbolTable arg1, SymbolTable arg2, char op, SymbolTable res);

/*
 * Create a new quad List
 */
listQuad newQuadList();

/*
 * add new quad to a list
 */
listQuad addQuadTailList(listQuad quads, aQuad newquad);

/*
 * add new quad to a list
 */
listQuad addQuadHeadList(listQuad quads, aQuad newquad);

/*
 * add new quad to a list before the label "lab"
 * exemple : pos=3, our quad becore number 3 and the old number 3 become 4
 */
listQuad addQuadPosList(listQuad quads, aQuad newquad, int lab);

/*
 * return quad with label; NULL if not exist
 */
aQuad getQuadLab(listQuad quads, aQuad newquad, int lab);
/*
 * print quad list
 */
void printList(listQuad quads);

/*
 * print a quad 
 */
void printQuad(aQuad quad);

/*
 * destroy head of the quad list
 */
void destroyHeadList(listQuad quads);

/*
 * free quad list
 */
void destroyList(listQuad quads);

/*
 * free a quad
 */
void destroyQuad(aQuad quad);


#endif