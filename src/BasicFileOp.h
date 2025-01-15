#ifndef BASICFILEOP_INCLUDED
#define BASICFILEOP_INCLUDED

#include "Types.h"

//! Size of the buffer for the DOS device path.
#define DOS_DEVICE_BUFFER_SIZE (0xFFFF)
//! The buffer for the source path if needed.
extern TCHAR DosDevicePath[DOS_DEVICE_BUFFER_SIZE];
//! The buffer for the target path.
extern TCHAR TargetDosDevicePath[DOS_DEVICE_BUFFER_SIZE];

extern void createDosDevicePath(LPCTSTR currentSourcePath, LPTSTR currentPath);
extern LPCTSTR getReadableFilename(LPCTSTR currentPath);

extern tResult isValidFileAttributes(const DWORD dwAttrs);
extern tResult isReadonly(const DWORD dwAttrs);
extern tResult isReparsePoint(const DWORD dwAttrs);
extern tResult isDirectory(const DWORD dwAttrs);
extern tResult clearReadonly(LPCTSTR currentPath, const DWORD dwAttrs);
extern tResult createSingleDirectory(LPCTSTR currentPath);
extern tResult removeEmptyDirectory(LPCTSTR currentPath);
extern tResult removeReparsePoint(LPCTSTR currentPath);
extern tResult removeSingleFile(LPCTSTR currentPath);
extern tResult copySingleFile(LPCTSTR currentSourcePath, LPCTSTR currentTargetPath, tBool force);
extern tResult moveSingleFile(LPCTSTR currentSourcePath, LPCTSTR currentTargetPath, tBool force);
extern tResult touchSingleFile(LPCTSTR currentPath, tBool createIfMissing);
extern tResult printFileToHandle(LPCTSTR currentPath, HANDLE *handle);

extern tBool isTimeOption(wchar_t *argv);
extern tResult storeTimeValue(int *argc, wchar_t **argv[]);

extern tResult runCommandForEachInputLine(int argc, wchar_t *argv[], tResult (*command)(void));
extern tResult checkUniqueNames(int argc, wchar_t *argv[]);
#endif
