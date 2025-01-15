test_fileop_command_common(
   COMMAND mkdir
   HELP_REGULAR_EXPRESSION "Create directories\\." "Available options are:"
)

test_fileop_check_filesystem(
   NAME Mkdir
   ARGS mkdir mkdir
   MUST_EXIST mkdir
)

test_fileop_check_filesystem(
   NAME MkdirExistingDir
   ARGS mkdir mkdir
   DEPENDS Mkdir
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Directory [A-Z]:\\\\.+\\\\mkdir already exists\\."
)

test_fileop_check_filesystem(
   NAME MkdirExistingDirParents
   ARGS mkdir --parents mkdir
   DEPENDS Mkdir
)

test_fileop_check_filesystem(
   NAME MkdirDirStructure
   ARGS mkdir mkdir/a/b/c
   DEPENDS MkdirExistingDirParents
   WILL_FAIL
   MUST_NOT_EXIST mkdir/a/b/c
)

test_fileop_check_filesystem(
   NAME MkdirDirStructureParents
   ARGS mkdir --parents mkdir/a/b/c
   DEPENDS MkdirDirStructure
   MUST_EXIST mkdir/a/b/c
)

test_fileop_check_filesystem(
   NAME MkdirWithDashDash
   ARGS mkdir -- --mkdir
   MUST_EXIST --mkdir
)

test_fileop_check_filesystem(
   NAME MkdirFilename
   ARGS mkdir -- ${CMAKE_CURRENT_LIST_FILE}
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Not a directory [A-Z]:\\\\.*\\\\OperationMkdir.cmake\\."
)

test_fileop_check_filesystem(
   NAME MkdirIllegalCharacter
   ARGS mkdir --parents "test/invalid_|_name/test_"
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Not a directory [A-Z]:\\\\.*\\\\test\\\\invalid_|_name\\\\test_:"
   MUST_EXIST test
)
