#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Script to cross build the 32-bit Windows version of Build Tools on Debian.

# Prerequisites:
#
# sudo apt-get install git nsis

# ----- Externally configurable variables -----

# The folder where the entire build procedure will run.
# If you prefer to build in a separate folder, define it before invoking
# the script.
if [ -d /media/Work ]
then
  BUILDTOOLS_WORK=${BUILDTOOLS_WORK:-"/media/Work/build-tools"}
else
  BUILDTOOLS_WORK=${BUILDTOOLS_WORK:-"${HOME}/Work/build-tools"}
fi

# The UTC date part in the name of the archive. 
NDATE=${NDATE:-$(date -u +%Y%m%d%H%M)}

# ----- Local variables -----

OUTFILE_VERSION="2.1"

BUILDTOOLS_TARGET="win32"

BUILDTOOLS_GIT_FOLDER="${BUILDTOOLS_WORK}/gnuarmeclipse-build-tools.git"
BUILDTOOLS_DOWNLOAD_FOLDER="${BUILDTOOLS_WORK}/download"
BUILDTOOLS_BUILD_FOLDER="${BUILDTOOLS_WORK}/build/${BUILDTOOLS_TARGET}"
BUILDTOOLS_INSTALL_FOLDER="${BUILDTOOLS_WORK}/install/${BUILDTOOLS_TARGET}"
BUILDTOOLS_OUTPUT="${BUILDTOOLS_WORK}/output"

WGET="wget"
WGET_OUT="-O"

ACTION=${1:-}

