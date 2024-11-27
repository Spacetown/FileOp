
#include "Message.h"
#include "BasicFileOp.h"

#include <stdarg.h>
#include <stdio.h>

//! The name of the program without path and extension.
TCHAR ProgramName[PROGRAM_NAME_BUFFER_SIZE];

//! The size of the error message buffer (must be greater than DOS_DEVICE_BUFFER_SIZE).
#define SIZE_MSG_BUFFER (2 * DOS_DEVICE_BUFFER_SIZE)
//! The buffer for the error message
TCHAR MsgBuffer[SIZE_MSG_BUFFER];

/*!
 * Print a message to STDERR.
 *
 * @param MsgTxt
 */
void printOut(LPCTSTR MsgTxt, ...) {
   va_list vl;
   va_start(vl, MsgTxt);
   _vftprintf(stdout, MsgTxt, vl);
   va_end(vl);
}

/*!
 * Print a error message to STDERR.
 *
 * @param MsgTxt The format string to print
 */
tBool printErr(LPCTSTR MsgTxt, ...) {
   va_list vl;
   va_start(vl, MsgTxt);
   _ftprintf(stderr, _T("%s: error: "), ProgramName);
   _vftprintf(stderr, MsgTxt, vl);
   va_end(vl);

   return eFalse;
}


/*!
 * Print last error if present.
 *
 * @param MsgTxt
 * @return eTrue if no error is set, else eFalse.
 */
tBool printLastError(LPCTSTR MsgTxt, ...) {
   DWORD dwLastError = GetLastError();
   if (dwLastError) {
      va_list vl;
      va_start(vl, MsgTxt);
      int MsgLength = _vsntprintf(MsgBuffer, SIZE_MSG_BUFFER, MsgTxt, vl);
      va_end(vl);
      MsgLength += _sntprintf(&MsgBuffer[MsgLength],
                              SIZE_MSG_BUFFER - MsgLength, _T(": "));
      if (FormatMessage(
         FORMAT_MESSAGE_FROM_SYSTEM,
         NULL, dwLastError, MAKELANGID(LANG_ENGLISH, SUBLANG_DEFAULT),
         (LPTSTR)&MsgBuffer[MsgLength],
         SIZE_MSG_BUFFER - MsgLength, NULL) == 0
      ) {
         _sntprintf(&MsgBuffer[MsgLength], SIZE_MSG_BUFFER - MsgLength, _T("GetLastError() = %d\n"), dwLastError);
      }
      return printErr(_T("%s"), MsgBuffer);
   }

   return eTrue;
}
