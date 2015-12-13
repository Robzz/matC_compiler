#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define N_BUCKETS 42

#include "types.h"

/* Symbol table element */
typedef struct {
    char* ident; 
    Type* t;
    unsigned int id;
    union {
        int int_v;
        float float_v;
    } value;
} TableRecord;

/* Create a new symbol table record */
TableRecord* new_record(char* ident, Type* t);
void delete_record(TableRecord* rec);

/* List of symbol table records */
typedef struct RecordListS {
    TableRecord *rec;
    struct RecordListS *next;
} RecordList;

/* Create a new empty record list */
RecordList* new_record_list();
/* Delete a record list and the records it contains */
void delete_record_list(RecordList* l);
/* Add a record to a list. The list takes ownership. */
void list_add_record(RecordList* l, TableRecord* rec);
/* Look for a symbol in a list */
TableRecord* list_search_record(RecordList* l, const char* name);

/* The actual symbl table */
typedef struct {
    RecordList** buckets;
} SymbolTable;

/* Create a new empty symbol table */
SymbolTable* new_symbol_table();
/* Delete a symbol table and the symbols in contains */
void delete_symbol_table(SymbolTable* s);

/* Look for a symbol in the table.
 * If successful, stores the address of the record in ptr and return true.
 * Return false otherwise. */
bool lookup_symbol(SymbolTable* s, char* ident, TableRecord** ptr);

/* Add a symbol to the symbol table. The table takes ownership. */
void add_symbol(SymbolTable* s, TableRecord* tr);

/* Generic hash function */
unsigned int hash(const void* key, size_t len);
/* Hash a a string */
unsigned int hash_str(const char* str);

/* Prints the contents of a symbol table */
void print_symbol_table(const SymbolTable* s);

#endif
