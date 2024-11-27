
#include "Types.h"
#include "FileOp.h"
#include "Message.h"
#include "BasicFileOp.h"

//! The time used for touch.
static LPCTSTR LocalTime = NULL;

static void printHelp(void)
{
   print(_T("Touch the given files. This means creating it or updating the timestamp if it\n"));
   print(_T("already exists.\n"));
   print(_T("If the file starts with an @, the files listed in the files are touched.\n"));
   print(_T("\n"));
   print(_T("Available options are:\n"));
   print(_T("   --time=TIME  Use local ISO time instead of current system time.\n"));
   print(_T("                E.g. 2021-01-31T15:05:01 if no time is given, 12:00:00 is\n"));
   print(_T("                assumed.\n"));
   print(_T("No options available.\n"));

   return;
}

static tBool touchOperation(void)
{
   return touchSingleFile(DosDevicePath, LocalTime, VALUE_TRUE);
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
      else if (_tcsncmp(*argv, _T("--time"), 6) == 0)
      {
         if (_tcsncmp(*argv, _T("--time="), 7) == 0)
         {
            LocalTime = &(*argv)[7];
         }
         else
         {
            if (argc == 1)
            {
               return printError(_T("Option [%s] needs an argument.\n"), *argv);
            }
            LocalTime = *(++argv);
            --argc;
         }
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
      result &= runCommandForEachInputLine(argc, argv, touchOperation);
   }

   return result;
}

tCommand CommandTouch = {
    _T("touch"),
    printHelp,
    runCommand,
};
