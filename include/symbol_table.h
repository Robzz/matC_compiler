#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define N_BUCKETS 42

#include "types.h"

typedef struct {
    char* ident; 
    Type* t;
    unsigned int id;
} TableRecord;

TableRecord* new_record(char* ident, Type* t);
void delete_record(TableRecord* rec);

typedef struct RecordListS {
    TableRecord *rec;
    struct RecordListS *next;
} RecordList;

RecordList* new_record_list();
void delete_record_list(RecordList* l);
void list_add_record(RecordList* l, TableRecord* rec);
TableRecord* list_search_record(RecordList* l, const char* name);

typedef struct {
    RecordList** buckets;
} SymbolTable;

SymbolTable* new_symbol_table();
void delete_symbol_table(SymbolTable* s);

/* Look for a symbol in the table.
 * If successful, stores the address of the record in ptr and return true.
 * Return false otherwise. */
bool lookup_symbol(char* ident, TableRecord* ptr);

/* */
void add_symbol(SymbolTable* s, TableRecord* tr);

/* Generic hash function */
unsigned int hash(const void* key, size_t len);
unsigned int hash_str(const char* str);

void print_symbol_table(const SymbolTable* s);

#endif
