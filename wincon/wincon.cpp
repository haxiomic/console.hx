#define IMPLEMENT_API
#define NEKO_COMPATIBLE
#include <hx/CFFI.h>

#include <windows.h>

extern "C" {

    value enableVTT()
    {
    	bool enabled = false;
    	// Set output mode to handle virtual terminal sequences
    	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    	DWORD dwMode = 0;	
    	if (hOut != INVALID_HANDLE_VALUE && GetConsoleMode(hOut, &dwMode))
    	{
    		dwMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
    		enabled = SetConsoleMode(hOut, dwMode);
    	}

    	return alloc_int(enabled);
    }
    
}

DEFINE_PRIM( enableVTT, 0 );