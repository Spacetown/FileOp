
#include "FileOp.h"
#include "Message.h"
#include "BasicFileOp.h"

//! Global value for force.
static tBool Force = eFalse;
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
   printOut(_T("- Create the folder --force and --recursive in the current directory:\n"));
   printOut(_T("  %s mkdir -- --force --recursive\n"), ProgramName);

   return;
}

static tBool mkdirOperation(void) {
   HANDLE hFind; // search handle
   WIN32_FIND_DATA FindFileData;
   DWORD dwAttrs;

   dwAttrs = GetFileAttributes(DosDevicePath);
   if (isDirectory(dwAttrs)) {
      if (Parents == 0) {
         return printErr(_T("Directory [%s] already exists.\n"), DosDevicePathWithoutPrefix);
      }
      else {
         return eTrue;
      }
   }
   else if (isValidFileAttributes(dwAttrs)) {
      return printErr(_T("Not a directory [%s].\n"), DosDevicePathWithoutPrefix);
   }

   tBool result = eTrue;
   if (Parents) {
      LPTSTR LastBackslash = _tcsrchr(DosDevicePath, _T('\\'));
      if (LastBackslash) {
         *LastBackslash = _T('\0');
         result = mkdirOperation();
         *LastBackslash = _T('\\');
      }
   }

   if (result == eTrue) {
      result &= createSingleDirectory(DosDevicePath);
   }

   return result;
}

/*!
 * Create the given directory.
 *
 * If global variable Parents is set, also the parent directories are created.
 *
 * @return eTrue on success, else eFalse.
 */
static tBool runCommand(int argc, wchar_t *argv[]) {
   while (argc != 0) {
      if ((_tcscmp(*argv, _T("--help")) == 0) || (_tcscmp(*argv, _T("-h")) == 0)) {
         printHelp();
         return eTrue;
      }
      else if ((_tcscmp(*argv, _T("--force")) == 0) || (_tcscmp(*argv, _T("-f")) == 0)) {
         Force = 1;
      }
      else if ((_tcscmp(*argv, _T("--parents")) == 0) || (_tcscmp(*argv, _T("-p")) == 0)) {
         Parents = 1;
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
         printErr(_T("Unknown option [%s], use option --help for more information.\n"), *argv);
         return eFalse;
      }
      else {
         break;
      }
      ++argv;
      --argc;
   }

   tBool result = eTrue;
   if (argc == 0) {
      result &= printErr(_T("Too view arguments given.\n"));
   }
   else {
      result &= runCommandForEachInputLine(argc, argv, mkdirOperation);
   }

   return result;
}

tCommand CommandMkdir = {
   _T("mkdir"),
   printHelp,
   runCommand,
};
