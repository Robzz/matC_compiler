CC=gcc
CFLAGS=-g --std=c11 -Wall -I../../include
OBJ_DIR=../../obj

all: types symtable

types: types.o $(OBJ_DIR)/types.o
	$(CC) $^ -o $@

symtable: symtable.o $(OBJ_DIR)/symbol_table.o $(OBJ_DIR)/types.o
	$(CC) $^ -o $@

types.o: types.c
	$(CC) -c -o $@ $< $(CFLAGS)

.PHONY: all
