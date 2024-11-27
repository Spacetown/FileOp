
#include "FileOp.h"
#include "Message.h"
#include "BasicFileOp.h"

//! Global value for force.
static tBool Force = VALUE_FALSE;
//! Global value for recursive.
static tBool Recursive = VALUE_FALSE;
//! Check if there is no name collision before doing the action.
static tBool CheckUniqueNames = VALUE_FALSE;
//! Global value for touching the files.
static tBool Touch = VALUE_FALSE;
//! The time used for touch.
static LPCTSTR LocalTime = NULL;

static void printHelp(void)
{
   print(_T("Move files or directories.\n"));
   print(_T("\n"));
   print(_T("Available options are (Arguments for long options are also needed for short\n"));
   print(_T("options):\n"));
   print(_T("   -f, --force          Ignore write protection of existing targets.\n"));
   print(_T("   --touch              Touch the files after copy.\n"));
   print(_T("   --time=TIME          Use local ISO time instead of current system time for.\n"));
   print(_T("                        the touch operation, e.g. 2021-01-31T15:05:01. If the\n"));
   print(_T("                        time is omitted, 12:00:00 is assumed.\n"));
   print(_T("   -t, --target-directory=DIR  Target directory to use. If not\n"));
   print(_T("                        given, the last argument is used as target dir.\n"));
   print(_T("   --check-unique-names If multiple files or folders are copied check upfront\n"));
   print(_T("                        if there are any collisions. This isn't supported with\n"));
   print(_T("                        wildcards.\n"));
   print(_T("\n"));
   print(_T("The write protection is not copied to the target elements.\n"));
   print(_T("If several sources are given or target is an existing directory the files\n"));
   print(_T("are created with the original name inside target.\n"));

   return;
}

static tBool moveOperation(void)
{
   static tBool RecursiveMoveNeeded = VALUE_FALSE;

   DWORD dwAttrs, dwAttrsTarget;
   int result = VALUE_TRUE;
   LPTSTR StartOfTargetName = &TargetDosDevicePath[_tcslen(TargetDosDevicePath)];

   // If target is a directory, the source name must be added and the attributes must be updated
   dwAttrsTarget = GetFileAttributes(TargetDosDevicePath);
   if (isDirectory(dwAttrsTarget))
   {
      _tcscpy(StartOfTargetName, _tcsrchr(DosDevicePath, _T('\\')));
      dwAttrsTarget = GetFileAttributes(TargetDosDevicePath);
   }

   dwAttrs = GetFileAttributes(DosDevicePath);
   if (Force && isReadonly(dwAttrsTarget))
   {
      result &= clearReadonly(TargetDosDevicePath, dwAttrsTarget);
   }

   if (result == VALUE_TRUE)
   {

      if (isDirectory(dwAttrs))
      {
         if (RecursiveMoveNeeded == VALUE_FALSE)
         {
            if (Debug)
            {
               print(_T("Try to move [%s] directly to [%s], this only works on same device.\n"), DosDevicePath,
                     TargetDosDevicePath);
            }
            if (!MoveFile(DosDevicePath, TargetDosDevicePath))
            {
               RecursiveMoveNeeded = VALUE_TRUE;
               if (Debug)
               {
                  print(_T("Direct move fails, fallback to recursive move.\n"));
               }
            }
         }

         // No else because value can be changed inside if.
         if (RecursiveMoveNeeded == VALUE_TRUE)
         {
            // If move fails, we create the directories in target and move each file.
            // The empty source directory is removed at the end.
            if (!isDirectory(dwAttrsTarget))
            {
               result &= createSingleDirectory(TargetDosDevicePath);
            }
            if (result == VALUE_TRUE)
            {
               HANDLE hFind; // search handle
               WIN32_FIND_DATA FindFileData;
               // File pattern for all files
               _tcscat(DosDevicePath, _T("\\*"));

               // Get the find handle and the data of the first file.
               hFind = FindFirstFile(DosDevicePath, &FindFileData);
               if (hFind == INVALID_HANDLE_VALUE)
               {
                  result = printLastError(_T("Got invalid handle for [%s]"),
                                          DosDevicePath);
               }
               else
               {
                  LPTSTR StartOfSourceName;
                  // Save the position of the filename
                  StartOfSourceName = &DosDevicePath[_tcslen(DosDevicePath) - 1];

                  do
                  {
                     if ((_tcscmp(FindFileData.cFileName, _T(".")) != 0) && (_tcscmp(FindFileData.cFileName, _T("..")) != 0))
                     {
                        _tcscpy(StartOfSourceName, FindFileData.cFileName);
                        // recursive move it
                        result &= moveOperation();
                     }
                  } while ((result == VALUE_TRUE) && (FindNextFile(hFind, &FindFileData) != 0));
                  StartOfSourceName[-1] = _T('\0');
                  if (result == VALUE_TRUE)
                  {
                     // We are at the end of the list
                     if (GetLastError() != ERROR_NO_MORE_FILES)
                     {
                        result = printLastError(_T("Can't get next file"));
                     }
                     else
                     {
                        removeEmptyDirectory(DosDevicePath);
                     }
                  }

                  // close handle to file
                  FindClose(hFind);
               }
            }
         }
      }
      else
      {
         result &= moveSingleFile(DosDevicePath, TargetDosDevicePath, Force);
         if (result == VALUE_TRUE)
         {
            dwAttrsTarget = GetFileAttributes(TargetDosDevicePath);
            if (isReadonly(dwAttrsTarget))
            {
               result &= clearReadonly(TargetDosDevicePath, dwAttrsTarget);
            }
            if ( Touch ) {
               result &= touchSingleFile(TargetDosDevicePath, LocalTime, VALUE_FALSE);
            }
         }
      }
   }

   StartOfTargetName[0] = _T('\0');

   return result;
}

