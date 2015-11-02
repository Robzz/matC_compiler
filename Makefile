CC=gcc

BIN_DIR=bin
OBJ_DIR=obj
INCLUDE_DIR=include
SRC_DIR=src
TARGET=ubercompiler

CFLAGS=-c -Wall -g -I$(INCLUDE_DIR)
LDFLAGS=-lfl -ly

all: dirs $(BIN_DIR)/$(TARGET)

$(BIN_DIR)/$(TARGET): $(OBJ_DIR)/y.tab.o $(OBJ_DIR)/matc.o 
	$(CC) -o $@ $^ $(LDFLAGS)

$(SRC_DIR)/y.tab.c: make_yacc

$(INCLUDE_DIR)/y.tab.h: make_yacc

$(OBJ_DIR)/y.tab.o: $(SRC_DIR)/y.tab.c $(INCLUDE_DIR)/y.tab.h
	$(CC) $(CFLAGS) -o $@ $<

$(OBJ_DIR)/matc.o: $(SRC_DIR)/matc.c $(INCLUDE_DIR)/y.tab.h
	$(CC) $(CFLAGS) -o $@ $<

$(SRC_DIR)/matc.c: $(SRC_DIR)/matc.lex
	flex -o $@ $<

make_yacc: $(SRC_DIR)/matc.y
	yacc -v --defines=$(INCLUDE_DIR)/y.tab.h -o $(SRC_DIR)/y.tab.c $<

mrproper: clean
	rm -rf bin

clean:
	rm -rf obj
	rm -f $(INCLUDE_DIR)/y.tab.h $(SRC_DIR)/.c

dist: matc_chavignat_laisne.tar.gz

matc_chavignat_laisne.tar.gz: clean $(SRC_DIR) $(INCLUDE_DIR) Makefile
	tar -acf $@ $^

dirs:
	mkdir -p $(BIN_DIR) $(OBJ_DIR)

.PHONY: make_yacc all dirs clean dist mrproper
