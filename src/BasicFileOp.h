#ifndef BASICFILEOP_INCLUDED
# define BASICFILEOP_INCLUDED

# include "Types.h"

 //! Size of the buffer for the DOS device path.
 #define DOS_DEVICE_BUFFER_SIZE (0xFFFF)
 //! The buffer for the source path if needed.
 extern TCHAR DosDevicePath[DOS_DEVICE_BUFFER_SIZE];
 //! The buffer for the target path.
 extern TCHAR TargetDosDevicePath[DOS_DEVICE_BUFFER_SIZE];

 extern void createDosDevicePath(LPCTSTR currentSourcePath, LPTSTR currentPath);
 extern tBool areAttrsValid(const DWORD dwAttrs);
 extern tBool isReadonly(const DWORD dwAttrs);
 extern tBool isReparsePoint(const DWORD dwAttrs);
 extern tBool isDirectory(const DWORD dwAttrs);
 extern tBool clearReadonly(LPCTSTR currentPath, const DWORD dwAttrs);
 extern tBool createSingleDirectory(LPCTSTR currentPath);
 extern tBool removeEmptyDirectory(LPCTSTR currentPath);
 extern tBool removeReparsePoint(LPCTSTR currentPath);
 extern tBool removeSingleFile(LPCTSTR currentPath);
 extern tBool copySingleFile(LPCTSTR currentSourcePath, LPCTSTR currentTargetPath, tBool force);
 extern tBool moveSingleFile(LPCTSTR currentSourcePath, LPCTSTR currentTargetPath, tBool force);
 extern tBool touchSingleFile(LPCTSTR currentPath, LPCTSTR localTime, tBool createIfMissing);
 extern tBool printFileToHandle(LPCTSTR currentPath, HANDLE *handle);

 extern tBool runCommandForEachInputLine(int argc, wchar_t *argv[], tBool (*command)( void ));
 extern tBool checkUniqueNames(int argc, wchar_t *argv[]);
#endif
