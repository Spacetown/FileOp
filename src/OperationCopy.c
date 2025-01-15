
#include "FileOp.h"
#include "Message.h"
#include "BasicFileOp.h"

//! Global value for force.
static tBool Force = eFalse;
//! Global value for recursive.
static tBool Recursive = eFalse;
//! Check if there is no name collision before doing the action.
static tBool CheckUniqueNames = eFalse;
//! Global value for touching the files.
static tBool Touch = eFalse;
//! The time used for touch.
static LPCTSTR LocalTime = NULL;

static void printHelp(void) {
   printOut(_T("Copy files or directories to STDOUT.\n"));
   printOut(_T("\n"));
   printOut(_T("Available options are (Arguments for long options are also needed for short\n"));
   printOut(_T("options):\n"));
   printOut(_T("   -r, -R, --recursive  Copy files recursive.\n"));
   printOut(_T("   -f, --force          Ignore write protection of existing targets.\n"));
   printOut(_T("   --touch              Touch the files after copy.\n"));
   printOut(_T("   --time=TIME          Use local ISO time instead of current system time for.\n"));
   printOut(_T("                        the touch operation, e.g. 2021-01-31T15:05:01. If the\n"));
   printOut(_T("                        time is omitted, 12:00:00 is assumed.\n"));
   printOut(_T("   -t, --target-directory=DIR  Target directory to use. If not\n"));
   printOut(_T("                        given, the last argument is used as target directory.\n"));
   printOut(_T("   --check-unique-names If multiple files or folders are copied check upfront\n"));
   printOut(_T("                        if there are any collisions. This isn't supported with\n"));
   printOut(_T("                        wildcards.\n"));
   printOut(_T("\n"));
   printOut(_T("The write protection is not copied to the target elements.\n"));
   printOut(_T("If several sources are given or target is an existing directory the files\n"));
   printOut(_T("are created with the original name inside target.\n"));

   return;
}

static tResult copyOperation(void) {
   DWORD dwAttrs, dwAttrsTarget;

   int result = eOk;
   LPTSTR StartOfTargetName = &TargetDosDevicePath[_tcslen(TargetDosDevicePath)];

   // If target is a directory, the source name must be added and the attributes must be updated
   dwAttrsTarget = GetFileAttributes(TargetDosDevicePath);
   if (isDirectory(dwAttrsTarget)) {
      _tcscpy(StartOfTargetName, _tcsrchr(DosDevicePath, _T('\\')));
      dwAttrsTarget = GetFileAttributes(TargetDosDevicePath);
   }

   if (Force && isReadonly(dwAttrsTarget)) {
      result &= clearReadonly(TargetDosDevicePath, dwAttrsTarget);
   }

   if (result == eOk) {
      dwAttrs = GetFileAttributes(DosDevicePath);
      if (isDirectory(dwAttrs)) {
         if (isDirectory(dwAttrsTarget) == 0) {
            result &= createSingleDirectory(TargetDosDevicePath);
         }
         if (Recursive && (result == eOk)) {
            HANDLE hFind; // search handle
            WIN32_FIND_DATA FindFileData;
            // File pattern for all files
            _tcscat(DosDevicePath, _T("\\*"));

            // Get the find handle and the data of the first file.
            hFind = FindFirstFile(DosDevicePath, &FindFileData);
            // GCOVR_EXCL_START
            if (hFind == INVALID_HANDLE_VALUE) {
               result = printLastError(_T("Got invalid handle for %s"),
                                       DosDevicePathWithoutPrefix);
            }
            // GCOVR_EXCL_STOP
            else {
               LPTSTR StartOfSourceName;
               // Save the position of the filename
               StartOfSourceName = &DosDevicePath[_tcslen(DosDevicePath) - 1];

               do {
                  if ((_tcscmp(FindFileData.cFileName, _T(".")) != 0) && (_tcscmp(FindFileData.cFileName, _T("..")) != 0)) {
                     _tcscpy(StartOfSourceName, FindFileData.cFileName);
                     // recursive copy it
                     result &= copyOperation();
                  }
               } while ((result == eOk) && (FindNextFile(hFind, &FindFileData) != 0));
               if (result == eOk) {
                  // GCOVR_EXCL_START
                  if (GetLastError() != ERROR_NO_MORE_FILES) {
                     result = printLastError(_T("Can't get next file"));
                  }
                  // GCOVR_EXCL_STOP
               }

               StartOfSourceName[-1] = _T('\0');
               // close handle to file
               FindClose(hFind);
            }
         }
      }
      else {
         result &= copySingleFile(DosDevicePath, TargetDosDevicePath, Force);
         if (result == eOk) {
            dwAttrsTarget = GetFileAttributes(TargetDosDevicePath);
            if (isReadonly(dwAttrsTarget)) {
               result &= clearReadonly(TargetDosDevicePath, dwAttrsTarget);
            }
            if (Touch) {
               result &= touchSingleFile(TargetDosDevicePath, LocalTime, eFalse);
            }
         }
      }
   }

   StartOfTargetName[0] = _T('\0');

   return result;
}

