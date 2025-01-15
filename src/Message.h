
#ifndef MESSAGE_INCLUDED
#define MESSAGE_INCLUDED

#include "Types.h"

#define PROGRAM_NAME_BUFFER_SIZE (MAX_PATH)

extern TCHAR ProgramName[PROGRAM_NAME_BUFFER_SIZE];

extern void flushOutputAndExit(UINT uExitCode);
extern void printOut(LPCTSTR MsgTxt, ...);
extern tResult printErr(LPCTSTR MsgTxt, ...);
extern tResult printLastError(LPCTSTR MsgTxt, ...);

#endif
