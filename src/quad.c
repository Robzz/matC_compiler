#include <stdio.h>
#include <stdlib.h>
#include "quad.h"

aQuad newQuad(SymbolTable arg1, SymbolTable arg2, char op, SymbolTable res) {
    aQuad new = malloc(sizeof (struct quad));
    new->label = 0;
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

listQuad addQuadTailList(listQuad quads, aQuad newquad) {
    aQuad tmp = quads->head;
    while (tmp->next != NULL) {
        tmp = tmp->next;
    }
    tmp->next = newquad;
    newquad->next = NULL;
    return quads;
}

listQuad addQuadHeadList(listQuad quads, aQuad newquad) {
    newquad->next = quads->head;
    quads->head = newquad;
    return quads;
}

listQuad addQuadPosList(listQuad quads, aQuad newquad, int lab) {
    aQuad tmp2 = NULL;
    aQuad tmp = quads->head;
    while ((tmp->label != lab)&&(tmp != NULL)) {
        tmp2 = tmp;
        tmp = tmp->next;
    }
    if (tmp == NULL) {
        addQuadTailList(quads, newquad);
    } else {
        tmp2->next = newquad;
        newquad->next = tmp;
        //        voir pour le label si il faut le mettre à jour ou pas
    }
    return quads;
}

aQuad getQuadLab(listQuad quads, aQuad newquad, int lab) {
    aQuad tmp = quads->head;
    while (tmp->label != lab) {
        tmp = tmp->next;
    }
    return tmp;
}

void destroyHeadList(listQuad quads) {
    aQuad tmp = quads->head->next;
    destroyQuad(quads->head);
    quads->head = tmp;
}

void destroyList(listQuad quads) {
    int i;
    for (i = 0; i < quads->number; i++) {
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
void printList(listQuad quads) {
    printf("List of quad :\n");
    aQuad tmp = quads->head;
    while (tmp->next != NULL) {
        printQuad(tmp);
        tmp = tmp->next;
    }
}

/*
 * print a quad 
 */
void printQuad(aQuad quad) {
   // printf("%d: %d %c %d = %d\n", quad->label, quad->arg1, quad->op, quad->arg2, quad->res);
}