if [ $# > 0 ]
then
  if [ "${ACTION}" == "clean" ]
  then
    # Remove most build and temporary folders
    rm -rfv "${BUILDTOOLS_BUILD_FOLDER}"
    rm -rfv "${BUILDTOOLS_INSTALL_FOLDER}"

    # exit 0
    # Continue with build
  fi
fi

# Create the work folder.
mkdir -p "${BUILDTOOLS_WORK}"

# Always clear the destination folder, to have a consistent package.
rm -rfv "${BUILDTOOLS_INSTALL_FOLDER}/build-tools"

# To simplify the script, we do not build the libraries, but use them form 
# the open source MinGW project.
# https://sourceforge.net/projects/mingw/
# From this archive the binary DLLs will be directly copied to the setup.

MSYS_PACK_URL_BASE="http://sourceforge.net/projects/mingw/files/MSYS/Base"

# http://sourceforge.net/projects/mingw/files/MSYS/Base/msys-core/msys-1.0.18-1/

MSYS_VERSION="1.0.18"
MSYS_VERSION_RELEASE="${MSYS_VERSION}-1"
MSYS_PACK_ARCH="msysCORE-${MSYS_VERSION_RELEASE}-msys-${MSYS_VERSION}-bin.tar.lzma"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/msys-core/msys-${MSYS_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/msys-1.0.dll" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar --lzma -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/msys-1.0.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"

MSYS_PACK_ARCH="msysCORE-${MSYS_VERSION_RELEASE}-msys-${MSYS_VERSION}-lic.tar.lzma"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/msys-core/msys-${MSYS_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/MSYS_LICENSE.rtf" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar --lzma -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/MSYS"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/COPYING" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/MSYS"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/COPYING.LIB" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/MSYS"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/CYGWIN_LICENSE" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/MSYS"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/MSYS_LICENSE.rtf" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/MSYS"

MSYS_PACK_ARCH="msysCORE-${MSYS_VERSION_RELEASE}-msys-${MSYS_VERSION}-doc.tar.lzma"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/msys-core/msys-${MSYS_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/README.rtf" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar --lzma -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/MSYS"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/MSYS_MISSION" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/MSYS"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/MSYS_VS_CYGWIN" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/MSYS"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/MSYS_WELCOME.rtf" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/MSYS"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/README.rtf" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/MSYS"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/msysCORE-1.0.18-1-msys-RELEASE_NOTES.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/MSYS"


# https://sourceforge.net/projects/mingw/files/MSYS/Base/make/make-3.81-3/

MSYS_VERSION="1.0.13"
MSYS_PACK_NAME="make"
MSYS_PACK_VERSION="3.81"
MSYS_PACK_VERSION_RELEASE="${MSYS_PACK_VERSION}-3"
MSYS_PACK_ARCH="make-${MSYS_PACK_VERSION_RELEASE}-msys-${MSYS_VERSION}-bin.tar.lzma"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/${MSYS_PACK_NAME}/${MSYS_PACK_NAME}-${MSYS_PACK_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/make.exe" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar --lzma -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/make.exe" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"

MSYS_PACK_ARCH="make-${MSYS_PACK_VERSION_RELEASE}-msys-${MSYS_VERSION}-doc.tar.lzma"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/${MSYS_PACK_NAME}/${MSYS_PACK_NAME}-${MSYS_PACK_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/make/${MSYS_PACK_VERSION}/README" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar --lzma -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/make"
cp -rv "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/make/${MSYS_PACK_VERSION}/"* \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/make"
cp -rv "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/make-${MSYS_PACK_VERSION_RELEASE}-msys.RELEASE_NOTES.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/make"


# https://sourceforge.net/projects/mingw/files/MSYS/Base/bash/bash-3.1.23-1/

MSYS_VERSION="1.0.18"
MSYS_PACK_NAME="bash"
MSYS_PACK_VERSION="3.1.23"
MSYS_PACK_VERSION_RELEASE="${MSYS_PACK_VERSION}-1"
MSYS_PACK_ARCH="bash-${MSYS_PACK_VERSION_RELEASE}-msys-${MSYS_VERSION}-bin.tar.xz"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/${MSYS_PACK_NAME}/${MSYS_PACK_NAME}-${MSYS_PACK_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/sh.exe" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar -xJvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/sh.exe" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"

MSYS_PACK_ARCH="bash-${MSYS_PACK_VERSION_RELEASE}-msys-${MSYS_VERSION}-doc.tar.xz"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/${MSYS_PACK_NAME}/${MSYS_PACK_NAME}-${MSYS_PACK_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/bash/${MSYS_PACK_VERSION}/README" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar -xJvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/bash"
cp -rv "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/bash/${MSYS_PACK_VERSION}/"* \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/bash"
cp -rv "${BUILDTOOLS_INSTALL_FOLDER}/msys/share/doc/MSYS/bash-${MSYS_PACK_VERSION_RELEASE}-msys.RELEASE_NOTES.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc/bash"


# https://sourceforge.net/projects/mingw/files/MSYS/Base/coreutils/coreutils-5.97-3/

MSYS_VERSION="1.0.13"
MSYS_PACK_NAME="coreutils"
MSYS_PACK_VERSION="5.97"
MSYS_PACK_VERSION_RELEASE="${MSYS_PACK_VERSION}-3"
MSYS_PACK_ARCH="coreutils-${MSYS_PACK_VERSION_RELEASE}-msys-${MSYS_VERSION}-bin.tar.lzma"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/${MSYS_PACK_NAME}/${MSYS_PACK_NAME}-${MSYS_PACK_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/rm.exe" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar --lzma -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/rm.exe" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/echo.exe" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"


# https://sourceforge.net/projects/mingw/files/MSYS/Base/termcap/termcap-0.20050421_1-2/

MSYS_VERSION="1.0.13"
MSYS_PACK_NAME="termcap"
MSYS_PACK_VERSION="0.20050421_1"
MSYS_PACK_VERSION_RELEASE="${MSYS_PACK_VERSION}-2"
MSYS_PACK_ARCH="libtermcap-${MSYS_PACK_VERSION_RELEASE}-msys-${MSYS_VERSION}-dll-0.tar.lzma"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/${MSYS_PACK_NAME}/${MSYS_PACK_NAME}-${MSYS_PACK_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/msys-termcap-0.dll" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar --lzma -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/msys-termcap-0.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"


# https://sourceforge.net/projects/mingw/files/MSYS/Base/gettext/gettext-0.18.1.1-1/

MSYS_VERSION="1.0.17"
MSYS_PACK_NAME="gettext"
MSYS_PACK_VERSION="0.18.1.1"
MSYS_PACK_VERSION_RELEASE="${MSYS_PACK_VERSION}-1"
MSYS_PACK_ARCH="libintl-${MSYS_PACK_VERSION_RELEASE}-msys-${MSYS_VERSION}-dll-8.tar.lzma"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/${MSYS_PACK_NAME}/${MSYS_PACK_NAME}-${MSYS_PACK_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/msys-intl-8.dll" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar --lzma -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/msys-intl-8.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"


# https://sourceforge.net/projects/mingw/files/MSYS/Base/libiconv/libiconv-1.14-1/

MSYS_VERSION="1.0.17"
MSYS_PACK_NAME="libiconv"
MSYS_PACK_VERSION="1.14"
MSYS_PACK_VERSION_RELEASE="${MSYS_PACK_VERSION}-1"
MSYS_PACK_ARCH="libiconv-${MSYS_PACK_VERSION_RELEASE}-msys-${MSYS_VERSION}-dll-2.tar.lzma"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/${MSYS_PACK_NAME}/${MSYS_PACK_NAME}-${MSYS_PACK_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/msys-iconv-2.dll" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar --lzma -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/msys-iconv-2.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"


# https://sourceforge.net/projects/mingw/files/MSYS/Base/regex/regex-1.20090805-2/

MSYS_VERSION="1.0.13"
MSYS_PACK_NAME="regex"
MSYS_PACK_VERSION="1.20090805"
MSYS_PACK_VERSION_RELEASE="${MSYS_PACK_VERSION}-2"
MSYS_PACK_ARCH="libregex-${MSYS_PACK_VERSION_RELEASE}-msys-${MSYS_VERSION}-dll-1.tar.lzma"
MSYS_PACK_URL="${MSYS_PACK_URL_BASE}/${MSYS_PACK_NAME}/${MSYS_PACK_NAME}-${MSYS_PACK_VERSION_RELEASE}/${MSYS_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS_PACK_URL}" \
  "${WGET_OUT}" "${MSYS_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/msys-regex-1.dll" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar --lzma -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/bin/msys-regex-1.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"


# Get the GNU ARM Eclipse OpenOCD git repository.

# The custom OpenOCD branch is available from the dedicated Git repository
# which is part of the GNU ARM Eclipse project hosted on SourceForge.
# Generally this branch follows the official OpenOCD master branch, 
# with updates after every OpenOCD public release.

if [ ! -d "${BUILDTOOLS_GIT_FOLDER}" ]
then
  cd "${BUILDTOOLS_WORK}"

  if [ "$(whoami)" == "ilg" ]
  then
    # Shortcut for ilg, who has full access to the repo.
    git clone ssh://ilg-ul@git.code.sf.net/p/gnuarmeclipse/build-tools gnuarmeclipse-build-tools.git
  else
    # For regular read/only access, use the git url.
    git clone http://git.code.sf.net/p/gnuarmeclipse/build-tools gnuarmeclipse-build-tools.git
  fi
fi

# Convert all text files to DOS.
find "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license" -type f \
-exec unix2dos {} \;
find "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/doc" -type f \
-exec unix2dos {} \;

# Copy the GNU ARM Eclipse info files.
mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/build-build-tools-w32-cross-debian.sh" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/build-build-tools-w32-cross-debian.sh"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/INFO.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/INFO.txt"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/INFO.txt"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/BUILD.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/BUILD.txt"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/BUILD.txt"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/CHANGES.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/CHANGES.txt"

# Not passed as it, used by makensis for the MUI_PAGE_LICENSE; must be DOS.
cp -v "${BUILDTOOLS_GIT_FOLDER}/COPYING" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/COPYING"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/COPYING"

# Create the distribution setup.

mkdir -p "${BUILDTOOLS_OUTPUT}"

NSIS_FOLDER="${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/nsis"
NSIS_FILE="${NSIS_FOLDER}/gnuarmeclipse-build-tools.nsi"

BUILDTOOLS_SETUP="${BUILDTOOLS_OUTPUT}/gnuarmeclipse-build-tools-${BUILDTOOLS_TARGET}-${OUTFILE_VERSION}-${NDATE}-setup.exe"

mkdir -p cd "${BUILDTOOLS_BUILD_FOLDER}"
cd "${BUILDTOOLS_BUILD_FOLDER}"
echo
makensis -V4 -NOCD \
-DINSTALL_FOLDER="${BUILDTOOLS_INSTALL_FOLDER}/build-tools" \
-DNSIS_FOLDER="${NSIS_FOLDER}" \
-DOUTFILE="${BUILDTOOLS_SETUP}" \
"${NSIS_FILE}"
RESULT="$?"

echo
if [ "${RESULT}" == "0" ]
then
  echo "Build completed."
else
  echo "Build failed."
fi

exit 0
