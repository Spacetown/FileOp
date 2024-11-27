
#ifndef MESSAGE_INCLUDED
# define MESSAGE_INCLUDED

# include "Types.h"

 #define PROGRAM_NAME_BUFFER_SIZE (MAX_PATH)

 extern TCHAR ProgramName[PROGRAM_NAME_BUFFER_SIZE];

 extern void flushOutputAndExit(UINT uExitCode);
 extern void printOut(LPCTSTR MsgTxt, ...);
 extern tBool printErr(LPCTSTR MsgTxt, ...);
 extern tBool printLastError(LPCTSTR MsgTxt, ...);

#endif
