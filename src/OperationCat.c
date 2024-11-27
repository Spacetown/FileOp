
#include "Types.h"
#include "FileOp.h"
#include "Message.h"
#include "BasicFileOp.h"

static void printHelp(void)
{
   print(_T("Print content of files to STDOUT.\n"));
   print(_T("If the file starts with an @, the files listed in the files are printed out.\n"));
   print(_T("\n"));
   print(_T("No options available.\n"));

   return;
}

static tBool catOperation(void)
{
   tBool result = VALUE_TRUE;
   DWORD dwAttrs = GetFileAttributes(DosDevicePath);

   if (isDirectory(dwAttrs))
   {
      result &= printError(_T("Only files can be printed. Got directory [%s]"), DosDevicePath);
   }
   else
   {
      result &= printFileToHandle(DosDevicePath, GetStdHandle(STD_OUTPUT_HANDLE));
   }

   return result;
}

/*!
 * Print a file to STDOUT.
 *
 * @return VALUE_TRUE on success, else VALUE_FALSE.
 */
static tBool runCommand(int argc, wchar_t *argv[])
{

   while (argc != 0)
   {
      if ((_tcscmp(*argv, _T("--help")) == 0) || (_tcscmp(*argv, _T("-h")) == 0))
      {
         printHelp();
         return VALUE_TRUE;
      }
      else if ((_tcscmp(*argv, _T("--")) == 0))
      {
         if (Debug)
         {
            print(_T("-- detected, stop option parsing.\n"));
         }
         ++argv;
         --argc;
         break;
      }
      else if ((_tcsncmp(*argv, _T("--"), 2) == 0) || (_tcsncmp(*argv, _T("-"), 1) == 0))
      {
         return printError(_T("Unknown option [%s], use option --help for more information.\n"), *argv);
      }
      else
      {
         break;
      }
      ++argv;
      --argc;
   }

   tBool result = VALUE_TRUE;
   if (argc == 0)
   {
      result &= printError(_T("Too view arguments given.\n"));
   }
   else
   {
      result &= runCommandForEachInputLine(argc, argv, catOperation);
   }

   return result;
}

tCommand CommandCat = {
    _T("cat"),
    printHelp,
    runCommand,
};
