cmake_minimum_required(VERSION 3.25.1)

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
        set(oneValueArgs NAME ARGS FAIL_REGULAR_EXPRESSION PASS_REGULAR_EXPRESSION)
        set(multiValueArgs MUST_EXIST)
        cmake_parse_arguments(
            PARSE_ARGV 0 arg
            "${options}" "${oneValueArgs}" "${multiValueArgs}"
        )

        add_test(
            NAME ${arg_NAME}
            COMMAND FileOp.exe ${arg_ARGS}
        )
            set_property(
                TEST ${arg_NAME}
                PROPERTY WILL_FAIL ${arg_WILL_FAIL}
                PROPERTY FAIL_REGULAR_EXPRESSION ${arg_FAIL_REGULAR_EXPRESSION}
                PROPERTY PASS_REGULAR_EXPRESSION ${arg_PASS_REGULAR_EXPRESSION}
            )
    endfunction()


    function(test_fileop)
        set(options WILL_FAIL)
        set(oneValueArgs NAME FILE_TIME_STAMP)
        set(multiValueArgs ARGS FAIL_REGULAR_EXPRESSION PASS_REGULAR_EXPRESSION FILE_EXIST FILE_NOT_EXISTS FILE_TIMESTAMP)
        cmake_parse_arguments(
            PARSE_ARGV 0 arg
            "${options}" "${oneValueArgs}" "${multiValueArgs}"
        )

        add_test(
            NAME ${arg_NAME}
            COMMAND FileOp.exe ${arg_ARGS}
        )
            set_property(
                TEST ${arg_NAME}
                PROPERTY WILL_FAIL ${arg_WILL_FAIL}
                PROPERTY FAIL_REGULAR_EXPRESSION ${arg_FAIL_REGULAR_EXPRESSION}
                PROPERTY PASS_REGULAR_EXPRESSION ${arg_PASS_REGULAR_EXPRESSION}
            )

        if (arg_FILE_EXIST)
            foreach(FILE ${arg_FILE_EXIST})
                add_test(
                    NAME ${arg_NAME}_${FILE}
                    COMMAND dir /T:W ${FILE}
                    DEPENDS ${arg_NAME}
                )
                    set_property(
                        TEST ${arg_NAME}_${FILE}
                        PROPERTY PASS_REGULAR_EXPRESSION ${arg_FILE_TIMESTAMP}
                    )
            endforeach()
        endif ()

        if (arg_FILE_NOT_EXIST)
            foreach(FILE ${arg_FILE_NOT_EXIST})
                add_test(
                    NAME ${arg_NAME}_${FILE}
                    COMMAND dir /T:W ${FILE}
                    DEPENDS ${arg_NAME}
                )
                    set_property(
                        TEST ${arg_NAME}_${FILE}
                        WILL_FAIL true
                        PROPERTY PASS_REGULAR_EXPRESSION ${arg_FILE_TIMESTAMP}
                    )
            endforeach()
        endif ()
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
            PASS_REGULAR_EXPRESSION ${arg_HELP_REGULAR_EXPRESSION}
        )
        test_fileop(
            NAME Run_${arg_COMMAND}_WithOptionH
            ARGS ${arg_COMMAND} -h
            PASS_REGULAR_EXPRESSION ${arg_HELP_REGULAR_EXPRESSION}
        )
        test_fileop(
            NAME Run_${arg_COMMAND}_WithNoArguments
            ARGS ${arg_COMMAND}
            WILL_FAIL
            PASS_REGULAR_EXPRESSION "FileOp\.exe: error: Too view arguments given\."
        )
        test_fileop(
            NAME Run_${arg_COMMAND}_WithUnknownSlashOption
            ARGS ${arg_COMMAND} -x
            WILL_FAIL
            PASS_REGULAR_EXPRESSION "FileOp\.exe: error: Unknown option -x, use option --help for more information\."
        )
        test_fileop(
            NAME Run_${arg_COMMAND}_WithUnknownSlashSlashOption
            ARGS ${arg_COMMAND} --xxx
            WILL_FAIL
            PASS_REGULAR_EXPRESSION "FileOp\.exe: error: Unknown option --xxx, use option --help for more information\."
        )
        test_fileop(
            NAME Run_${arg_COMMAND}_WithLonesomeDash
            ARGS --debug ${arg_COMMAND} -- --xxx
            WILL_FAIL
            PASS_REGULAR_EXPRESSION "-- detected, stop option parsing\."
        )

        if (arg_TEST_TIME_OPTION)
            test_fileop(
                NAME Run_${arg_COMMAND}_TimeWithoutValue
                ARGS ${arg_COMMAND} --time
                WILL_FAIL
                PASS_REGULAR_EXPRESSION "FileOp\.exe: error: Option --time needs an argument\."
            )
            test_fileop(
                NAME Run_${arg_COMMAND}_TimeWithWrongFormatI
                ARGS ${arg_COMMAND} --time 2001-01
                WILL_FAIL
                PASS_REGULAR_EXPRESSION "FileOp\.exe: error: Wrong format for time 2001-01, expected yyyy-mm-dd\\[Thh:mm\\[:ss\\]\\]\."
            )
            test_fileop(
                NAME Run_${arg_COMMAND}_TimeWithWrongFormatII
                ARGS ${arg_COMMAND} --time 2001-01-01T12
                WILL_FAIL
                PASS_REGULAR_EXPRESSION "FileOp\.exe: error: Wrong format for time 2001-01-01T12, expected yyyy-mm-dd\\[Thh:mm\\[:ss\\]\\]\."
            )
        endif()
    endfunction()

    ################################# Base tests #################################
    test_fileop(
        NAME Run_WithNoArguments
        WILL_FAIL
        PASS_REGULAR_EXPRESSION "No command given. Use option --help."
    )

    test_fileop(
        NAME Run_WithOptionHelp
        ARGS --help
        PASS_REGULAR_EXPRESSION "FileOp\.exe \\[<options>\\] \\[<command> \\[<options>\\] <argument\\+>\\]"
    )

    test_fileop(
        NAME Run_WithUnknownCommand
        ARGS unknown
        PASS_REGULAR_EXPRESSION "FileOp\.exe: error: Unknown command 'unknown' given, use option --help for more information."
    )

    include(OperationCat.cmake)
    include(OperationCopy.cmake)
    include(OperationMkdir.cmake)
    include(OperationMove.cmake)
    include(OperationRemove.cmake)
    include(OperationTouch.cmake)