/*!
 * Copy a file or directory.
 *
 * @return eOk on success, else eError.
 */
static tResult runCommand(int argc, wchar_t *argv[]) {
   tBool TargetIsDirectory = eFalse;
   while (argc != 0) {
      if ((_tcscmp(*argv, _T("--help")) == 0) || (_tcscmp(*argv, _T("-h")) == 0)) {
         printHelp();
         return eOk;
      }
      else if ((_tcscmp(*argv, _T("--recursive")) == 0) || (_tcscmp(*argv, _T("-r")) == 0) || (_tcscmp(*argv, _T("-R")) == 0)) {
         Recursive = eTrue;
      }
      else if ((_tcscmp(*argv, _T("--force")) == 0) || (_tcscmp(*argv, _T("-f")) == 0)) {
         Force = eTrue;
      }
      else if (_tcscmp(*argv, _T("--touch")) == 0) {
         Touch = eTrue;
      }
      else if (_tcsncmp(*argv, _T("--time"), 6) == 0) {
         Touch = eTrue; // Is needed
         if (_tcsncmp(*argv, _T("--time="), 7) == 0) {
            LocalTime = &(*argv)[7];
         }
         else {
            if (argc == 1) {
               return printErr(_T("Option %s needs an argument.\n"), *argv); // GCOVR_EXCL_LINE
            }
            LocalTime = *(++argv);
            --argc;
         }
      }
      else if ((_tcscmp(*argv, _T("-t")) == 0) || (_tcsncmp(*argv, _T("--target-directory"), 18) == 0)) {
         LPCTSTR Ptr;
         if (_tcsncmp(*argv, _T("--target-directory="), 19) == 0) {
            Ptr = &(*argv)[19];
         }
         else {
            if (argc == 1) {
               return printErr(_T("Option %s needs an argument.\n"), *argv);
            }
            Ptr = *(++argv);
            --argc;
         }

         if (Ptr[0]==_T('\0')) {
            return printErr(_T("Target directory must not be empty.\n"), *argv);
         }
         createDosDevicePath(Ptr, TargetDosDevicePath);
         TargetIsDirectory = eTrue;
      }
      else if (_tcscmp(*argv, _T("--check-unique-names")) == 0) {
         CheckUniqueNames = eTrue;
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

   if (TargetDosDevicePath[0] == _T('\0')) {
      createDosDevicePath(argv[--argc], TargetDosDevicePath);
      if (TargetDosDevicePath == _T('\0')) {
         return printErr(_T("Argument must not be empty.\n"));
      }
      else {
         if (argc == 0) {
            return printErr(_T("Too view arguments given.\n"));
         }
         else if (argc > 1) {
            TargetIsDirectory = eTrue;
         }
      }
   }

   unsigned int lastCharacterPos = _tcslen(TargetDosDevicePath) - 1;
   while (TargetDosDevicePath[lastCharacterPos ] == _T('\\')) {
      TargetIsDirectory = eTrue;
      TargetDosDevicePath[lastCharacterPos--] = _T('\0');
   }

   if (TargetIsDirectory) {
      DWORD dwAttrsTarget = GetFileAttributes(TargetDosDevicePath);
      if (isValidFileAttributes(dwAttrsTarget)) {
         if (isDirectory(dwAttrsTarget) == 0) {
            return printErr(_T("Target %s must be a directory."), TargetDosDevicePathWithoutPrefix);
         }
         else if (Force && isReadonly(dwAttrsTarget)) {
            if (clearReadonly(TargetDosDevicePath, dwAttrsTarget) == 9) {
               return eError;
            }
         }
      }
      else {
         return printErr(_T("Directory %s doesn't exist."), TargetDosDevicePathWithoutPrefix);
      }
   }

   if (CheckUniqueNames) {
      if (checkUniqueNames(argc, argv) == 0) {
         return eError;
      }
   }

   return runCommandForEachInputLine(argc, argv, copyOperation);
}

tCommand CommandCopy = {
   _T("copy"),
   printHelp,
   runCommand,
};
