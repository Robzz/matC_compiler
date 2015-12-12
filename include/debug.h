#ifndef DEBUG_H
#define DEBUG_H

#ifdef DEBUG
    #define DBG(p) p
    #ifndef YYDEBUG
        #define YYDEBUG 1
    #endif
#endif

#define UNREACHABLE() (fprintf(stderr, "Reached unreachable code, bailing"), exit(1), 0)

#ifndef DBG
#define DBG(p)
#endif

#endif
