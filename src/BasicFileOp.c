
#include "FileOp.h"
#include "Message.h"
#include "BasicFileOp.h"

#include <winioctl.h>
#include <io.h>
#include <fcntl.h>
#include <stdlib.h>
#include <shellapi.h>

#include <sys/stat.h>

//! The prefix for a DOS device path
LPCTSTR DosDevicePrefix = _T("\\\\?\\");
const int DOS_DEVICE_PREFIX_LENGTH = sizeof(DosDevicePrefix) / sizeof(TCHAR);

//! The buffer for the source path if needed.
TCHAR DosDevicePath[DOS_DEVICE_BUFFER_SIZE] = _T("");
//! The pointer to the buffer for the source path if needed after the prefix.
TCHAR * const DosDevicePathWithoutPrefix = &DosDevicePath[DOS_DEVICE_PREFIX_LENGTH];
//! The buffer for the target path.
TCHAR TargetDosDevicePath[DOS_DEVICE_BUFFER_SIZE] = _T("");
//! The pointer to the buffer for the target path.
TCHAR * const TargetDosDevicePathWithoutPrefix = &TargetDosDevicePath[DOS_DEVICE_PREFIX_LENGTH];
//! The buffer for the current response file.
TCHAR DosDevicePathResponseFile[DOS_DEVICE_BUFFER_SIZE] = _T("");

TCHAR **KnownFilenames = NULL;

//! Size ot the read buffer.
#define SIZE_IO_BUFFER (0x1FFFF)
//! The buffer to read a file.
char IoBuffer[SIZE_IO_BUFFER];
//! The buffer to read a file.
TCHAR IoBufferWideCharacter[SIZE_IO_BUFFER];

//! The time format for touch
static const TCHAR TIME_FORMAT[] = _T("%4d-%02d-%02dT%02d:%02d:%02d");

/*!
 * Create the used DOS device path (starting with \\?\). Path is normalized and changed to an absolute path..
 *
 * @param currentSourcePath The path to normalize.
 * @param currentPath       The target buffer for the DOS device path.
 */
void createDosDevicePath(LPCTSTR currentSourcePath, LPTSTR currentPath) {
   static TCHAR TempSourcePath[DOS_DEVICE_BUFFER_SIZE];

   if (*currentSourcePath == _T('\0')) {
      *currentPath = _T('\0');
   }
   else {
      DWORD Size = GetFullPathName(currentSourcePath, DOS_DEVICE_BUFFER_SIZE, TempSourcePath, NULL);
      if (Size == 0L) {
         printLastError(_T("Could not get full name of %s"), &currentSourcePath[DOS_DEVICE_PREFIX_LENGTH]);
         flushOutputAndExit(EXIT_FAILURE);
      }
      else if (Size > DOS_DEVICE_BUFFER_SIZE) {
         printLastError(_T("Could not get full name of %s. Buffer is to small, needed are %d characters."),
                        &currentSourcePath[DOS_DEVICE_PREFIX_LENGTH], Size);
         flushOutputAndExit(EXIT_FAILURE);
      }
      LPTSTR StartOfPath = TempSourcePath;
      _tcscpy(currentPath, DosDevicePrefix);
      // Create the used DOS device path (starting with \\?\).
      if (_tcsncmp(StartOfPath, DosDevicePrefix, 4) == 0) {
         StartOfPath += 4;
      }
      else {
         if (_tcsncmp(StartOfPath, _T("\\\\"), 2) == 0) {
            _tcscat(currentPath, _T("UNC"));
            ++StartOfPath;
            // \\?\UNC\server\share
         }
      }

      _tcscat(currentPath, StartOfPath);
   }

   return;
}

/*!
 * Check if the attributes are valid
 *
 * @param dwAttrs The attributes to check.
 * @return eOk if file attributes are valid
 */
tResult isValidFileAttributes(const DWORD dwAttrs) {
   return (dwAttrs == INVALID_FILE_ATTRIBUTES) ? eError : eOk;
}

/*!
 * Check if readonly attribute is set.
 *
 * @param dwAttrs The attributes to check.
 * @return eOk if readonly attribute is set, else eError.
 */
