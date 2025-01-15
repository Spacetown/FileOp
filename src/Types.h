
#ifndef TYPES_INCLUDES
#define TYPES_INCLUDES

#define _UNICODE // use Unicode (Microsoft C run-time API)
#define UNICODE  // use Unicode (Microsoft Windows API)
#define _WIN32_WINNT _WIN32_WINNT_WINXP

#include <tchar.h>
#include <wchar.h>
#include <windows.h>

//! Local result type.
typedef enum {
   //! The local false value.
   eError = 0,
   //! The local true value.
   eOk = 1
} tResult;

//! Local boolean type.
typedef enum {
   //! The local false value.
   eFalse = 0,
   //! The local true value.
   eTrue = 1
} tBool;

typedef struct {
   const TCHAR id[10];
   void (*printHelp)(void);
   tResult (*run)(int argc, wchar_t *argv[]);
} tCommand;

#endif
