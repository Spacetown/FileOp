test_fileop_command_common(
   COMMAND move
   HELP_REGULAR_EXPRESSION "Move files or directories\\." "Available options are:"
   TEST_TIME_OPTION
)

test_fileop_check_filesystem(
   NAME MoveMissingTarget
   ARGS move ${CMAKE_CURRENT_LIST_FILE}
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Too view arguments given\\."
)

test_fileop_check_filesystem(
   NAME MoveMissingSource
   ARGS move file1 file2
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Can't move file .+\\\\file to .+\\\\file2: The system cannot find the file specified\\."
)

test_fileop_check_filesystem(
   NAME MoveMissingTargetDirectoryI
   ARGS move --target-directory= CopyMissingTargetDirectoryI
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Target directory must not be empty\\."
)

test_fileop_check_filesystem(
   NAME MoveMissingTargetDirectoryII
   ARGS move --target-directory
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Option --target-directory needs an argument\\."
)

test_fileop_check_filesystem(
   NAME MoveNonExistingTargetDirectory
   PREPARE_COMMAND cp -f ${CMAKE_CURRENT_LIST_FILE} MoveNonExistingTargetDirectory.in
   ARGS move MoveNonExistingTargetDirectory.in MoveNonExistingTargetDirectory/
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Directory [A-Z]:\\\\.+\\\\MoveNonExistingTargetDirectory doesn't exist\\."
   MUST_NOT_EXIST MoveNonExistingTargetDirectory/MoveNonExistingTargetDirectory.in
)

test_fileop_check_filesystem(
   NAME MoveFileWithTargetDirectory
   PREPARE_COMMAND sh -c "cp -f ${CMAKE_CURRENT_LIST_FILE} . && mkdir SubDir"
   ARGS move --target-directory=SubDir OperationMove.cmake
   MUST_NOT_EXIST OperationMove.cmake
   MUST_EXIST SubDir/OperationMove.cmake
)

test_fileop_check_filesystem(
   NAME MoveFileWithTargetDirectoryForce
   DEPENDS MoveFileWithTargetDirectory
   PREPARE_COMMAND cp -f ${CMAKE_CURRENT_LIST_FILE} .
   ARGS move --force --target-directory SubDir OperationMove.cmake
   MUST_NOT_EXIST OperationMove.cmake
   MUST_EXIST SubDir/OperationMove.cmake
)

test_fileop_check_filesystem(
   NAME MoveFileWithTargetDirectoryUniqueNames
   DEPENDS MoveFileWithTargetDirectoryForce
   PREPARE_COMMAND sh -c "cp -f ${CMAKE_CURRENT_LIST_FILE} . && mkdir SubDir1"
   ARGS move --check-unique-names --target-directory SubDir1 SubDir/OperationMove.cmake OperationMove.cmake
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: File in source list will overwrite each other: OperationMove.cmake"
   MUST_NOT_EXIST SubDir1/OperationMove.cmake
   MUST_EXIST OperationMove.cmake SubDir/OperationMove.cmake
)

test_fileop_check_filesystem(
   NAME MoveFileWithPattern
   DEPENDS MoveFileWithTargetDirectoryUniqueNames
   ARGS move --target-directory SubDir1 SubDir/OperationMove.*
   MUST_NOT_EXIST SubDir/OperationMove.cmake
   MUST_EXIST SubDir1/OperationMove.cmake
)

test_fileop_check_filesystem(
   NAME MoveFileListWithPattern
   PREPARE_COMMAND sh -c "mkdir -p MoveFileListWithPattern MoveFileListWithPatternTarget && cp -f ${CMAKE_CURRENT_LIST_DIR}/Ope*Move.* MoveFileListWithPattern/"
   ARGS move --touch --time=2001-01-01T00:30 MoveFileListWithPattern/OperationMove.* MoveFileListWithPatternTarget/
   MUST_EXIST MoveFileListWithPatternTarget/OperationMove.cmake MoveFileListWithPatternTarget/OperationMove.c
   MUST_NOT_EXIST MoveFileListWithPattern/OperationMove.cmake MoveFileListWithPattern/OperationMove.c
   FILE_TIMESTAMP_REGEX "2001-01-01 00:30:00\\.000000000 \\+0000"
)

