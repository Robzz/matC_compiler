/* 
 * File:   quad.h
 * Author: dragorane
 *
 * struct for quad operation
 */
#ifndef QUAD_H
#define QUAD_H

typedef struct quad{
    int id;
    char op;
    SymbolTable* arg1;
    SymbolTable* arg2;
    SymbolTable* res;
    struct quad* next;
}aQuad;

typedef struct quad_list{
    aQuad head;
    int number;
}listQuad;

/*
 * Generate a new quad
 */
aQuad newQuad(SymbolTable* arg1, SymbolTable* arg2, char op, SymbolTable* res);

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
 * add new quad to a list before the position "pos"
 * exemple : pos=3, our quad becore number 3 and the old number 3 become 4
 */
listQuad addQuadPosList(listQuad quads, aQuad newquad, int pos);

/*
 * return quad at the position pos
 */
aQuad getQuadPos(listQuad quads, aQuad newquad, int pos);
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