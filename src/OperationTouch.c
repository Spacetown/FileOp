
#include "BasicFileOp.h"
#include "FileOp.h"
#include "Message.h"
#include "Types.h"

static void printHelp(void) {
   printOut(_T("Touch the given files. This means creating it or updating the timestamp if it\n"));
   printOut(_T("already exists.\n"));
   printOut(_T("If the file starts with an @, the files listed in the files are touched.\n"));
   printOut(_T("\n"));
   printOut(_T("Available options are:\n"));
   printOut(_T("   --time=TIME  Use local ISO time instead of current system time.\n"));
   printOut(_T("                E.g. 2021-01-31T15:05:01 if no time is given, 12:00:00 is\n"));
   printOut(_T("                assumed.\n"));

   return;
}

static tResult touchOperation(void) { return touchSingleFile(DosDevicePath, eTrue); }

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
      } else if (isTimeOption(*argv)) {
         if (storeTimeValue(&argc, &argv) != eOk) {
            return eError;
         }
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

   return runCommandForEachInputLine(argc, argv, touchOperation);
}

tCommand CommandTouch = {
    _T("touch"),
    printHelp,
    runCommand,
};
