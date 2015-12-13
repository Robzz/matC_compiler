#ifndef DEBUG_H
#define DEBUG_H

#ifdef DEBUG
    // Expands to p if DEBUG is set, or to nothing otherwise.
    #define DBG(p) p
    #ifndef YYDEBUG
        #define YYDEBUG 1
    #endif
#endif

// Mark code as unreachable, crash on execution if it is reached
#define UNREACHABLE() (fprintf(stderr, "Reached unreachable code, bailing"), exit(1), 0)

#ifndef DBG
#define DBG(p)
#endif

#endif
