
#include "BasicFileOp.h"
#include "FileOp.h"
#include "Message.h"
#include "Types.h"

static void printHelp(void) {
   printOut(_T("Print content of files to STDOUT.\n"));
   printOut(_T("If the file starts with an @, the files listed in the files are printed out.\n"));
   printOut(_T("\n"));
   printOut(_T("No options available.\n"));

   return;
}

static tResult catOperation(void) {
   DWORD dwAttrs = GetFileAttributes(DosDevicePath);
   if (isDirectory(dwAttrs)) {
      return printErr(_T("Only files can be printed. Got directory %s.\n"), getReadableFilename(DosDevicePath));
   }

   return printFileToHandle(DosDevicePath, GetStdHandle(STD_OUTPUT_HANDLE));
}

/*!
 * Print a file to STDOUT.
 *
 * @return eOk on success, else eError.
 */
static tResult runCommand(int argc, wchar_t *argv[]) {

   while (argc != 0) {
      if ((_tcscmp(*argv, _T("--help")) == 0) || (_tcscmp(*argv, _T("-h")) == 0)) {
         printHelp();
         return eOk;
      } else if ((_tcscmp(*argv, _T("--")) == 0)) {
         if (Debug) {
            printOut(_T("-- detected, stop option parsing.\n"));
         }
         ++argv;
         --argc;
         break;
      } else if ((_tcsncmp(*argv, _T("--"), 2) == 0) || (_tcsncmp(*argv, _T("-"), 1) == 0)) {
         return printErr(_T("Unknown option %s, use option --help for more information.\n"), *argv);
      } else {
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
