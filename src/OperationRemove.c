
#include "FileOp.h"
#include "Message.h"
#include "BasicFileOp.h"

//! Global value for force.
static tResult Force = eError;
//! Global value for recursive.
static tResult Recursive = eError;

static void printHelp(void) {
   printOut(_T("Remove files or directories.\n"));
   printOut(_T("\n"));
   printOut(_T("Available options are:\n"));
   printOut(_T("   -r, -R, --recursive  Remove files recursive.\n"));
   printOut(_T("   -f, --force          Ignore write protection.\n"));
   printOut(_T("\n"));
   printOut(_T("Examples:\n"));
   printOut(_T("- Delete two folders recursive, ignoring write protection:\n"));
   printOut(_T("  %s remove --recursive --force c:\\temp\\subFolder c:\\temp\\aFile.txt\n"), ProgramName);

   return;
}

static tResult removeOperation(void) {
   int result = eOk;
   DWORD dwAttrs = GetFileAttributes(DosDevicePath);
   if (isValidFileAttributes(dwAttrs)) {
      if (Force && isReadonly(dwAttrs)) {
         result &= clearReadonly(DosDevicePath, dwAttrs);
      }

      if (result == eOk) {
         if (isReparsePoint(dwAttrs)) {
            result &= removeReparsePoint(DosDevicePath);
         }
         else if (isDirectory(dwAttrs)) {
            if (Recursive) {
               HANDLE hFind; // search handle
               WIN32_FIND_DATA FindFileData;
               // File pattern for all files
               _tcscat(DosDevicePath, _T("\\*"));

               // Get the find handle and the data of the first file.
               hFind = FindFirstFile(DosDevicePath, &FindFileData);
               if (hFind == INVALID_HANDLE_VALUE) {
                  result = printLastError(_T("Got invalid handle for %s"), DosDevicePathWithoutPrefix);
               }
               else {
                  LPTSTR StartOfName;
                  // Save the position of the filename
                  StartOfName = &DosDevicePath[_tcslen(DosDevicePath) - 1];

                  do {
                     if ((_tcscmp(FindFileData.cFileName, _T(".")) != 0) && (_tcscmp(FindFileData.cFileName, _T("..")) != 0)) {
                        _tcscpy(StartOfName, FindFileData.cFileName);
                        // recursive copy it
                        result &= removeOperation();
                     }
                  } while ((result == eOk) && (FindNextFile(hFind, &FindFileData) != 0));
                  if (result == eOk) {
                     // We are at the end of the list
                     if (GetLastError() != ERROR_NO_MORE_FILES) {
                        result = printLastError(_T("Can't get next file"));
                     }
                  }

                  StartOfName[-1] = _T('\0');
                  // close handle to file
                  FindClose(hFind);
               }
            }

            if (result == eOk) {
               // Remove the empty directory
               result &= removeEmptyDirectory(DosDevicePath);
            }
         }
         else {
            result &= removeSingleFile(DosDevicePath);
         }
      }
   }
   else if (Debug) {
      printOut(_T("Skip %s because it doesn't exist.\n"),
            DosDevicePath);
   }

   return result;
}

/*!
 * Remove a file or directory.
 *
 * If global variable Recurse is set all sub directories are also removed.
 * If global variable Force is set the write protection is removed before deleting the elements.
 *
 * @return eOk on success, else eError.
 */
static tResult runCommand(int argc, wchar_t *argv[]) {
   while (argc != 0) {
      if ((_tcscmp(*argv, _T("--help")) == 0) || (_tcscmp(*argv, _T("-h")) == 0)) {
         printHelp();
         return eOk;
      }
      else if ((_tcscmp(*argv, _T("--force")) == 0) || (_tcscmp(*argv, _T("-f")) == 0)) {
         Force = 1;
      }
      else if ((_tcscmp(*argv, _T("--recursive")) == 0) || (_tcscmp(*argv, _T("-r")) == 0) || (_tcscmp(*argv, _T("-R")) == 0)) {
         Recursive = 1;
      }
      else if ((_tcscmp(*argv, _T("--")) == 0)) {
         if (Debug) {
            printOut(_T("-- detected, stop option parsing.\n"));
         }
         ++argv;
         --argc;
         break;
      }
      else if ((_tcsncmp(*argv, _T("--"), 2) == 0) || (_tcsncmp(*argv, _T("-"), 1) == 0)) {
         return printErr(_T("Unknown option %s, use option --help for more information.\n"), *argv);
      }
      else {
         break;
      }
      ++argv;
      --argc;
   }

   int result = eOk;
   if (argc == 0) {
      result &= printErr(_T("Too view arguments given.\n"));
   }
   else {
      result &= runCommandForEachInputLine(argc, argv, removeOperation);
   }

   return result;
}

tCommand CommandRemove = {
   _T("remove"),
   printHelp,
   runCommand,
};