
# Changelog

<!-- cspell:ignore INFDTEP -->

## Unreleased

- First release under BSD 3-Clause License.
- Use CMake and cross compiling with gcc-12.

## 1.8.0

- INFDTEP-2374
  - Always use English system error messages.
- INFDTEP-2099
  - Add check for unique file names

## 1.7.3

- INFDTEP-2128
  - Fix crash if tool is called with /.

## 1.7.2

- INFDTEP-2097
  - Fix handling of response files bigger than buffer (0x1FFFF).

## 1.7.1

- INFDTEP-2088
  - Fix option `--touch` for `copy` and `move` command. If several
    files are copied or moved the target file of the operation was
    always the first target file.

## 1.7.0

- INFDTEP-1729
  - Add batch to tag tool.
  - Fix link to pull request.
- INFDTEP-1992
  - Add support for response files.
- INFDTEP-2081
  - Add touch command.
  - Add option `--touch` to `copy` and `move` commands.
  - Restructure tests.

## 1.6.1

- INFDTEP-1550
  - Fix crash if given command is unknown.

## 1.6.0

- INFDTEP-1424
  - Remove the flush of the buffer in the cat command.

## 1.5.0

- INFDTEP-1404
  - Implement option `--target-directory`.
  - Internal redesign: Put each command into a single source file.

## 1.4.0

- INFDTEP-1349
  - Implement `cat`, `type` and `move` command.

- INFDTEP-1350
  - Update to new version of 000_ToolCommon.

## 1.3.0

- INFDTEP-1261
  - Update help output and change documentation to markdown file.

- INFDTEP-1262
  - Add Jenkinsfile and shell scripts to build.

## 1.2.0

- INFDTEP-1140

  - Add support for reparse points (junctions).
  - The `remove` command removes the reparse point. The `copy` command copies the content of the reparse point.

## 1.1.0

- INFDTEP-1077
  - Add support for wildcard in paths except `mkdir` command and the target for the `copy` command.
  - Add version information to PE header of executable.

## 1.0.0

- INFDTEP-1058
  - First implementation of FileOp.exe.
