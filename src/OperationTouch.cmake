test_fileop_command_common(
   COMMAND touch
   HELP_REGULAR_EXPRESSION "Touch the given files\. This means creating it or updating the timestamp of it" "already exists\." "Available options are:"
   TEST_TIME_OPTION
)

test_fileop(
   NAME TouchTemporaryFileSpaceTimestamp
   ARGS --debug touch --time 2000-01-01T12:30 TouchTemporaryFileSpaceTimestamp
   FILE_EXIST TouchTemporaryFileSpaceTimestamp
   FILE_TIMESTAMP 2000-01-01T12:30
)

test_fileop(
   NAME TouchTemporaryFileEqualTimestamp
   ARGS --debug touch --time 2001-01-01T12:30 TouchTemporaryFileEqualTimestamp
   FILE_EXIST TouchTemporaryFileEqualTimestamp
   FILE_TIMESTAMP 2000-01-01T12:30
)
