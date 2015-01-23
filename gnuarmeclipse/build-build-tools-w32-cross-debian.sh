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

OUTFILE_VERSION="2.2"

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
    rm -rf "${BUILDTOOLS_BUILD_FOLDER}"
    rm -rf "${BUILDTOOLS_INSTALL_FOLDER}"

    # exit 0
    # Continue with build
  fi
fi

# Create the work folder.
mkdir -p "${BUILDTOOLS_WORK}"

# Always clear the destination folder, to have a consistent package.
rm -rfv "${BUILDTOOLS_INSTALL_FOLDER}/build-tools"

# To simplify the script, we do not build the libraries, but use them form 
# the open source MSYS2 project.
# https://sourceforge.net/projects/msys2/
# From this project the binary executable and DLLs will be directly 
# copied to the setup.

MSYS2_PACK_URL_BASE="http://sourceforge.net/projects/msys2/files"

# https://sourceforge.net/projects/msys2/files/Base/i686/

MSYS2_PACK_VERSION="20141113"
MSYS2_PACK_ARCH="msys2-base-i686-${MSYS2_PACK_VERSION}.tar.xz"
MSYS2_PACK_URL="${MSYS2_PACK_URL_BASE}/Base/i686/${MSYS2_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS2_PACK_URL}" \
  "${WGET_OUT}" "${MSYS2_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/echo.exe" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/echo.exe" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/rm.exe" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/sh.exe" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/rebase.exe" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/msys-2.0.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/msys-crypt-0.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/msys-ffi-6.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/msys-gcc_s-1.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/msys-gmp-10.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/msys-iconv-2.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/msys32/usr/bin/msys-intl-8.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

# http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/i686/make-4.1-2-i686.pkg.tar.xz

MSYS2_PACK_VERSION="4.1-2"
MSYS2_PACK_ARCH="make-${MSYS2_PACK_VERSION}-i686.pkg.tar.xz"
MSYS2_PACK_URL="${MSYS2_PACK_URL_BASE}/REPOS/MSYS2/i686/${MSYS2_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS2_PACK_URL}" \
  "${WGET_OUT}" "${MSYS2_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/usr/bin/make.exe" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/usr/bin/make.exe" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

# http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/i686/libltdl-2.4.5-1-i686.pkg.tar.xz

MSYS2_PACK_VERSION="2.4.5-1"
MSYS2_PACK_ARCH="libltdl-${MSYS2_PACK_VERSION}-i686.pkg.tar.xz"
MSYS2_PACK_URL="${MSYS2_PACK_URL_BASE}/REPOS/MSYS2/i686/${MSYS2_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS2_PACK_URL}" \
  "${WGET_OUT}" "${MSYS2_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/usr/bin/msys-ltdl-7.dll" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/usr/bin/msys-ltdl-7.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

# http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/i686/libunistring-0.9.4-2-i686.pkg.tar.xz/download

MSYS2_PACK_VERSION="0.9.4-2"
MSYS2_PACK_ARCH="libunistring-${MSYS2_PACK_VERSION}-i686.pkg.tar.xz"
MSYS2_PACK_URL="${MSYS2_PACK_URL_BASE}/REPOS/MSYS2/i686/${MSYS2_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS2_PACK_URL}" \
  "${WGET_OUT}" "${MSYS2_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/usr/bin/msys-unistring-2.dll" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/usr/bin/msys-unistring-2.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

# http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/i686/libguile-2.0.11-3-i686.pkg.tar.xz/download

MSYS2_PACK_VERSION="2.0.11-3"
MSYS2_PACK_ARCH="libguile-${MSYS2_PACK_VERSION}-i686.pkg.tar.xz"
MSYS2_PACK_URL="${MSYS2_PACK_URL_BASE}/REPOS/MSYS2/i686/${MSYS2_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS2_PACK_URL}" \
  "${WGET_OUT}" "${MSYS2_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/usr/bin/msys-guile-2.0-22.dll" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/usr/bin/msys-guile-2.0-22.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

# http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/i686/libgc-7.2.d-1-i686.pkg.tar.xz/download

MSYS2_PACK_VERSION="7.2.d-1"
MSYS2_PACK_ARCH="libgc-${MSYS2_PACK_VERSION}-i686.pkg.tar.xz"
MSYS2_PACK_URL="${MSYS2_PACK_URL_BASE}/REPOS/MSYS2/i686/${MSYS2_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS2_PACK_URL}" \
  "${WGET_OUT}" "${MSYS2_PACK_ARCH}"
fi

if [ ! -f "${BUILDTOOLS_INSTALL_FOLDER}/msys/usr/bin/msys-gc-1.dll" ]
then
  mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/msys"
  cd "${BUILDTOOLS_INSTALL_FOLDER}/msys"

  tar -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_PACK_ARCH}"
fi

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"

cp -v "${BUILDTOOLS_INSTALL_FOLDER}/msys/usr/bin/msys-gc-1.dll" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/usr/bin"


# Copy license files
mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}/msys/license"
cd "${BUILDTOOLS_DOWNLOAD_FOLDER}/msys/license"

for N in 'COPYING' 'COPYING.LIB' 'COPYING.LIBGLOSS' 'COPYING.NEWLIB' 'COPYING3' 'COPYING3.LIB' 'README'
do
  if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/msys/license/${N}" ]
  then
    "${WGET}" "https://sourceforge.net/p/msys2/code/ci/master/tree/${N}?format=raw" \
      "${WGET_OUT}" "${BUILDTOOLS_DOWNLOAD_FOLDER}/msys/license/${N}"
  fi
done

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/msys2"
cp -v "${BUILDTOOLS_DOWNLOAD_FOLDER}/msys/license/"* \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/msys2"


# Convert all text files to DOS.
find "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license" -type f \
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

mkdir -p "${BUILDTOOLS_BUILD_FOLDER}"
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
  echo "File ${BUILDTOOLS_SETUP} created."
else
  echo "Build failed."
fi

exit 0
