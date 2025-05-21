test_fileop_command_common(
   COMMAND cat
   HELP_REGULAR_EXPRESSION "Print content of files to STDOUT\\." "No options available\\."
)

test_fileop_check_filesystem(
   NAME CatFile
   ARGS cat ${CMAKE_CURRENT_LIST_FILE}
   PASS_REGULAR_EXPRESSION "Print content of files to STDOUT\\\\\\\\\\." "No options available\\\\\\\\\\."
)

test_fileop_check_filesystem(
   NAME CatFileLeadingDashDash
   PREPARE_COMMAND sh -c "echo 'File content of --xxx' > --xxx"
   ARGS --debug cat -- --xxx
   PASS_REGULAR_EXPRESSION "-- detected, stop option parsing." "^File content of --xxx$"
)

test_fileop_check_filesystem(
   NAME CatDirectory
   ARGS cat .
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp.exe: error: Only files can be printed. Got directory [A-Z]:\\\\.*\\\\CatDirectory"
)