test_fileop_check_filesystem(
   NAME MoveFileListWithPatternExisting
   DEPENDS MoveFileListWithPattern
   PREPARE_COMMAND sh -c "cp -f MoveFileListWithPatternTarget/*.* MoveFileListWithPattern/ && chmod -R oga-w MoveFileListWithPatternTarget"
   ARGS move --touch --time=2002-01-01T00:30 MoveFileListWithPattern/OperationMove.* MoveFileListWithPatternTarget/
   WILL_FAIL
   MUST_EXIST MoveFileListWithPattern/OperationMove.cmake MoveFileListWithPattern/OperationMove.c
)

test_fileop_check_filesystem(
   NAME MoveFileListWithPatternExistingForced
   DEPENDS MoveFileListWithPatternExisting
   ARGS move --touch --force --time=2002-01-01T00:30 MoveFileListWithPattern/OperationMove.* MoveFileListWithPatternTarget/
   MUST_EXIST MoveFileListWithPatternTarget/OperationMove.cmake MoveFileListWithPatternTarget/OperationMove.c
   MUST_NOT_EXIST MoveFileListWithPattern/OperationMove.cmake MoveFileListWithPattern/OperationMove.c
   FILE_TIMESTAMP_REGEX "2002-01-01 00:30:00\\.000000000 \\+0000"
)

test_fileop_check_filesystem(
   NAME MoveFileWithDashDash
   PREPARE_COMMAND cp -f -- ${CMAKE_CURRENT_LIST_FILE} --source
   ARGS move -- --source --target
   MUST_NOT_EXIST --source
   MUST_EXIST --target
)

test_fileop_check_filesystem(
   NAME MoveFileToDirectory
   DEPENDS MoveFileWithDashDash
   PREPARE_COMMAND mkdir -p MoveFileToDirectory/dir
   ARGS move -- --target MoveFileToDirectory/dir
   MUST_NOT_EXIST --target
   MUST_EXIST MoveFileToDirectory/dir/--target
)

test_fileop_check_filesystem(
   NAME MoveDirectoryToExistingFile
   DEPENDS MoveFileToDirectory
   ARGS --debug move -- ${CMAKE_CURRENT_LIST_DIR} MoveFileToDirectory/dir/--target
   WILL_FAIL
   MUST_EXIST ${CMAKE_CURRENT_LIST_DIR}
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Target .+\\\\--target must be a directory\\."
)

test_fileop_check_filesystem(
   NAME MoveFileExistingTarget
   DEPENDS MoveDirectoryToExistingFile
   PREPARE_COMMAND cp -f -- ${CMAKE_CURRENT_LIST_FILE} --target
   ARGS move -- --target MoveFileToDirectory/dir
   WILL_FAIL
   MUST_EXIST --target
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Can't move file .+\\\\--target to .+\\\\MoveFileToDirectory\\\\dir\\\\--target: The file exists\\."
)

test_fileop_check_filesystem(
   NAME MoveFileExistingTargetForce
   DEPENDS MoveFileExistingTarget
   PREPARE_COMMAND chmod -R oga-w MoveFileToDirectory/dir/--target
   ARGS move --force -- --target MoveFileToDirectory/dir/
   MUST_NOT_EXIST --target
   MUST_EXIST MoveFileToDirectory/dir/--target
)

test_fileop_check_filesystem(
   NAME MoveDirectoryRecursive
   DEPENDS MoveFileExistingTargetForce
   PREPARE_COMMAND sh -c "mkdir -p MoveFileToDirectory/Target/dir && chmod -R oga-w MoveFileToDirectory"
   ARGS --debug move --force --touch --time 2003-01-01 --target-directory MoveFileToDirectory/Target MoveFileToDirectory/dir
   MUST_EXIST MoveFileToDirectory/Target/dir/--target
   MUST_NOT_EXIST MoveFileToDirectory/dir
)
