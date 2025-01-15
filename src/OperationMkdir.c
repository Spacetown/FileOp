
#include "BasicFileOp.h"
#include "FileOp.h"
#include "Message.h"

//! Global value for parents.
static tBool Parents = eFalse;

static void printHelp(void) {
   printOut(_T("Create directories.\n"));
   printOut(_T("\n"));
   printOut(_T("Available option is:\n"));
   printOut(_T("   -p, --parents        Create parent directories if needed, no error if\n"));
   printOut(_T("                        directory already exists.\n"));
   printOut(_T("\n"));
   printOut(_T("Examples:\n"));
   printOut(_T("- Create the folder --recursive in the current directory:\n"));
   printOut(_T("  %s mkdir -- --recursive\n"), ProgramName);

   return;
}

static tResult mkdirOperation(void) {
   HANDLE hFind; // search handle
   WIN32_FIND_DATA FindFileData;
   DWORD dwAttrs;

   dwAttrs = GetFileAttributes(DosDevicePath);
   if (isDirectory(dwAttrs)) {
      if (Parents == eFalse) {
         return printErr(_T("Directory %s already exists.\n"), getReadableFilename(DosDevicePath));
      }
      return eOk;
   } else if (isValidFileAttributes(dwAttrs)) {
      return printErr(_T("Not a directory %s.\n"), getReadableFilename(DosDevicePath));
   }

   if (Parents) {
      LPTSTR LastBackslash = _tcsrchr(DosDevicePath, _T('\\'));
      if (LastBackslash) {
         *LastBackslash = _T('\0');
         tResult result = mkdirOperation();
         *LastBackslash = _T('\\');
         if (result == eError) {
            return result;
         }
      }
   }

   return createSingleDirectory(DosDevicePath);
}

/*!
 * Create the given directory.
 *
 * If global variable Parents is set, also the parent directories are created.
 *
 * @return eOk on success, else eError.
 */
static tResult runCommand(int argc, wchar_t *argv[]) {
   while (argc != 0) {
      if ((_tcscmp(*argv, _T("--help")) == 0) || (_tcscmp(*argv, _T("-h")) == 0)) {
         printHelp();
         return eOk;
      } else if ((_tcscmp(*argv, _T("--parents")) == 0) || (_tcscmp(*argv, _T("-p")) == 0)) {
         Parents = 1;
      } else if ((_tcscmp(*argv, _T("--")) == 0)) {
         if (Debug) {
            printOut(_T("-- detected, stop option parsing.\n"));
         }
         ++argv;
         --argc;
         break;
      } else if ((_tcsncmp(*argv, _T("--"), 2) == 0) || (_tcsncmp(*argv, _T("-"), 1) == 0)) {
         printErr(_T("Unknown option %s, use option --help for more information.\n"), *argv);
         return eError;
      } else {
         break;
      }
      ++argv;
      --argc;
   }

   if (argc == 0) {
      return printErr(_T("Too view arguments given.\n"));
   }

   return runCommandForEachInputLine(argc, argv, mkdirOperation);
}

tCommand CommandMkdir = {
    _T("mkdir"),
    printHelp,
    runCommand,
};
