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
        set(oneValueArgs NAME)
        set(multiValueArgs ARGS FAIL_REGULAR_EXPRESSION PASS_REGULAR_EXPRESSION)
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

    test_fileop(
        NAME RunWithNoArguments
        WILL_FAIL
        PASS_REGULAR_EXPRESSION "No command given. Use option --help."
    )

    test_fileop(
        NAME RunWithOptionHelp
        ARGS --help
        PASS_REGULAR_EXPRESSION "FileOp\\.exe \\[<options>\\] \\[<command> \\[<options>\\] <argument\\+>\\]"
    )

    test_fileop(
        NAME RunWithOptionH
        ARGS -h
        PASS_REGULAR_EXPRESSION "FileOp\\.exe \\[<options>\\] \\[<command> \\[<options>\\] <argument\\+>\\]"
    )

    test_fileop(
        NAME RunWithUnknownCommand
        ARGS unknown
        PASS_REGULAR_EXPRESSION "FileOp\\.exe: error: Unknown command 'unknown' given, use option --help for more information."
    )
