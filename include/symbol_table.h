#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "types.h"

typedef struct {
    char* ident; 
    Type t;
    unsigned int id;
} TableRecord;

typedef struct {
    unsigned int size;
    unsigned int capacity;
    Type* table;
} SymbolTable;


/* Look for a symbol in the table.
 * If successful, stores the address of the record in ptr and return true.
 * Return false otherwise. */
bool lookup_symbol(char* ident, TableRecord* ptr);
bool add_symbol(TableRecord tr);

#endif
