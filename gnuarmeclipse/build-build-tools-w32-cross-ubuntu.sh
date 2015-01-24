#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Script to cross build the 32-bit Windows version of Build Tools on Ubuntu.

# Prerequisites:
#
# sudo apt-get install git libtool autoconf automake autotools-dev pkg-config
# sudo apt-get install texinfo texlive dos2unix nsis
# sudo apt-get install mingw-w64 mingw-w64-tools mingw-w64-i686-dev 
# sudo apt-get install autopoint gettext

# ----- Externally configurable variables -----

# The folder where the entire build procedure will run.
# If you prefer to build in a separate folder, define it before invoking
# the script.
if [ -d "/media/${USER}/Work" ]
then
  BUILDTOOLS_WORK=${BUILDTOOLS_WORK:-"/media/${USER}/Work/build-tools"}
else
  BUILDTOOLS_WORK=${BUILDTOOLS_WORK:-"${HOME}/Work/build-tools"}
fi

# The UTC date part in the name of the archive. 
NDATE=${NDATE:-$(date -u +%Y%m%d%H%M)}

# ----- Local variables -----

OUTFILE_VERSION="2.3"

CROSS_COMPILE="i686-w64-mingw32"
BUILDTOOLS_TARGET="win32"

BUILDTOOLS_GIT_FOLDER="${BUILDTOOLS_WORK}/gnuarmeclipse-build-tools.git"
BUILDTOOLS_DOWNLOAD_FOLDER="${BUILDTOOLS_WORK}/download"
BUILDTOOLS_BUILD_FOLDER="${BUILDTOOLS_WORK}/build/${BUILDTOOLS_TARGET}"
BUILDTOOLS_INSTALL_FOLDER="${BUILDTOOLS_WORK}/install/${BUILDTOOLS_TARGET}"
BUILDTOOLS_OUTPUT="${BUILDTOOLS_WORK}/output"

WGET="wget"
WGET_OUT="-O"

ACTION=${1:-}