/*!
 * Move a file or directory.
 *
 * @return
 */
static tBool runCommand(int argc, wchar_t *argv[])
{
   tBool TargetIsDirectory = VALUE_FALSE;
   while (argc != 0)
   {
      if ((_tcscmp(*argv, _T("--help")) == 0) || (_tcscmp(*argv, _T("-h")) == 0))
      {
         printHelp();
         return VALUE_TRUE;
      }
      else if ((_tcscmp(*argv, _T("--force")) == 0) || (_tcscmp(*argv, _T("-f")) == 0))
      {
         Force = VALUE_TRUE;
      }
      else if (_tcscmp(*argv, _T("--touch")) == 0)
      {
         Touch = VALUE_TRUE;
      }
      else if (_tcsncmp(*argv, _T("--time"), 6) == 0)
      {
         Touch = VALUE_TRUE; // Is needed
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
      else if ((_tcscmp(*argv, _T("-t")) == 0) || (_tcsncmp(*argv, _T("--target-directory"), 18) == 0))
      {
         LPCTSTR Ptr;
         if (_tcsncmp(*argv, _T("--target-directory="), 19) == 0)
         {
            Ptr = &(*argv)[19];
         }
         else
         {
            if (argc == 1)
            {
               return printError(_T("Option [%s] needs an argument.\n"), *argv);
            }
            Ptr = *(++argv);
            --argc;
         }
         if (Ptr[0] == _T('\n'))
         {
            return printError(_T("Target directory must not be empty.\n"), *argv);
         }
         createDosDevicePath(Ptr, TargetDosDevicePath);
         TargetIsDirectory = VALUE_TRUE;
      }
      else if (_tcscmp(*argv, _T("--check-unique-names")) == 0)
      {
         CheckUniqueNames = VALUE_TRUE;
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

   if (argc == 0)
   {
      return printError(_T("Too view arguments given.\n"));
   }

   if (TargetDosDevicePath[0] == _T('\0'))
   {
      createDosDevicePath(argv[--argc], TargetDosDevicePath);
      if (TargetDosDevicePath == _T('\0'))
      {
         return printError(_T("Argument must not be empty.\n" ));
      }
      else
      {
         if (argc == 0)
         {
            return printError(_T("Too view arguments given.\n"));
         }
         else if (argc > 1)
         {
            TargetIsDirectory = VALUE_TRUE;
         }
      }
   }

   unsigned int lastCharacterPos = _tcslen(TargetDosDevicePath) - 1;
   while ( TargetDosDevicePath[lastCharacterPos ] == _T('\\') )
   {
      TargetIsDirectory = VALUE_TRUE;
      TargetDosDevicePath[lastCharacterPos--] = _T('\0');
   }

   int result = VALUE_TRUE;
   if (TargetIsDirectory)
   {
      DWORD dwAttrsTarget = GetFileAttributes(TargetDosDevicePath);
      if (areAttrsValid(dwAttrsTarget))
      {
         if (!isDirectory(dwAttrsTarget))
         {
            result &= printError(_T("Target [%s] must be a directory."), TargetDosDevicePath);
         }
         else if (Force && isReadonly(dwAttrsTarget))
         {
            result &= clearReadonly(TargetDosDevicePath, dwAttrsTarget);
         }
      }
      else
      {
         result &= printError(_T("Directory [%s] doesn't exist."), TargetDosDevicePath);
      }
   }

   if ( CheckUniqueNames && ( result == VALUE_TRUE ) ) {
      result &= checkUniqueNames(argc, argv);
   }
   if ( result == VALUE_TRUE ) {
      result &= runCommandForEachInputLine(argc, argv, moveOperation);
   }

   return result;
}

tCommand CommandMove = {
    _T("move"),
    printHelp,
    runCommand,
};
