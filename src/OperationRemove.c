
#include "FileOp.h"
#include "Message.h"
#include "BasicFileOp.h"

//! Global value for force.
static tBool Force = eFalse;
//! Global value for recursive.
static tBool Recursive = eFalse;

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
               // GCOVR_EXCL_START
               if (hFind == INVALID_HANDLE_VALUE) {
                  result = printLastError(_T("Got invalid handle for %s"), DosDevicePathWithoutPrefix);
               }
               // GCOVR_EXCL_STOP
               else {
                  LPTSTR StartOfName;
                  // Save the position of the filename
                  StartOfName = &DosDevicePath[_tcslen(DosDevicePath) - 1];

                  do {
                     if ((_tcscmp(FindFileData.cFileName, _T(".")) != 0) && (_tcscmp(FindFileData.cFileName, _T("..")) != 0)) {
                        _tcscpy(StartOfName, FindFileData.cFileName);
                        // recursive remove it
                        result &= removeOperation();
                     }
                  } while ((result == eOk) && (FindNextFile(hFind, &FindFileData) != 0));
                  if (result == eOk) {
                     // GCOVR_EXCL_START
                     if (GetLastError() != ERROR_NO_MORE_FILES) {
                        result = printLastError(_T("Can't get next file"));
                     }
                     // GCOVR_EXCL_STOP
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
            DosDevicePathWithoutPrefix);
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

   if (argc == 0) {
      return printErr(_T("Too view arguments given.\n"));
   }

   return runCommandForEachInputLine(argc, argv, removeOperation);
}

tCommand CommandRemove = {
   _T("remove"),
   printHelp,
   runCommand,
};
