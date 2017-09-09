#define IMPLEMENT_API
#define NEKO_COMPATIBLE
#include <hx/CFFI.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

extern "C" {

    value sum(value a, value b)
    {
        if( !val_is_int(a) || !val_is_int(b) ) return val_null;
        return alloc_int(val_int(a) + val_int(b));
    }
    
}

DEFINE_PRIM( sum, 2 );