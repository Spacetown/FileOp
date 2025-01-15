
# FileOp

Tool for general file operations under Windows with support of file names longer than MAX_PATH (260 characters).

## Background

Windows command line tools only support paths with a maximum length of 260 characters.
As workaround you need to subst the directory to a drive letter and delete the sub
tree from there.

## Directory layout

dir     | description
---     | ---
`build` | *ignored*: Storage of build-results
`src`   | Storage for source files
`tests` | Storage for test scripts

## Development

For development a workspace for `Visual Studio Code` is configured together with a cross compiler
running under docker.

### Build

The project uses CMake and ninja for building the executable. The CMake configuration step is executed by
calling [scripts/cmake.configure.sh](./scripts/cmake.configure.sh) and the build by calling
[scripts/cmake.build.sh](./scripts/cmake.build.sh). In the status bar of the IDE there are buttons to
execute the tools.

### Test

To test the generated artifacts call `.\tools\test.cmd` or use `Terminal`->`Run Task...`->`Test` in the IDE.
