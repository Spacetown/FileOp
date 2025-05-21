cmake_minimum_required(VERSION 3.25.1)

string(APPEND CMAKE_C_FLAGS_PROFILE "--coverage")
string(APPEND CMAKE_RC_FLAGS "--verbose")
string(APPEND CMAKE_EXE_LINKER_FLAGS "-static")

project(FileOp C RC)

   add_custom_target(
      resource_file
      COMMAND bash -c ${CMAKE_CURRENT_LIST_DIR}/../scripts/get_pe_header.rc.sh > PeHeader.rc
      BYPRODUCTS PeHeader.rc
   )

   add_executable(
      FileOp
      PeHeader.rc
      BasicFileOp.c
      FileOp.c
      Message.c
      OperationCat.c
      OperationCopy.c
      OperationMkdir.c
      OperationMove.c
      OperationRemove.c
      OperationTouch.c
   )

   add_custom_target(
      readme ALL
      COMMAND bash -c ${CMAKE_CURRENT_LIST_DIR}/../scripts/get_readme.md.sh > README.md
      BYPRODUCTS README.md
   )

   add_custom_target(
      create_zip ALL
      COMMAND ${CMAKE_COMMAND} -E tar "cfv" "FileOp.7z" --format=7zip
         FileOp.exe
         README.md
      DEPENDS FileOp readme
      BYPRODUCTS FileOp.7z
   )

   include(CTest)

   function(test_fileop)
      set(options WILL_FAIL)
      set(oneValueArgs NAME WORKING_DIRECTORY FILE_TIME_STAMP)
      set(multiValueArgs ARGS FAIL_REGULAR_EXPRESSION PASS_REGULAR_EXPRESSION)
      cmake_parse_arguments(
         PARSE_ARGV 0 arg
         "${options}" "${oneValueArgs}" "${multiValueArgs}"
      )

      add_test(
         NAME ${arg_NAME}
         COMMAND FileOp.exe ${arg_ARGS}
         WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
      )
         set_property(
               TEST ${arg_NAME}
               PROPERTY WILL_FAIL ${arg_WILL_FAIL}
         )
         if (arg_FAIL_REGULAR_EXPRESSION)
            set_property(
               TEST ${arg_NAME}
               PROPERTY FAIL_REGULAR_EXPRESSION ${arg_FAIL_REGULAR_EXPRESSION}
            )
         endif()
         if (arg_PASS_REGULAR_EXPRESSION)
            set_property(
               TEST ${arg_NAME}
               PROPERTY PASS_REGULAR_EXPRESSION ${arg_PASS_REGULAR_EXPRESSION}
            )
         endif()
   endfunction()

   function(test_fileop_command_common)
      set(options TEST_TIME_OPTION)
      set(oneValueArgs COMMAND)
      set(multiValueArgs HELP_REGULAR_EXPRESSION)
      cmake_parse_arguments(
         PARSE_ARGV 0 arg
         "${options}" "${oneValueArgs}" "${multiValueArgs}"
      )

      test_fileop(
         NAME Run_${arg_COMMAND}_WithOptionHelp
         ARGS ${arg_COMMAND} --help
         WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
         PASS_REGULAR_EXPRESSION ${arg_HELP_REGULAR_EXPRESSION}
      )
      test_fileop(
         NAME Run_${arg_COMMAND}_WithOptionH
         ARGS ${arg_COMMAND} -h
         WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
         PASS_REGULAR_EXPRESSION ${arg_HELP_REGULAR_EXPRESSION}
      )
      test_fileop(
         NAME Run_${arg_COMMAND}_WithNoArguments
         ARGS ${arg_COMMAND}
         WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
         WILL_FAIL
         FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Too view arguments given\\."
      )
      test_fileop(
         NAME Run_${arg_COMMAND}_WithUnknownSlashOption
         ARGS ${arg_COMMAND} -x
         WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
         WILL_FAIL
         FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Unknown option -x, use option --help for more information\\."
      )
      test_fileop(
         NAME Run_${arg_COMMAND}_WithUnknownSlashSlashOption
         ARGS ${arg_COMMAND} --xxx
         WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
         WILL_FAIL
         FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Unknown option --xxx, use option --help for more information\\."
      )
      test_fileop(
         NAME Run_${arg_COMMAND}_WithLonesomeDash
         ARGS --debug ${arg_COMMAND} -- --xxx
         WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
         WILL_FAIL
         FAIL_REGULAR_EXPRESSION "-- detected, stop option parsing\\."
      )

      if (arg_TEST_TIME_OPTION)
         test_fileop(
            NAME Run_${arg_COMMAND}_TimeWithoutValue
            ARGS ${arg_COMMAND} --time
            WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
            WILL_FAIL
            FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Option --time needs an argument\\."
         )
         test_fileop(
            NAME Run_${arg_COMMAND}_TimeWithWrongFormatI
            ARGS ${arg_COMMAND} --time 2001-01
            WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
            WILL_FAIL
            FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Wrong format for time 2001-01, expected yyyy-mm-dd\\[Thh:mm\\[:ss\\]\\]\\."
         )
         test_fileop(
            NAME Run_${arg_COMMAND}_TimeWithWrongFormatII
            ARGS ${arg_COMMAND} --time 2001-01-01T12
            WORKING_DIRECTORY ${arg_WORKING_DIRECTORY}
            WILL_FAIL
            FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Wrong format for time 2001-01-01T12, expected yyyy-mm-dd\\[Thh:mm\\[:ss\\]\\]\\."
         )
      endif()
   endfunction()

   function(test_fileop_check_filesystem)
      set(options WILL_FAIL)
      set(oneValueArgs NAME)
      set(multiValueArgs PREPARE_COMMAND ARGS FAIL_REGULAR_EXPRESSION PASS_REGULAR_EXPRESSION MUST_EXIST MUST_NOT_EXIST FILE_TIMESTAMP_REGEX)
      cmake_parse_arguments(
         PARSE_ARGV 0 arg
         "${options}" "${oneValueArgs}" "${multiValueArgs}"
      )

      add_test(
         NAME ${arg_NAME}_setup
         COMMAND sh -c "rm -rf ${arg_NAME} ; mkdir ${arg_NAME}"
      )

      if (arg_PREPARE_COMMAND)
         add_test(
            NAME ${arg_NAME}_prepare
            COMMAND sh -c "${arg_PREPARE_COMMAND}"
            WORKING_DIRECTORY ${arg_NAME}
         )
            set_property(
               TEST ${arg_NAME}_prepare
               PROPERTY DEPENDS ${arg_NAME}_setup
            )
      endif()

      add_test(
         NAME ${arg_NAME}
         COMMAND ../FileOp.exe ${arg_ARGS}
         WORKING_DIRECTORY ${arg_NAME}
      )
         set_property(
               TEST ${arg_NAME}
               PROPERTY WILL_FAIL ${arg_WILL_FAIL}
         )
         if (arg_PREPARE_COMMAND)
            set_property(
               TEST ${arg_NAME}
               PROPERTY DEPENDS ${arg_NAME}_prepare
            )
         else()
            set_property(
               TEST ${arg_NAME}
               PROPERTY DEPENDS ${arg_NAME}_setup
            )
         endif()
         if (arg_FAIL_REGULAR_EXPRESSION)
            set_property(
               TEST ${arg_NAME}
               PROPERTY FAIL_REGULAR_EXPRESSION ${arg_FAIL_REGULAR_EXPRESSION}
            )
         endif()
         if (arg_PASS_REGULAR_EXPRESSION)
            set_property(
               TEST ${arg_NAME}
               PROPERTY PASS_REGULAR_EXPRESSION ${arg_PASS_REGULAR_EXPRESSION}
            )
         endif()

      if (arg_MUST_EXIST)
         foreach(FILE ${arg_MUST_EXIST})
            add_test(
               NAME ${arg_NAME}_${FILE}_must_exist
               COMMAND sh -c "test -w ${FILE} && stat --printf '%y' -- ${FILE}"
               WORKING_DIRECTORY ${arg_NAME}
            )
            set_property(
               TEST ${arg_NAME}_${FILE}_must_exist
               PROPERTY DEPENDS ${arg_NAME}
            )
            if (arg_FILE_TIMESTAMP_REGEX)
               set_property(
                  TEST ${arg_NAME}_${FILE}_must_exist
                  PROPERTY PASS_REGULAR_EXPRESSION ${arg_FILE_TIMESTAMP_REGEX}
               )
            endif ()
         endforeach()
      endif ()

      if (arg_MUST_NOT_EXIST)
         foreach(FILE ${arg_MUST_NOT_EXIST})
            add_test(
               NAME ${arg_NAME}_${FILE}_must_not_exist
               COMMAND stat --printf '%y' -- ${FILE}
               WORKING_DIRECTORY ${arg_NAME}
            )
            set_property(
               TEST ${arg_NAME}_${FILE}_must_not_exist
               PROPERTY DEPENDS ${arg_NAME}
            )
            set_property(
               TEST ${arg_NAME}_${FILE}_must_not_exist
               PROPERTY WILL_FAIL true
            )
         endforeach()
      endif ()

   endfunction()


   ################################# Base tests #################################
   test_fileop(
      NAME Run_WithNoArguments
      WILL_FAIL
      FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: No command given. Use option --help."
   )

   test_fileop(
      NAME Run_WithOptionHelp
      ARGS --help
      PASS_REGULAR_EXPRESSION "FileOp\\.exe \\[<options>\\] \\[<command> \\[<options>\\] <argument\\+>\\]"
   )

   test_fileop(
      NAME Run_WithUnknownCommand
      ARGS unknown
      WILL_FAIL
      FAIL_REGULAR_EXPRESSION "FileOp\\.exe: error: Unknown command 'unknown' given, use option --help for more information."
   )

   include(OperationCat.cmake)
   include(OperationCopy.cmake)
   include(OperationMkdir.cmake)
   include(OperationMove.cmake)
   include(OperationRemove.cmake)
   include(OperationTouch.cmake)
