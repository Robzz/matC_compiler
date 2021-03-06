CC=gcc

BIN_DIR=bin
OBJ_DIR=obj
INCLUDE_DIR=include
SRC_DIR=src
TARGET=ubercompiler

CFLAGS+=-c -Wall --std=c11 -g -I$(INCLUDE_DIR)
LDFLAGS+=-lfl -ly

all: dirs $(BIN_DIR)/$(TARGET)

# Linkage
$(BIN_DIR)/$(TARGET): $(OBJ_DIR)/y.tab.o $(OBJ_DIR)/matc.o $(OBJ_DIR)/matrix.o $(OBJ_DIR)/types.o $(OBJ_DIR)/symbol_table.o $(OBJ_DIR)/quad.o
	$(CC) -o $@ $^ $(LDFLAGS)

# Compile C sources
$(OBJ_DIR)/y.tab.o: $(SRC_DIR)/y.tab.c $(INCLUDE_DIR)/y.tab.h $(INCLUDE_DIR)/debug.h
	$(CC) $(CFLAGS) -o $@ $<

$(OBJ_DIR)/matc.o: $(SRC_DIR)/matc.c $(INCLUDE_DIR)/y.tab.h $(INCLUDE_DIR)/debug.h
	$(CC) $(CFLAGS) -o $@ $<

$(OBJ_DIR)/matrix.o: $(SRC_DIR)/matrix.c
	$(CC) $(CFLAGS) -o $@ $<

$(OBJ_DIR)/types.o: $(SRC_DIR)/types.c $(INCLUDE_DIR)/types.h
	$(CC) $(CFLAGS) -o $@ $<

$(OBJ_DIR)/symbol_table.o: $(SRC_DIR)/symbol_table.c $(INCLUDE_DIR)/symbol_table.h $(INCLUDE_DIR)/types.h $(INCLUDE_DIR)/quad.h 
	$(CC) $(CFLAGS) -o $@ $<

$(OBJ_DIR)/quad.o: $(SRC_DIR)/quad.c $(INCLUDE_DIR)/quad.h $(INCLUDE_DIR)/symbol_table.h
	$(CC) $(CFLAGS) -o $@ $<

$(OBJ_DIR)/ast.o: $(SRC_DIR)/ast.c $(INCLUDE_DIR)/matrix.h
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

# Lexer test.y
test_lex: $(BIN_DIR)/lexer

$(BIN_DIR)/lexer: $(OBJ_DIR)/matc_test_lex.o $(OBJ_DIR)/y.tab_test_lex.o $(OBJ_DIR)/symbol_table.o $(OBJ_DIR)/types.o $(OBJ_DIR)/quad.o
	$(CC) $^ -o $@ $(LDFLAGS)

$(OBJ_DIR)/y.tab_test_lex.o: $(SRC_DIR)/y.tab.c $(INCLUDE_DIR)/y.tab.h $(INCLUDE_DIR)/debug.h
	$(CC) $(CFLAGS) -DDEBUG -DLEXER_TEST_BUILD -o $@ $<

$(OBJ_DIR)/matc_test_lex.o: $(SRC_DIR)/matc.c $(INCLUDE_DIR)/y.tab.h $(INCLUDE_DIR)/debug.h
	$(CC) $(CFLAGS) -DDEBUG -DLEXER_TEST_BUILD -o $@ $<

# Parser test
test_yacc: $(BIN_DIR)/parser

$(BIN_DIR)/parser: $(OBJ_DIR)/matc_test_yacc.o $(OBJ_DIR)/y.tab_test_yacc.o $(OBJ_DIR)/symbol_table.o $(OBJ_DIR)/types.o $(OBJ_DIR)/quad.o
	$(CC) $^ -o $@ $(LDFLAGS)

$(OBJ_DIR)/y.tab_test_yacc.o: $(SRC_DIR)/y.tab.c $(INCLUDE_DIR)/y.tab.h $(INCLUDE_DIR)/debug.h
	$(CC) $(CFLAGS) -DDEBUG -o $@ $<

$(OBJ_DIR)/matc_test_yacc.o: $(SRC_DIR)/matc.c $(INCLUDE_DIR)/y.tab.h $(INCLUDE_DIR)/debug.h
	$(CC) $(CFLAGS) -DDEBUG -o $@ $<

# Unit tests
unit:
	$(MAKE) -C tests/unit

# Clean targets
mrproper: clean
	rm -rf bin/*

clean:
	rm -rf obj/*
	rm -f $(INCLUDE_DIR)/y.tab.h $(SRC_DIR)/y.tab.c $(SRC_DIR)/matc.c $(SRC_DIR)/y.output

dist: clean matc_chavignat_laisne.tar.gz

matc_chavignat_laisne.tar.gz: $(SRC_DIR) $(INCLUDE_DIR) Makefile tests run_tests.sh
	tar -acf $@ $^

# Make directories in build tree
dirs: $(BIN_DIR) $(OBJ_DIR)

$(OBJ_DIR):
	mkdir -p $@

$(BIN_DIR):
	mkdir -p $@

.PHONY: make_yacc all dirs clean dist mrproper unit