if [ $# -gt 0 ]
then
  if [ "${ACTION}" == "clean" ]
  then
    # Remove most build and temporary folders
    rm -rf "${BUILDTOOLS_BUILD_FOLDER}"
    rm -rf "${BUILDTOOLS_INSTALL_FOLDER}"
    rm -rf "${BUILDTOOLS_WORK}/msys2"
    rm -rf "${BUILDTOOLS_WORK}/make-"*
	
    # exit 0
    # Continue with build
  fi
fi

# Test if various tools are present
${CROSS_COMPILE}-gcc --version
unix2dos --version
git --version
makensis -VERSION

# Create the work folder.
mkdir -p "${BUILDTOOLS_WORK}"

# Always clear the destination folder, to have a consistent package.
rm -rfv "${BUILDTOOLS_INSTALL_FOLDER}/build-tools"

# Get the GNU ARM Eclipse Build Tools git repository.

# The Build Tools Git is available from the dedicated Git repository
# which is part of the GNU ARM Eclipse project hosted on SourceForge.

if [ ! -d "${BUILDTOOLS_GIT_FOLDER}" ]
then
  cd "${BUILDTOOLS_WORK}"

  if [ "${USER}" == "ilg" ]
  then
    # Shortcut for ilg, who has full access to the repo.
    git clone ssh://ilg-ul@git.code.sf.net/p/gnuarmeclipse/build-tools gnuarmeclipse-build-tools.git
  else
    # For regular read/only access, use the git url.
    git clone http://git.code.sf.net/p/gnuarmeclipse/build-tools gnuarmeclipse-build-tools.git
  fi
fi

# The make executable is built using the source package from  
# the open source MSYS2 project.
# https://sourceforge.net/projects/msys2/

MSYS2_MAKE_PACK_URL_BASE="http://sourceforge.net/projects/msys2/files"

# http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/make-4.1-2.src.tar.gz/download

MAKE_VERSION="4.1"

MSYS2_MAKE_VERSION_RELEASE="${MAKE_VERSION}-2"
MSYS2_MAKE_PACK_ARCH="make-${MSYS2_MAKE_VERSION_RELEASE}.src.tar.gz"
MSYS2_MAKE_PACK_URL="${MSYS2_MAKE_PACK_URL_BASE}/REPOS/MSYS2/Sources/${MSYS2_MAKE_PACK_ARCH}"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_MAKE_PACK_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${MSYS2_MAKE_PACK_URL}" \
  "${WGET_OUT}" "${MSYS2_MAKE_PACK_ARCH}"
fi

MAKE_ARCH="make-${MAKE_VERSION}.tar.bz2"
if [ ! -f "${BUILDTOOLS_WORK}/msys2/make/${MAKE_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_WORK}/msys2"
  cd "${BUILDTOOLS_WORK}/msys2"

  tar -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_MAKE_PACK_ARCH}"
fi

if [ ! -d "${BUILDTOOLS_WORK}/make-${MAKE_VERSION}" ]
then
  mkdir -p "${BUILDTOOLS_WORK}"
  cd "${BUILDTOOLS_WORK}"

  tar -xvf "${BUILDTOOLS_WORK}/msys2/make/${MAKE_ARCH}"

  cd "${BUILDTOOLS_WORK}/make-${MAKE_VERSION}"
  patch -p1 -i "${BUILDTOOLS_WORK}/msys2/make/make-autoconf.patch"
  autoreconf -fi
fi

mkdir -p "${BUILDTOOLS_BUILD_FOLDER}/make-${MAKE_VERSION}"
cd "${BUILDTOOLS_BUILD_FOLDER}/make-${MAKE_VERSION}"

"${BUILDTOOLS_WORK}/make-${MAKE_VERSION}/configure" \
--host=${CROSS_COMPILE} \
--prefix="${BUILDTOOLS_INSTALL_FOLDER}/make-${MAKE_VERSION}"  \
--without-libintl-prefix \
--without-libiconv-prefix \
ac_cv_dos_paths=yes

make clean all install-strip

mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/make-${MAKE_VERSION}/bin/make.exe" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"

# Copy make license files
mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/make"
cp -v "${BUILDTOOLS_WORK}/make-${MAKE_VERSION}/COPYING" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/make"
cp -v "${BUILDTOOLS_WORK}/make-${MAKE_VERSION}/README"* \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/make"
cp -v "${BUILDTOOLS_WORK}/make-${MAKE_VERSION}/NEWS" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/make"

# Get BusyBox

# http://intgat.tigress.co.uk/rmy/busybox/index.html

BUSYBOX_URL="ftp://ftp.tigress.co.uk/pub/gpl/6.0.0/busybox/busybox.exe"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/busybox.exe" ]
then
  mkdir -p "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"

  "${WGET}" "${BUSYBOX_URL}" \
  "${WGET_OUT}" "busybox.exe"
fi

# Copy BusyBox with 3 different names
mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_DOWNLOAD_FOLDER}/busybox.exe" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin/sh.exe"
cp -v "${BUILDTOOLS_DOWNLOAD_FOLDER}/busybox.exe" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin/rm.exe"
cp -v "${BUILDTOOLS_DOWNLOAD_FOLDER}/busybox.exe" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin/echo.exe"


# Convert all text files to DOS.
find "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license" -type f \
-exec unix2dos {} \;

# Copy the GNU ARM Eclipse info files.
mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/build-build-tools-w32-cross-ubuntu.sh" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/build-build-tools-w32-cross-ubuntu.sh"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/INFO.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/INFO.txt"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/INFO.txt"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/BUILD.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/BUILD.txt"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/BUILD.txt"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/CHANGES.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/CHANGES.txt"

# Not passed as is, used by makensis for the MUI_PAGE_LICENSE; must be DOS.
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

