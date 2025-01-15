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
   NAME TargetDirectoryIsExistingFile
   DEPENDS CopyToDirectory
   ARGS copy --target-directory=${CMAKE_CURRENT_LIST_FILE} ${CMAKE_CURRENT_LIST_FILE}
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Target .+\\\\OperationCopy.cmake must be a directory\\."
)

test_fileop_check_filesystem(
   NAME TargetFileExists
   DEPENDS CopyToDirectory
   ARGS copy ${CMAKE_CURRENT_LIST_FILE} ./OperationCopy.cmake
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Can't copy file .+\\\\OperationCopy.cmake to .+\\\\OperationCopy.cmake: The file exists\\."
)

test_fileop_check_filesystem(
   NAME TargetFileExistsForce
   DEPENDS TargetFileExists
   ARGS copy --force ${CMAKE_CURRENT_LIST_FILE} ./OperationCopy.cmake
)
