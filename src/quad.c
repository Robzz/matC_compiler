#include <stdio.h>
#include <stdlib.h>
#include "quad.h"
#include "debug.h"

const char* op_to_string(Op o) {
    return (o == OP_PLUS) ?        "OP_PLUS" :
           (o == OP_MINUS) ?       "OP_MINUS" :
           (o == OP_MUL) ?         "OP_MUL" :
           (o == OP_DIV) ?         "OP_DIV" :
           (o == OP_MOD) ?         "OP_MOD" :
           (o == OP_UNARY_MINUS) ? "OP_UNARY_MINUS" :
           (o == OP_AFFECT) ?      "OP_AFFECT" :
           (o == OP_PRINT) ?       "OP_PRINT" :
           (o == OP_PRINTF) ?      "OP_PRINTF" :
                                   UNREACHABLE();
}

aQuad newQuad(TableRecord * arg1, TableRecord * arg2, Op op, TableRecord * res) {
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
    if (tmp == NULL) {
        quads->head = newquad;
    } else {
        while (tmp->next != NULL) {
            tmp = tmp->next;
        }
        tmp->next = newquad;
        newquad->next = NULL;
    }
    quads->number = quads->number + 1;
    return quads;
}

listQuad addQuadHeadList(listQuad quads, aQuad newquad) {
    newquad->next = quads->head;
    quads->head = newquad;
    quads->number = quads->number + 1;
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
    if (quads->head != NULL) {
        aQuad tmp = quads->head->next;
        destroyQuad(quads->head);
        quads->head = tmp;
    }
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
    while (tmp != NULL) {
        printQuad(tmp);
        tmp = tmp->next;
    }
}

/*
 * print a quad 
 */
void printQuad(aQuad quad) {
    if (quad != NULL) {
        printf("label : %d\n", quad->label);
        printf("arg1 : ");
        if(quad->arg1) {
            if(quad->arg1->ident)
                printf("%s ", quad->arg1->ident);
            printf("(");
            print_type(quad->arg1->t);
            printf(")\n");
        }
        else
            printf("NULL\n");
        printf("arg2 : ");
        if(quad->arg2) {
            printf("%s (", quad->arg2->ident);
            print_type(quad->arg2->t);
            printf(")\n");
        }
        else
            printf("NULL\n");
        printf("op : %s\n", op_to_string(quad->op));
        printf("res : ");
        if(quad->arg2) {
            printf("%s (", quad->res->ident);
            print_type(quad->res->t);
            printf(")\n");
        }
        else
            printf("NULL\n");
    }
}
