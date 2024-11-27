
#include "Types.h"
#include "FileOp.h"
#include "Message.h"
#include "BasicFileOp.h"

static void printHelp(void) {
   printOut(_T("Print content of files to STDOUT.\n"));
   printOut(_T("If the file starts with an @, the files listed in the files are printed out.\n"));
   printOut(_T("\n"));
   printOut(_T("No options available.\n"));

   return;
}

static tBool catOperation(void) {
   tBool result = eTrue;
   DWORD dwAttrs = GetFileAttributes(DosDevicePath);

   if (isDirectory(dwAttrs)) {
      result &= printErr(_T("Only files can be printed. Got directory [%s]"), DosDevicePathWithoutPrefix);
   }
   else {
      result &= printFileToHandle(DosDevicePath, GetStdHandle(STD_OUTPUT_HANDLE));
   }

   return result;
}

/*!
 * Print a file to STDOUT.
 *
 * @return eTrue on success, else eFalse.
 */
static tBool runCommand(int argc, wchar_t *argv[]) {

   while (argc != 0) {
      if ((_tcscmp(*argv, _T("--help")) == 0) || (_tcscmp(*argv, _T("-h")) == 0)) {
         printHelp();
         return eTrue;
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
         return printErr(_T("Unknown option [%s], use option --help for more information.\n"), *argv);
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

   return runCommandForEachInputLine(argc, argv, catOperation);
}

tCommand CommandCat = {
   _T("cat"),
   printHelp,
   runCommand,
};
