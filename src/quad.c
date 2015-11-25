#include <stdio.h>
#include <stdlib.h>
#include "quad.h"
#include "symbol_table.h

aQuad newQuad(SymbolTable * arg1, SymbolTable * arg2, char op, SymbolTable * res) {
    aQuad new = malloc(sizeof (struct quad));
    new->id = 0;
    new->op = op;
    new->arg1 = arg1;
    new->arg2 = arg2;
    new->res = res;
    new->next = NULL;
    return new;
}

listQuad newQuadList() {
    listQuad new = malloc(sizeof (struct quad_list));
    new->head = NULL;
    new->number = 0;
    return new;
}

listQuad addQuadTailList(listQuad quads, aQuad newquad);

listQuad addQuadHeadList(listQuad quads, aQuad newquad);

listQuad addQuadPosList(listQuad quads, aQuad newquad, int pos);

aQuad getQuadPos(listQuad quads, aQuad newquad, int pos);

void destroyHeadList(listQuad quads) {
    aQuad tmp = quads->head->next;
    destroyQuad(quads->head)
    quads->head = tmp;
}

void destroyList(listQuad quads) {
    for (int i = 0; i < quads->number; i++) {
        destroyHeadList(quads);
    }
    free(quads);
}

void destroyQuad(aQuad quad) {
    free(quad);
}

/*
 * print quad list
 */
void printList(listQuad quads);

/*
 * print a quad 
 */
void printQuad(aQuad quad);