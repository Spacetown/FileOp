
#include "FileOp.h"

#include "BasicFileOp.h"
#include "Message.h"
#include "OperationCat.h"
#include "OperationCopy.h"
#include "OperationMkdir.h"
#include "OperationMove.h"
#include "OperationRemove.h"
#include "OperationTouch.h"

#include <excpt.h>
#include <stdio.h>

tCommand *Commands[] = {&CommandCat, &CommandCopy, &CommandMkdir, &CommandMove, &CommandRemove, &CommandTouch, NULL};

tCommand **Command = NULL;

//! Global value for debug.
tBool Debug;

/*!
 * Flush output and exit process.
 *
 * @param uExitCode The Exitcode for the process
 */
void flushOutputAndExit(UINT uExitCode) {
   fflush(stderr);
   fflush(stdout);
   exit(uExitCode);
}

/*!
 * Prints the usage and exits with success.
 */
void errorNoCommand() {
   printErr(_T("No command given. Use option --help.\n"));
   flushOutputAndExit(EXIT_FAILURE);
}

/*!
 * Prints the usage and exits with success.
 */
void printHelpAndExit() {
   printOut(_T("Windows file operations\n"));
   printOut(_T("=======================\n"));
   printOut(_T("\n"));
   printOut(_T("Usage:\n"));
   printOut(_T("  %s [<options>] [<command> [<options>] <argument+>]\n"), ProgramName);
   printOut(_T("\n"));
   printOut(_T("The command support paths with up to 32676 characters by using the DOS device\n"));
   printOut(_T("path e.g. \\\\?\\c:\\temp. / and \\ are supported as path separator."));
   printOut(_T("\n"));
   printOut(_T("To use file or directory names starting with a - or -- add a -- argument.\n"));
   printOut(_T("The -- argument stops the command line options.\n"));
   printOut(_T("\n"));
   printOut(_T("Following options are available:\n"));
   printOut(_T("   -h, --help           Print this help.\n"));
   printOut(_T("   -d, --debug          Print additional debug informations.\n"));
   printOut(_T("\n"));
   printOut(_T("Following commands are available:\n"));
   printOut(_T("\n"));

   for (Command = Commands; (*Command) != NULL; ++Command) {
      printOut(_T("%s:\n"), (*Command)->id);
      printOut(_T("%.*s\n"), _tcslen((*Command)->id) + 1, _T("----------------------------------------"));
      (*Command)->printHelp();
      printOut(_T("\n"));
   }

   flushOutputAndExit(EXIT_SUCCESS);
}

#include "mingw-unicode.c"

/*!
 * Tha main routine.
 *
 * @param argc Number of arguments.
 * @param argv The arguments.
 * @return The exit code of the process.
 */
int _tmain(int argc, wchar_t *argv[]) {
   LPCTSTR Ptr, PtrSlash, PtrBackSlash;

   // Search the last \ or /.
   PtrSlash = _tcsrchr(*argv, _T('/'));
   PtrBackSlash = _tcsrchr(*argv, _T('\\'));
   if (PtrBackSlash > PtrSlash) {
      Ptr = ++PtrBackSlash;
   }
   // GCOVR_EXCL_START
   else if (PtrSlash > PtrBackSlash) {
      Ptr = ++PtrSlash;
   } else {
      Ptr = *argv;
   }
   // GCOVR_EXCL_STOP

   DWORD ProgramNameLen = _tcslen(Ptr);
   if (ProgramNameLen > PROGRAM_NAME_BUFFER_SIZE) { // GCOVR_EXCL_BR
      // GCOVR_EXCL_START
      _tcscpy(ProgramName, _T("..."));
      _tcscat(ProgramName, &Ptr[ProgramNameLen - (PROGRAM_NAME_BUFFER_SIZE + 3 + 1)]);
      // GCOVR_EXCL_STOP
   } else {
      _tcscpy(ProgramName, Ptr);
   }
   argv++;
   argc--;

   if (argc == 0) {
      errorNoCommand();
   }

   while (1 == 1) {
      if ((_tcscmp(*argv, _T("--help")) == 0) || (_tcscmp(*argv, _T("-h")) == 0)) {
         printHelpAndExit();
      } else if ((_tcscmp(*argv, _T("--debug")) == 0) || (_tcscmp(*argv, _T("-d")) == 0)) {
         Debug = 1;
         ++argv;
         --argc;
      } else {
         break;
      }
   }

   for (Command = Commands; (*Command) != NULL; ++Command) {
      if (_tcscmp(*argv, (*Command)->id) == 0) {
         break;
      }
   }

   if ((*Command) == NULL) {
      printErr(_T("Unknown command '%s' given, use option --help for more information.\n"), *argv);
      flushOutputAndExit(EXIT_FAILURE);
   }
   ++argv;
   --argc;

   flushOutputAndExit(((*Command)->run(argc, argv) == eOk) ? EXIT_SUCCESS : EXIT_FAILURE);

   // here we never come to
   return EXIT_FAILURE; // GCOVR_EXCL_LINE
}
