test_fileop_command_common(
   COMMAND touch
   HELP_REGULAR_EXPRESSION "Touch the given files\. This means creating it or updating the timestamp of it" "already exists\." "Available options are:"
   TEST_TIME_OPTION
)
