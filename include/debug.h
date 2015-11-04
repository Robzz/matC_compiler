#ifndef DEBUG_H
#define DEBUG_H

#ifdef DEBUG
#define DBG(p) p
#ifndef YYDEBUG
#define YYDEBUG 1
#endif
#endif

#ifndef DBG
#define DBG(p)
#endif

#endif
