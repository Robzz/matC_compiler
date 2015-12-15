#!/bin/zsh
local TEST_LEX=0
local TEST_YACC=0
local TEST_UNIT=0
local TEST_COMPILE=0
local SUCCESS=1

parse_args() {
    if [[ -z $@ ]]; then
        echo 'You must specify one or more test targets.'
        echo 'Valid targets : yacc, lex, unit, compile-test, all'
        exit
    fi
    for arg in "$@"; do
        case "$arg" in
            'lex') TEST_LEX=1;;
            'yacc') TEST_YACC=1;;
            'unit') TEST_UNIT=1;;
            'compile-test') TEST_COMPILE=1;;
            'all') TEST_LEX=1; TEST_YACC=1; TEST_UNIT=1; TEST_COMPILE=1;;
            *) echo 'Error : unknown test target '"$arg"; exit 1;;
        esac
    done
}

print_test_start() {
    echo '###### '"$1"' ######'
}

parse_args "$@"

if [[ $TEST_LEX != 0 ]]; then
    print_test_start 'Testing lexer'
    make test_lex 1&> /dev/null
    if [[ ! $? -eq 0 ]] ; then
        echo 'Error : cannot build lexer program'
        exit 1
    fi
    for f in ./tests/matc/* ; do
        if ./bin/lexer < "$f" 1&> /dev/null ; then
            echo -e 'Lexing test file '"$f"': \e[32mSUCCESS\e[0m'
        else
            echo -e 'Lexing test file '"$f"': \e[31mFAILURE\e[0m'
            SUCCESS=0
        fi
    done
fi

if [[ $TEST_YACC != 0 ]]; then
    print_test_start 'Testing parser'
    make test_yacc 1&> /dev/null
    if [[ ! $? -eq 0 ]] ; then
        echo 'Error : cannot build parser program'
        exit 1
    fi
    for f in tests/matc/* ; do
        if ./bin/parser < "$f" 1&> /dev/null ; then
            echo -e 'Parsing test file '"$f"': \e[32mSUCCESS\e[0m'
        else
            echo -e 'Parsing test file '"$f"': \e[31mFAILURE\e[0m'
            SUCCESS=0
        fi
    done
fi

if [[ $TEST_COMPILE != 0 ]]; then
    print_test_start 'Testing compiler'
    make 1&> /dev/null
    if [[ ! $? -eq 0 ]] ; then
        echo 'Error : cannot build compiler'
        exit 1
    fi
    for f in tests/matc/* ; do
        if ./bin/ubercompiler < "$f" 1&> /dev/null ; then
            echo -e 'Compiling test file '"$f"': \e[32mSUCCESS\e[0m'
        else
            echo -e 'Compiling test file '"$f"': \e[31mFAILURE\e[0m'
            SUCCESS=0
        fi
    done
fi

if [[ $TEST_UNIT != 0 ]]; then
    print_test_start 'Running unit tests'
    make 1&> /dev/null
    if [[ ! $? -eq 0 ]]; then
        echo 'Error : cannot build compiler'
        exit 1
    fi
    make unit 1&> /dev/null
    if [[ ! $? -eq 0 ]]; then
        echo 'Error : cannot build unit tests'
        exit 1
    fi
    for f in tests/unit/*(x); do
        if ./$f 1&> /dev/null; then
            echo -e 'Unit test '"$f"': \e[32mSUCCESS\e[0m'
        else
            echo -e 'Unit test '"$f"': \e[31mFAILURE\e[0m'
            SUCCESS=0
        fi
    done
fi

if [[ ! $SUCCESS -eq 1 ]]; then
    exit 1
fi
