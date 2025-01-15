test_fileop_command_common(
   COMMAND touch
   HELP_REGULAR_EXPRESSION "Touch the given files\\. This means creating it or updating the timestamp of it" "already exists\\." "Available options are:"
   TEST_TIME_OPTION
)

test_fileop_check_filesystem(
   NAME TouchFileSpaceTimestamp
   ARGS --debug touch --time 2000-01-01T12:30 TouchFileSpaceTimestamp
   MUST_EXIST TouchFileSpaceTimestamp
   FILE_TIMESTAMP_REGEX "2000-01-01 12:30:00\\.000000000 \\+0000"
)

test_fileop_check_filesystem(
   NAME TouchFileEqualTimestamp
   ARGS --debug touch --time 2001-01-02T00:30 TouchFileEqualTimestamp
   MUST_EXIST TouchFileEqualTimestamp
   FILE_TIMESTAMP_REGEX "2001-01-02 00:30:00\\.000000000 \\+0000"
)

test_fileop_check_filesystem(
   NAME TouchFileLeadingDashDash
   ARGS --debug touch -- --xxx
   MUST_EXIST --xxx
)

test_fileop_check_filesystem(
   NAME TouchFileLeadingDosDeviceName
   ARGS --debug touch //?/${CMAKE_CURRENT_BINARY_DIR}/TouchFileLeadingDosDeviceName
   MUST_EXIST TouchFileLeadingDosDeviceName
)

test_fileop(
   NAME TouchFileUnc
   ARGS --debug touch //machine/share/file
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Can't get handle to UNC\\\\machine\\\\share\\\\file: The network (name cannot be|path was not) found\\."

)

test_fileop(
   NAME TouchFileLeadingDosDeviceNameUnc
   ARGS --debug touch //?//UNC/machine/share/file
   WILL_FAIL
   FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Can't get handle to UNC\\\\machine\\\\share\\\\file: The network (name cannot be|path was not) found\\."
)