tResult isReadonly(const DWORD dwAttrs) {
   return (isValidFileAttributes(dwAttrs) && ((dwAttrs & FILE_ATTRIBUTE_READONLY) != 0)) ? eOk : eError;
}

/*!
 * Check if it is a reparse point
 *
 * @param dwAttrs The attributes to check.
 * @return eOk if element is a reparse point, else eError.
 */
tResult isReparsePoint(const DWORD dwAttrs) {
   return (isValidFileAttributes(dwAttrs) && ((dwAttrs & FILE_ATTRIBUTE_REPARSE_POINT) != 0)) ? eOk : eError;
}

/*!
 * Check if directory attribute is set.
 *
 * @param dwAttrs The attributes to check.
 * @return eOk if directory attribute is set, else eError.
 */
tResult isDirectory(const DWORD dwAttrs) {
   return (isValidFileAttributes(dwAttrs) && ((dwAttrs & FILE_ATTRIBUTE_DIRECTORY) != 0)) ? eOk : eError;
}

/*!
 * Clear the readonly attribute.
 *
 * @param currentPath The file for which the attribute are changed.
 * @param dwAttrs     The current attribute value.
 * @return eOk on success, else eError.
 */
tResult clearReadonly(LPCTSTR currentPath, const DWORD dwAttrs) {
   if (Debug) {
      printOut(_T("Clear readonly flag of element %s\n"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }
   if (SetFileAttributes(currentPath, dwAttrs & (~FILE_ATTRIBUTE_READONLY)) == 0) {
      return printLastError(_T("Can't clear readonly flag of element %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }
   return eOk;
}

/*!
 * Create a single directory.
 *
 * @param currentPath The directory to create.
 * @return eOk on success, else eError.
 */
tResult createSingleDirectory(LPCTSTR currentPath) {
   if (Debug) {
      printOut(_T("Create directory %s\n"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }
   if (CreateDirectory(currentPath, NULL) == 0) {
      return printLastError(_T("Can't create directory %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }

   return eOk;
}

/*!
 * Delete a empty directory directory.
 *
 * @param currentPath The directory to remove.
 * @return eOk on success, else eError.
 */
tResult removeEmptyDirectory(LPCTSTR currentPath) {
   if (Debug) {
      printOut(_T("Remove directory %s\n"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }
   if (RemoveDirectory(currentPath) == 0) {
      return printLastError(_T("Can't remove directory %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }

   return eOk;
}

/*!
 * Delete a reparse point.
 *
 * @param currentPath The reparse point to remove.
 * @return eOk on success, else eError.
 */
tResult removeReparsePoint(LPCTSTR currentPath) {
   if (Debug) {
      printOut(_T("Remove reparse point %s\n"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }

   HANDLE Handle = CreateFile(currentPath, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING,
                              FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT, NULL);
   if (Handle == INVALID_HANDLE_VALUE) {
      return printLastError(_T("Can't get handle to %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }

   REPARSE_GUID_DATA_BUFFER ReparseDataBuffer = {0};
   ReparseDataBuffer.ReparseTag = IO_REPARSE_TAG_MOUNT_POINT;

   DWORD BytesReturned = 0;
   if (DeviceIoControl(
      Handle, FSCTL_DELETE_REPARSE_POINT, &ReparseDataBuffer, sizeof(ReparseDataBuffer), NULL, 0,
      &BytesReturned, 0) == 0
   ) {
      printLastError(_T("Can't remove reparse point %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
      if (CloseHandle(Handle) == 0) {
         printLastError(_T("Can't close handle to %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
      }
      return eError;
   }
   if (CloseHandle(Handle) == 0) {
      return printLastError(_T("Can't close handle to %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }
   return removeEmptyDirectory(currentPath);
}

/*!
 * Delete a single file.
 *
 * @param currentPath The file to remove.
 * @return eOk on success, else eError.
 */
tResult removeSingleFile(LPCTSTR currentPath) {
   if (Debug) {
      printOut(_T("Remove file %s\n"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }
   if (DeleteFile(currentPath) == 0) {
      return printLastError(_T("Can't remove file %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }

   return eOk;
}

/*!
 * Copy a single file.
 *
 * @param currentSourcePath The file to copy.
 * @param currentTargetPath The target file.
 * @param force             Overwrite existing file.
 *
 * @return eOk on success, else eError.
 */
tResult copySingleFile(LPCTSTR currentSourcePath, LPCTSTR currentTargetPath, tResult force) {
   if (Debug) {
      printOut(
         _T("Copy file %s to %s\n"), &currentSourcePath[DOS_DEVICE_PREFIX_LENGTH],
         &currentTargetPath[DOS_DEVICE_PREFIX_LENGTH]
      );
   }
   if (CopyFile(currentSourcePath, currentTargetPath, force ? 0 : 1) == 0) {
      return printLastError(
         _T("Can't copy file %s to %s"), &currentSourcePath[DOS_DEVICE_PREFIX_LENGTH],
         &currentTargetPath[DOS_DEVICE_PREFIX_LENGTH]
      );
   }

   return eOk;
}

/*!
 * Move a single file.
 *
 * @param currentSourcePath The file to copy.
 * @param currentTargetPath The target file.
 * @param force             Overwrite existing file.
 *
 * @return eOk on success, else eError.
 */
tResult moveSingleFile(LPCTSTR currentSourcePath, LPCTSTR currentTargetPath, tResult force) {
   if (Debug) {
      printOut(
         _T("Move file %s to %s\n"), &currentSourcePath[DOS_DEVICE_PREFIX_LENGTH],
         &currentTargetPath[DOS_DEVICE_PREFIX_LENGTH]
      );
   }
   if (MoveFileEx(currentSourcePath, currentTargetPath, MOVEFILE_COPY_ALLOWED | MOVEFILE_REPLACE_EXISTING | (force ? MOVEFILE_REPLACE_EXISTING : 0)) == 0) {
      return printLastError(
         _T("Can't move file %s to %s"), &currentSourcePath[DOS_DEVICE_PREFIX_LENGTH],
         &currentTargetPath[DOS_DEVICE_PREFIX_LENGTH]
      );
   }

   return eOk;
}

/*!
 * Touch a file.
 *
 * @param currentPath     The file to touch.
 * @param localTime       The time to use, NULL to use current time.
 * @param createIfMissing If eOk, the file is created if it doesn't exist.
 *
 * @return eOk if the file was successfully touched, else eError.
 */
tResult touchSingleFile(LPCTSTR currentPath, LPCTSTR localTime, tResult createIfMissing) {
   HANDLE hFile;

   if (Debug) {
      printOut(_T("Touch file %s\n"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }
   hFile = CreateFile(currentPath, FILE_WRITE_ATTRIBUTES , 0, NULL, createIfMissing ? OPEN_ALWAYS : OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
   if (hFile == INVALID_HANDLE_VALUE) {
      return printLastError(_T("Can't get handle to %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }
   else {
      static LPFILETIME pft = NULL;
      // Only initialize time on first call
      if (pft == NULL) {
         static FILETIME ft;
         static SYSTEMTIME st;
         pft = &ft;
         if (localTime == NULL) {
            GetSystemTime(&st);              // Gets the current system time
         }
         else {
            static SYSTEMTIME lt;
            int count = swscanf(
               localTime,
               TIME_FORMAT,
               &lt.wYear, &lt.wMonth, &lt.wDay, &lt.wHour, &lt.wMinute, &lt.wSecond
            );
            if (count < 3) {
               return printErr(_T("Wrong format for time %s, expected %s.\n"), localTime, TIME_FORMAT);
            }
            if (count == 3) {
               lt.wHour = 12;
               lt.wMinute = 0;
               lt.wSecond = 0;
            }
            else if (count != 6) {
               return printErr(_T("Wrong format for time %s, expected %s.\n"), localTime, TIME_FORMAT);
            }
            lt.wMilliseconds = 0;
            if (TzSpecificLocalTimeToSystemTime((TIME_ZONE_INFORMATION*)NULL, &lt, &st) == 0) {
               return printLastError(_T("Can't convert local time %s to system time"), localTime);
            }
         }
         // Converts the current system time to file time format
         if (SystemTimeToFileTime(&st, &ft) == 0) {
            return printLastError(_T("Can't convert system time to file time"));
         }
      }
      if (SetFileTime(hFile, (LPFILETIME) NULL, pft, pft) == 0) {
         return printLastError(_T("Can't set access and write time of %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
      }
      if (CloseHandle(hFile) == 0) {
         return printLastError(_T("Can't close handle to %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
      }
   }

   return eOk;
}

/*!
 * Open the given path for reading.
 *
 * @param currentPath The file to open.
 * @param handle      A pointer to write the opened handle to.
 *
 * @return eOk if the file was opened successfully, also setting argument handle, else eError.
 */
tResult openFile(LPCTSTR currentPath, HANDLE *handle) {
   IoBuffer[0] = '\0';

   *handle = CreateFile(currentPath, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
   if (*handle == INVALID_HANDLE_VALUE) {
      return printLastError(_T("Can't get handle to %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }

   return eOk;
}


/*!
 * Close the handle to the file.
 *
 * @param currentPath The file to close (needed for error message).
 * @param handle      The handle to close.
 *
 * @return The handle or INVALID_HANDLE_VALUE if open wasn't successful.
 */
tResult closeFile(LPCTSTR currentPath, HANDLE *handle) {
   if (CloseHandle(handle) == 0) {
      return printLastError(_T("Can't close handle to %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
   }

   return eOk;
}

/*!
 * Run a command for each argument. If the argument starts with a @ the
 * file is opened and read line by line, running the given command for each line.
 *
 * @param argc    The number of arguments.
 * @param argv    The arguments.
 * @param command The pointer to the function which shall be executed for each file.
 *
 * @return eOk on success, else eError
 */
tResult runCommandForEachInputLine(int argc, wchar_t *argv[], tResult (*command)(void)) {
   tResult result = eOk;
   while ((result == eOk) && (argc-- != 0)) {
      TCHAR *filename = *(argv++);
      if (filename[0] == _T('@')) {
         createDosDevicePath(&filename[1], DosDevicePathResponseFile);
         HANDLE InHandle;
         result &= openFile(DosDevicePathResponseFile, &InHandle);
         if (result == eOk) {
            DWORD BytesRead = 0;
            *IoBuffer = '\0';
            *IoBufferWideCharacter = _T('\0');
            do {
               // Start behind the current content
               DWORD Offset = _tcslen(IoBufferWideCharacter);
               if (FALSE == ReadFile(InHandle, IoBuffer, SIZE_IO_BUFFER - Offset - 1, &BytesRead, NULL)) {
                  result &= printLastError(_T("Error reading file %s"), DosDevicePathResponseFile);
               }
               if (BytesRead != 0) {
                  // Add a \0 after the read content
                  IoBuffer[BytesRead] = '\0';
                  // ...and convert it.
                  if (MultiByteToWideChar(CP_ACP, 0, IoBuffer, -1, &IoBufferWideCharacter[Offset], SIZE_IO_BUFFER - Offset) == 0) {
                     result &= printLastError(_T("Error converting file content of %s"), DosDevicePathResponseFile);
                  }
                  else {
                     LPTSTR PtrStart = IoBufferWideCharacter;
                     LPTSTR PtrEnd   = &IoBufferWideCharacter[BytesRead + Offset];
                     do {
                        LPTSTR PtrEndOfLine = _tcschr(PtrStart, _T('\n'));
                        if (PtrEndOfLine != NULL) {
                           LPTSTR PtrStartNextLine = &PtrEndOfLine[1];
                           *PtrEndOfLine = _T('\0');
                           do {
                              --PtrEndOfLine;
                              if ((*PtrEndOfLine == _T('\r')) || (*PtrEndOfLine == _T(' '))) {
                                 *PtrEndOfLine = _T('\0');
                              }
                           } while ((*PtrEndOfLine == _T('\0')) && (PtrEndOfLine > PtrStart));
                           // If line isn't empty
                           if (PtrEndOfLine > PtrStart) {
                              createDosDevicePath(PtrStart, DosDevicePath);
                              result &= command();
                           }
                           // Clear this line (needed if last char in buffer is a linebreak
                           *PtrStart = _T('\0');
                           PtrStart = PtrStartNextLine;
                        }
                        else {
                           // Move the rest of the string to the start of the buffer
                           DWORD Index = _tcslen(PtrStart) + 1;
                           for (; Index > 0; --Index) {
                              IoBufferWideCharacter[Index] = PtrStart[Index];
                           }
                           IoBufferWideCharacter[0] = PtrStart[0];
                           PtrStart = PtrEnd;
                        }
                     } while (PtrStart < PtrEnd);
                  }
               }
            } while ((result == eOk) && (BytesRead != 0));
            result &= closeFile(DosDevicePathResponseFile, InHandle);
         }
      }
      else {
         createDosDevicePath(filename, DosDevicePath);
         if (DosDevicePath[0] == _T('\0')) {
            result &= printErr(_T("Argument must not be empty.\n"));
         }
         else {
            result &= command();
         }
      }
   }

   return result;
}

/*!
 * Check if the last part of the input is unique.
 *
 * @return eOk if everything is unique, else eError
 */
tResult checkUniqueName(void) {
   tResult result = eOk;

   // Get the filename and make it lowercase
   LPTSTR PtrFilenameStart = _tcsrchr(DosDevicePath, _T('\\')) + 1;
   (void)_tcslwr(PtrFilenameStart);
   TCHAR **CurrentFilename = KnownFilenames;
   while(*CurrentFilename != NULL) {
      if (_tcscmp(PtrFilenameStart, *CurrentFilename) == 0) {
         result &= printErr(_T("File in source list will overwrite each other: %s"), PtrFilenameStart);
         break;
      }
      ++CurrentFilename;
   }
   if (result == eOk) {
      *CurrentFilename = malloc(_tcslen(PtrFilenameStart) * sizeof(TCHAR*));
      if (*CurrentFilename == NULL) {
         result &= printLastError(_T("Can't allocate memory for current filenames"));
      }
      _tcscpy(*CurrentFilename, PtrFilenameStart);
   }

   return result;
}

tResult checkUniqueNames(int argc, wchar_t *argv[]) {
   tResult result = eOk;
   size_t ListSize = (argc + 1) * sizeof(TCHAR*); // +1 to have a trailing NULL pointer (needed for freeing the space)

   KnownFilenames = malloc(ListSize);
   if (KnownFilenames == NULL) {
      result &= printLastError(_T("Can't allocate memory for list of filenames"));
   }
   else {
      memset(KnownFilenames, 0, ListSize);

      result &= runCommandForEachInputLine(argc, argv, checkUniqueName);

      TCHAR **CurrentFilename = KnownFilenames;
      while (*CurrentFilename != NULL) {
         free(*CurrentFilename);
         if (errno != 0) {
            result &= printLastError(_T("Can't free memory of filename"));
         }
         ++CurrentFilename;
      }
      free(KnownFilenames);
      if (errno != 0) {
         result &= printLastError(_T("Can't free memory of list of filenames"));
      }
   }

   return result;
}

/*!
 * Print a file to a given handle.
 *
 * @param outHandle The handle to which the file is printed.
 *
 * @return eOk on success, else eError.
 */
tResult printFileToHandle(LPCTSTR currentPath, HANDLE *outHandle) {
   tResult result = eOk;

   HANDLE InHandle;
   result &= openFile(currentPath, &InHandle);
   if (result == eOk) {
      DWORD BytesRead = 0;
      do {
         if (FALSE == ReadFile(InHandle, IoBuffer, SIZE_IO_BUFFER, &BytesRead, NULL)) {
            result &= printLastError(_T("Error reading file %s"), &currentPath[DOS_DEVICE_PREFIX_LENGTH]);
         }
         if (BytesRead != 0) {
            DWORD BytesWritten = 0;
            if (WriteFile(outHandle, IoBuffer, BytesRead, &BytesWritten, NULL) == 0) {
               result &= printLastError(_T("Error writing to output handle"));
            }
         }
      } while ((result == eOk) && (BytesRead != 0));
      result &= closeFile(currentPath, InHandle);
   }

   return result;
}