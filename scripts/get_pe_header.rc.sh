#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

CurrentDate=$(date)
CurrentYear=$(date --date="${CurrentDate}" +%Y)
FileVersion=$(date --date="${CurrentDate}" +%Y,%-m,%-d,%H%M)
FileVersionInfoString=$(date --date="${CurrentDate}" +%Y.%m.%d.%H%M)
GitCommitSha=$(git rev-parse HEAD)
GitRemoteUrl=$(git remote get-url origin)
ReleaseTag=$(${THIS_DIRECTORY}/get_version.sh)

# cspell:disable
echo """
#include <windows.h>

VS_VERSION_INFO VERSIONINFO
FILEVERSION    	${FileVersion}
PRODUCTVERSION 	$(echo "${ReleaseTag}" | sed -e "s/\./,/g"),0
FILEFLAGSMASK  	VS_FFI_FILEFLAGSMASK
FILEFLAGS      	VS_FF_DEBUG
FILEOS         	VOS_NT_WINDOWS32
FILETYPE       	VFT_APP
FILESUBTYPE    	VFT2_UNKNOWN
BEGIN
   BLOCK \"StringFileInfo\"
   BEGIN
      BLOCK \"040904E4\"
      BEGIN
         VALUE \"CompanyName\",      \"FileOp authors\"
         VALUE \"FileDescription\",  \"Program for basic file operations\"
         VALUE \"FileVersion\",      \"${FileVersionInfoString}\"
         VALUE \"InternalName\",     \"$(echo ${GitRemoteUrl} | sed -e 's|\.git|/tree/|')${GitCommitSha}\"
         VALUE \"LegalCopyright\",   \"FileOp authors, 2020-${CurrentYear}\"
         VALUE \"OriginalFilename\", \"FileOp.exe\"
         VALUE \"ProductVersion\",   \"${ReleaseTag}.0\"
      END
   END

   BLOCK \"VarFileInfo\"
   BEGIN
      /* The following line should only be modified for localized versions.     */
      /* It consists of any number of WORD,WORD pairs, with each pair           */
      /* describing a language,codepage combination supported by the file.      */
      /*                                                                        */
      /* For example, a file might have values "0x409,1252" indicating that it  */
      /* supports English language (0x409) in the Windows ANSI codepage (1252). */
      VALUE \"Translation\", 0x409, 1252
   END
END
"""
# cspell:enable
