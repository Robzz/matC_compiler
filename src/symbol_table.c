#include "symbol_table.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

TableRecord* new_record(char* ident, Type* t) {
    static unsigned int id = 0;
    TableRecord* rec = malloc(sizeof(TableRecord));
    int n = strlen(ident) + 1;
    rec->ident = malloc(n * sizeof(char));
    strncpy(rec->ident, ident, n);
    rec->t = t;
    rec->id = id++;
    rec->addr = NULL;
    return rec;
}

void delete_record(TableRecord* rec) {
    if(rec) {
        if(rec->ident)
            free(rec->ident);
        if(rec->t) {
        if(rec->t->tf == STRING && rec->val.str_v)
            free(rec->val.str_v);
            delete_type(rec->t);
        }
        free(rec);
    }
}

RecordList* new_record_list() {
    RecordList* l = malloc(sizeof(RecordList));;
    l->rec = NULL;
    l->next = NULL;
    return l;
}

void delete_record_list(RecordList* l) {
    if(l) {
        if(l->rec)
            delete_record(l->rec);
        delete_record_list(l->next);
        free(l);
    }
}

void list_add_record(RecordList* l, TableRecord* rec) {
    RecordList* it = l;
    if(!it->rec) {
        it->rec = rec;
        return;
    }
    for(; it->next; it = it->next);
    it->next = new_record_list();
    it->next->rec = rec;
}

TableRecord* list_search_record(RecordList* l, const char* name) {
    for(RecordList* it = l; it && it->rec ; it = it->next) {
        if(!strcmp(name, it->rec->ident))
            return it->rec;
    }
    return NULL;
}

SymbolTable* new_symbol_table() {
    SymbolTable* s = malloc(sizeof(SymbolTable));
    s->buckets = malloc(N_BUCKETS * sizeof(RecordList*));
    for(int i = 0 ; i != N_BUCKETS ; ++i)
        s->buckets[i] = new_record_list();
    return s;
}

void delete_symbol_table(SymbolTable* s) {
    for(int i = 0 ; i != N_BUCKETS ; ++i)
        delete_record_list(s->buckets[i]);
    free(s->buckets);
    free(s);
}

void add_symbol(SymbolTable* s, TableRecord* tr) {
    unsigned int h = hash_str(tr->ident);
    unsigned int i = h % N_BUCKETS;
    RecordList* l = s->buckets[i];
    if(!list_search_record(l, tr->ident)) {
        list_add_record(l, tr);
    }
}

bool lookup_symbol(SymbolTable* s, char* ident, TableRecord** ptr) {
    unsigned int h = hash_str(ident);
    unsigned int i = h % N_BUCKETS;

    TableRecord* rec = list_search_record(s->buckets[i], ident);
    if(rec) {
        if(ptr)
            *ptr = rec;
        return true;
    }
    if(ptr)
        *ptr = NULL;
    return false;
}

/* Jenkins one-at-a-time hash function */
unsigned int hash(const void* key, size_t len) {
    char* ckey = (char*)key;
    int hash, i;
    for(hash = i = 0; i < len; ++i) {
        hash += ckey[i];
        hash += (hash << 10);
        hash ^= (hash >> 6);
    }
    hash += (hash << 3);
    hash ^= (hash >> 11);
    hash += (hash << 15);
    return hash;
}

unsigned int hash_str(const char* str) {
    return hash(str, strlen(str));
}

void print_symbol_table(const SymbolTable* s) {
    for(int i = 0 ; i != N_BUCKETS ; ++i) {
        const RecordList* l = s->buckets[i];
        for(const RecordList* it = l ; it != NULL ; it = it->next) {
            if(it->rec) {
                printf("%s : ", it->rec->ident);
                print_type(it->rec->t);
                printf("\n");
            }
        }
    }
}
