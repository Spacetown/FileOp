test_fileop_command_common(
   COMMAND copy
   HELP_REGULAR_EXPRESSION "Copy files or directories to STDOUT\\." "Available options are:"
   TEST_TIME_OPTION
)

test_fileop_check_filesystem(
   NAME CopyMissingTarget
   ARGS copy ${CMAKE_CURRENT_LIST_FILE}
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Too view arguments given\\."
)

test_fileop_check_filesystem(
   NAME CopyMissingSource
   ARGS copy FileDoesNotExists CopyMissingSource
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Can't copy file .+\\\\FileDoesNotExists to .+\\\\CopyMissingSource: The system cannot find the file specified\\."
)

test_fileop_check_filesystem(
   NAME CopyMissingTargetDirectoryI
   ARGS copy --target-directory= CopyMissingTargetDirectoryI
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Target directory must not be empty\\."
)

test_fileop_check_filesystem(
   NAME CopyMissingTargetDirectoryII
   ARGS copy --target-directory
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Option --target-directory needs an argument\\."
)

test_fileop_check_filesystem(
   NAME CopyNonExistingTargetDirectory
   ARGS copy ${CMAKE_CURRENT_LIST_FILE} CopyNonExistingTargetDirectory/
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Directory .+\\\\CopyNonExistingTargetDirectory doesn't exist\\."
)

test_fileop_check_filesystem(
   NAME CopyToDirectory
   ARGS copy ${CMAKE_CURRENT_LIST_FILE} ./
   MUST_EXIST OperationCopy.cmake
)

test_fileop_check_filesystem(
   NAME CopyTargetDirectoryIsExistingFile
   DEPENDS CopyToDirectory
   ARGS copy --target-directory=${CMAKE_CURRENT_LIST_FILE} ${CMAKE_CURRENT_LIST_FILE}
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Target .+\\\\OperationCopy.cmake must be a directory\\."
   MUST_EXIST OperationCopy.cmake
)

test_fileop_check_filesystem(
   NAME CopyTargetFileExists
   DEPENDS CopyCopyToDirectory
   ARGS copy ${CMAKE_CURRENT_LIST_FILE} ./OperationCopy.cmake
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Can't copy file .+\\\\OperationCopy.cmake to .+\\\\OperationCopy.cmake: The file exists\\."
   MUST_EXIST OperationCopy.cmake
)

test_fileop_check_filesystem(
   NAME CopyTargetFileExistsForce
   DEPENDS CopyTargetFileExists
   ARGS --debug copy --force --time 2001-01-02T00:30 ${CMAKE_CURRENT_LIST_FILE} ./OperationCopy.cmake
   MUST_EXIST OperationCopy.cmake
   FILE_TIMESTAMP_REGEX "2001-01-02 00:30:00\\.000000000 \\+0000"
)

test_fileop_check_filesystem(
   NAME CopyTargetFileExistsWithDirectory
   DEPENDS CopyTargetFileExistsForce
   ARGS copy --target-directory=. ${CMAKE_CURRENT_LIST_FILE}
   WILL_FAIL
)

test_fileop_check_filesystem(
   NAME CopyTargetFileExistsWithDirectoryForce
   DEPENDS CopyTargetFileExistsWithDirectory
   ARGS copy --force --time 2002-01-02T00:30 --target-directory=. ${CMAKE_CURRENT_LIST_FILE}
   FILE_TIMESTAMP_REGEX "2002-01-02 00:30:00\\.000000000 \\+0000"
)

test_fileop_check_filesystem(
   NAME CopyTargetFileExistsWithPatternForce
   ARGS copy --force --time 2003-01-02T00:30 --target-directory=. ${CMAKE_CURRENT_LIST_DIR}/OperationCopy.*
   MUST_EXIST OperationCopy.c OperationCopy.cmake OperationCopy.h
   FILE_TIMESTAMP_REGEX "2003-01-02 00:30:00\\.000000000 \\+0000"
)

test_fileop_check_filesystem(
   NAME CopyFileList
   DEPENDS CopyTargetFileExistsWithPatternForce
   ARGS copy --force --time 2004-01-02T00:30 ${CMAKE_CURRENT_LIST_DIR}/OperationCopy.h ${CMAKE_CURRENT_LIST_DIR}/OperationCopy.c  ${CMAKE_CURRENT_LIST_DIR}/OperationCopy.cmake .
   MUST_EXIST OperationCopy.c OperationCopy.cmake OperationCopy.h
   FILE_TIMESTAMP_REGEX "2004-01-02 00:30:00\\.000000000 \\+0000"
)

test_fileop_check_filesystem(
   NAME CopyDirectory
   ARGS copy --target-directory=. ${CMAKE_CURRENT_LIST_DIR}
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: --recursive not specified, omitting directory"
   MUST_NOT_EXIST src src/OperationCopy.c src/OperationCopy.cmake src/OperationCopy.h
)

test_fileop_check_filesystem(
   NAME CopyDirectoryRecursive
   DEPENDS CopyDirectoryExists
   ARGS copy --recursive --time 2007-01-02T00:30 --target-directory=. ${CMAKE_CURRENT_LIST_DIR}
   MUST_EXIST src/OperationCopy.c src/OperationCopy.cmake src/OperationCopy.h
   FILE_TIMESTAMP_REGEX "2007-01-02 00:30:00\\.000000000 \\+0000"
)

test_fileop_check_filesystem(
   NAME CopyDirectoryRecursiveExists
   DEPENDS CopyDirectoryRecursive
   ARGS copy --recursive --time 2008-01-02T00:30 --target-directory=. ${CMAKE_CURRENT_LIST_DIR}
   WILL_FAIL
   MUST_EXIST src/OperationCopy.c src/OperationCopy.cmake src/OperationCopy.h
   FILE_TIMESTAMP_REGEX "2007-01-02 00:30:00\\.000000000 \\+0000" # Not touched
)

test_fileop_check_filesystem(
   NAME CopyDirectoryRecursiveForce
   DEPENDS CopyDirectoryRecursiveExists
   ARGS copy --recursive --force --time 2008-01-02T00:30 --target-directory=. ${CMAKE_CURRENT_LIST_DIR}
   MUST_EXIST src/OperationCopy.c src/OperationCopy.cmake src/OperationCopy.h
   FILE_TIMESTAMP_REGEX "2008-01-02 00:30:00\\.000000000 \\+0000"
)
