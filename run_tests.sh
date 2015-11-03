#!/bin/bash
TEST_LEX=0
TEST_YACC=0

parse_args() {
    if [[ -z $@ ]]; then
        echo 'You must specify one or more test targets.'
        echo 'Valid targets : yacc, lex'
        exit
    fi
    for arg in "$@"; do
        case "$arg" in
            "lex") TEST_LEX=1;;
            "yacc") TEST_YACC=1;;
            *) echo 'Error : unknown test target '"$arg"
        esac
    done
}

print_test_start() {
    echo "###### $1 ######"
}

parse_args "$@"

# TODO : doesn't work yet, need a shim
if [[ $TEST_LEX != 0 ]]; then
    print_test_start 'Testing lexer'
    if ! make test_lex 1&> /dev/null ; then
        echo "Error : cannot build lexer program"
        exit 1
    fi
    for f in ./tests/matc/* ; do
        echo ""
        ./bin/lexer < "$f" > /dev/null
    done
fi

if [[ $TEST_YACC != 0 ]]; then
    print_test_start "Testing parser" 
    make test_yacc > /dev/null
    for f in tests/matc/* ; do
        if ./bin/parser < "$f" > /dev/null ; then
            echo -e "Parsing test file $f: "'\e[32mSUCCESS\e[0m'
        else
            echo -e "Parsing test file $f: "'\e[31mFAILURE\e[0m'
        fi
    done
fi
