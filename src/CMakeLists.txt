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