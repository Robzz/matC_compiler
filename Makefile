CC=gcc

BIN_DIR=bin
OBJ_DIR=obj
INCLUDE_DIR=include
SRC_DIR=src
TARGET=ubercompiler

CFLAGS+=-c -Wall -g -I$(INCLUDE_DIR)
LDFLAGS+=-lfl -ly

all: dirs $(BIN_DIR)/$(TARGET)

# Linkage
$(BIN_DIR)/$(TARGET): $(OBJ_DIR)/y.tab.o $(OBJ_DIR)/matc.o 
	$(CC) -o $@ $^ $(LDFLAGS)

# Compile C sources
$(OBJ_DIR)/y.tab.o: $(SRC_DIR)/y.tab.c $(INCLUDE_DIR)/y.tab.h
	$(CC) $(CFLAGS) -o $@ $<

$(OBJ_DIR)/matc.o: $(SRC_DIR)/matc.c $(INCLUDE_DIR)/y.tab.h
	$(CC) $(CFLAGS) -o $@ $<

# Compilation in debug mode


# Lex/Yacc targets
$(SRC_DIR)/y.tab.c: $(SRC_DIR)/matc.y
	yacc -v --defines=$(INCLUDE_DIR)/y.tab.h -o $(SRC_DIR)/y.tab.c $<

$(INCLUDE_DIR)/y.tab.h: $(SRC_DIR)/matc.y
	yacc -v --defines=$(INCLUDE_DIR)/y.tab.h -o $(SRC_DIR)/y.tab.c $<


$(SRC_DIR)/matc.c: $(SRC_DIR)/matc.lex
	flex -o $@ $<

# Testing targets
all_tests: test_lex test_yacc

# Lexer test
test_lex: $(BIN_DIR)/lexer

$(BIN_DIR)/lexer: $(OBJ_DIR)/matc_test.o $(OBJ_DIR)/y.tab_test.o
	$(CC) $^ -o $@ $(LDFLAGS)

$(OBJ_DIR)/y.tab_test.o: $(SRC_DIR)/y.tab.c $(INCLUDE_DIR)/y.tab.h
	$(CC) $(CFLAGS) -DDEBUG -DLEXER_TEST_BUILD -o $@ $<

$(OBJ_DIR)/matc_test.o: $(SRC_DIR)/matc.c $(INCLUDE_DIR)/y.tab.h
	$(CC) $(CFLAGS) -DDEBUG -DLEXER_TEST_BUILD -o $@ $<

# Parser test
test_yacc: $(BIN_DIR)/parser

$(BIN_DIR)/parser: $(OBJ_DIR)/matc.o $(OBJ_DIR)/y.tab.o
	$(CC) $^ -o $@ $(LDFLAGS)

# Clean targets
mrproper: clean
	rm -rf bin/*

clean:
	rm -rf obj/*
	rm -f $(INCLUDE_DIR)/y.tab.h $(SRC_DIR)/y.tab.c $(SRC_DIR)/matc.c

dist: matc_chavignat_laisne.tar.gz

matc_chavignat_laisne.tar.gz: clean $(SRC_DIR) $(INCLUDE_DIR) Makefile
	tar -acf $@ $^

# Make directories in build tree
dirs: $(BIN_DIR) $(OBJ_DIR)

$(OBJ_DIR):
	mkdir -p $@

$(BIN_DIR):
	mkdir -p $@

.PHONY: make_yacc all dirs clean dist mrproper
