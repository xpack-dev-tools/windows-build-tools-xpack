#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Script to cross build the 32/64-bit Windows version of Build Tools 
# with MinGW-w64 on GNU/Linux.
# Developed on Ubuntu 14.04 LTS.

# Note: the 64-bit is not yet functional, BusyBox sh.exe fails.

# Prerequisites:
#
# sudo apt-get install git libtool autoconf automake autotools-dev pkg-config
# sudo apt-get install texinfo texlive dos2unix nsis
# sudo apt-get install mingw-w64 mingw-w64-tools mingw-w64-i686-dev 
# sudo apt-get install autopoint gettext

# ----- Parse actions and command line options -----

ACTION_CLEAN=""
ACTION_PULL=""
TARGET_BITS="32"

while [ $# -gt 0 ]
do
  if [ "$1" == "clean" ]
  then
    ACTION_CLEAN="$1"
  elif [ "$1" == "pull" ]
  then
    ACTION_PULL="$1"
  elif [ "$1" == "-32" -o "$1" == "-m32" -o "$1" == "-w32" ]
  then
    TARGET_BITS="32"
  elif [ "$1" == "-64" -o "$1" == "-m64" -o "$1" == "-w64" ]
  then
    TARGET_BITS="64"
  else
    echo "Unknown action/option $1"
    exit 1
  fi

  shift
done

# ----- Externally configurable variables -----

# The folder where the entire build procedure will run.
# If you prefer to build in a separate folder, define it before invoking
# the script.
if [ -d "/media/${USER}/Work" ]
then
  BUILDTOOLS_WORK_FOLDER=${BUILDTOOLS_WORK_FOLDER:-"/media/${USER}/Work/build-tools"}
elif [ -d /media/Work ]
then
  BUILDTOOLS_WORK_FOLDER=${BUILDTOOLS_WORK_FOLDER:-"/media/Work/build-tools"}
else
  BUILDTOOLS_WORK_FOLDER=${BUILDTOOLS_WORK_FOLDER:-"${HOME}/Work/build-tools"}
fi

MAKE_JOBS=${MAKE_JOBS:-"-j4"}

# The UTC date part in the name of the archive. 
NDATE=${NDATE:-$(date -u +%Y%m%d%H%M)}

# ----- Local variables -----

OUTFILE_VERSION="2.4"

BUILDTOOLS_TARGET="win${TARGET_BITS}"

BUILDTOOLS_GIT_FOLDER="${BUILDTOOLS_WORK_FOLDER}/gnuarmeclipse-build-tools.git"
BUILDTOOLS_DOWNLOAD_FOLDER="${BUILDTOOLS_WORK_FOLDER}/download"
BUILDTOOLS_BUILD_FOLDER="${BUILDTOOLS_WORK_FOLDER}/build/${BUILDTOOLS_TARGET}"
BUILDTOOLS_INSTALL_FOLDER="${BUILDTOOLS_WORK_FOLDER}/install/${BUILDTOOLS_TARGET}"
BUILDTOOLS_OUTPUT="${BUILDTOOLS_WORK_FOLDER}/output"

WGET="wget"
WGET_OUT="-O"

# Decide which toolchain to use.
if [ ${TARGET_BITS} == "32" ]
then
  CROSS_COMPILE_PREFIX="i686-w64-mingw32"
else
  CROSS_COMPILE_PREFIX="x86_64-w64-mingw32"
fi

# ----- Test if some tools are present -----

echo
echo "Test tools..."
echo
${CROSS_COMPILE_PREFIX}-gcc --version
unix2dos --version
git --version
automake --version
makensis -VERSION
echo

# Process actions.

if [ "${ACTION_CLEAN}" == "clean" ]
then
  # Remove most build and temporary folders.
  echo
  echo "Remove most build folders..."

  # Remove most build and temporary folders
  rm -rf "${BUILDTOOLS_BUILD_FOLDER}"
  rm -rf "${BUILDTOOLS_INSTALL_FOLDER}"
  rm -rf "${BUILDTOOLS_WORK_FOLDER}/msys2"
  rm -rf "${BUILDTOOLS_WORK_FOLDER}/make-"*
  rm -rf "${BUILDTOOLS_WORK_FOLDER}/busybox-w32-"*

  echo
  echo "Clean completed. Proceed with a regular build."
  exit 0
fi

if [ "${ACTION_PULL}" == "pull" ]
then
  if [ -d "${BUILDTOOLS_GIT_FOLDER}" ]
  then
    echo
    if [ "${USER}" == "ilg" ]
    then
      echo "Enter SourceForge password for git pull"
    fi
    cd "${BUILDTOOLS_GIT_FOLDER}"
    git pull

    rm -rf "${BUILDTOOLS_BUILD_FOLDER}"

    echo
    echo "Pull completed. Proceed with a regular build."
    exit 0
  else
	echo "No git folder."
    exit 1
  fi
fi

# Create the work folder.
mkdir -p "${BUILDTOOLS_WORK_FOLDER}"

# Get the GNU ARM Eclipse Build Tools git repository.

# The Build Tools Git is available from the dedicated Git repository
# which is part of the GNU ARM Eclipse project hosted on SourceForge.

if [ ! -d "${BUILDTOOLS_GIT_FOLDER}" ]
then
  cd "${BUILDTOOLS_WORK_FOLDER}"

  if [ "${USER}" == "ilg" ]
  then
    # Shortcut for ilg, who has full access to the repo.
    echo
    echo "Enter SourceForge password for git clone"
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

# http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/
# http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/make-4.1-3.src.tar.gz/download

MAKE_VERSION="4.1"
MSYS2_MAKE_VERSION_RELEASE="${MAKE_VERSION}-3"

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
if [ ! -f "${BUILDTOOLS_WORK_FOLDER}/msys2/make/${MAKE_ARCH}" ]
then
  mkdir -p "${BUILDTOOLS_WORK_FOLDER}/msys2"

  cd "${BUILDTOOLS_WORK_FOLDER}/msys2"
  tar -xvf "${BUILDTOOLS_DOWNLOAD_FOLDER}/${MSYS2_MAKE_PACK_ARCH}"
fi

if [ ! -d "${BUILDTOOLS_WORK_FOLDER}/make-${MAKE_VERSION}" ]
then
  mkdir -p "${BUILDTOOLS_WORK_FOLDER}"

  cd "${BUILDTOOLS_WORK_FOLDER}"
  tar -xvf "${BUILDTOOLS_WORK_FOLDER}/msys2/make/${MAKE_ARCH}"

  cd "${BUILDTOOLS_WORK_FOLDER}/make-${MAKE_VERSION}"
  patch -p1 -i "${BUILDTOOLS_WORK_FOLDER}/msys2/make/make-autoconf.patch"
  autoreconf -fi
fi

# On first run, create the build folder.
mkdir -p "${BUILDTOOLS_BUILD_FOLDER}/make-${MAKE_VERSION}"

if [ ! -f "${BUILDTOOLS_BUILD_FOLDER}/make-${MAKE_VERSION}/config.h" ]
then

  echo
  echo "configure..."

  cd "${BUILDTOOLS_BUILD_FOLDER}/make-${MAKE_VERSION}"
  "${BUILDTOOLS_WORK_FOLDER}/make-${MAKE_VERSION}/configure" \
  --host=${CROSS_COMPILE_PREFIX} \
  --prefix="${BUILDTOOLS_INSTALL_FOLDER}/make-${MAKE_VERSION}"  \
  --without-libintl-prefix \
  --without-libiconv-prefix \
  ac_cv_dos_paths=yes

fi

cd "${BUILDTOOLS_BUILD_FOLDER}/make-${MAKE_VERSION}"
make ${MAKE_JOBS} all

# Always clear the destination folder, to have a consistent package.
echo
echo "remove install..."

rm -rf "${BUILDTOOLS_INSTALL_FOLDER}"
make install-strip

# ----- Copy files to the install bin folder -----

echo 
mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUILDTOOLS_INSTALL_FOLDER}/make-${MAKE_VERSION}/bin/make.exe" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"

echo 
# Copy make license files
mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/make"
cp -v "${BUILDTOOLS_WORK_FOLDER}/make-${MAKE_VERSION}/COPYING" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/make"
cp -v "${BUILDTOOLS_WORK_FOLDER}/make-${MAKE_VERSION}/README"* \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/make"
cp -v "${BUILDTOOLS_WORK_FOLDER}/make-${MAKE_VERSION}/NEWS" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license/make"

# Build BusyBox

# http://intgat.tigress.co.uk/rmy/busybox/index.html

BUSYBOX_COMMIT="74ba8c760f3337218cddabaaa0acc4e1f5d6e6c5"
# BUSYBOX_COMMIT=master
BUSYBOX_ARCHIVE="${BUSYBOX_COMMIT}.zip"
BUSYBOX_URL="https://github.com/rmyorston/busybox-w32/archive/${BUSYBOX_ARCHIVE}"

BUSYBOX_SRC_FOLDER="${BUILDTOOLS_WORK_FOLDER}/busybox-w32-${BUSYBOX_COMMIT}"
BUSYBOX_BUILD_FOLDER="${BUILDTOOLS_BUILD_FOLDER}/busybox"

if [ ! -f "${BUILDTOOLS_DOWNLOAD_FOLDER}/${BUSYBOX_ARCHIVE}" ]
then
  cd "${BUILDTOOLS_DOWNLOAD_FOLDER}"
  "${WGET}" "${BUSYBOX_URL}" "${WGET_OUT}" "${BUSYBOX_ARCHIVE}"
fi

if [ ! -d "${BUSYBOX_SRC_FOLDER}" ]
then
  cd "${BUILDTOOLS_WORK_FOLDER}"
  unzip "${BUILDTOOLS_DOWNLOAD_FOLDER}/${BUSYBOX_ARCHIVE}"

  cd "${BUSYBOX_SRC_FOLDER}/configs"
  sed \
  -e 's/CONFIG_CROSS_COMPILER_PREFIX=".*"/CONFIG_CROSS_COMPILER_PREFIX="i686-w64-mingw32-"/' \
  <mingw32_defconfig >gnuarmeclipse_32_mingw_defconfig

  sed \
  -e 's/CONFIG_CROSS_COMPILER_PREFIX=".*"/CONFIG_CROSS_COMPILER_PREFIX="x86_64-w64-mingw32-"/' \
  <mingw32_defconfig >gnuarmeclipse_64_mingw_defconfig
fi

# make KBUILD_SRC=/path/to/source -f /path/to/source/Makefile defconfig
# make

if [ ! -f "${BUSYBOX_BUILD_FOLDER}/.config" ]
then

  mkdir -p "${BUSYBOX_BUILD_FOLDER}"

  echo 
  echo "make gnuarmeclipse_${TARGET_BITS}_mingw_defconfig..."

  cd "${BUSYBOX_BUILD_FOLDER}"
  make KBUILD_SRC="${BUSYBOX_SRC_FOLDER}" \
  -f "${BUSYBOX_SRC_FOLDER}/Makefile" \
  "gnuarmeclipse_${TARGET_BITS}_mingw_defconfig"

fi

if [ ! -f "${BUSYBOX_BUILD_FOLDER}/busybox.exe" ]
then

  echo 
  echo "make..."

  cd "${BUSYBOX_BUILD_FOLDER}"
  make

fi

echo 
# Copy BusyBox with 3 different names
mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin"
cp -v "${BUSYBOX_BUILD_FOLDER}/busybox.exe" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin/busybox.exe"
cp -v "${BUSYBOX_BUILD_FOLDER}/busybox.exe" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin/sh.exe"
cp -v "${BUSYBOX_BUILD_FOLDER}/busybox.exe" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin/rm.exe"
cp -v "${BUSYBOX_BUILD_FOLDER}/busybox.exe" \
 "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/bin/echo.exe"

echo 
# Convert all text files to DOS.
find "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/license" -type f \
-exec unix2dos {} \;

echo 
# Copy the GNU ARM Eclipse info files.
mkdir -p "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/scripts/build-build-tools-win-cross-linux.sh" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/build-build-tools-win-cross-linux.sh"

cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/info/INFO.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/INFO.txt"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/INFO.txt"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/info/BUILD.txt" \
  "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/BUILD.txt"
unix2dos "${BUILDTOOLS_INSTALL_FOLDER}/build-tools/gnuarmeclipse/BUILD.txt"
cp -v "${BUILDTOOLS_GIT_FOLDER}/gnuarmeclipse/info/CHANGES.txt" \
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
  -DW${TARGET_BITS} \
  -DBITS=${TARGET_BITS} \
  -DVERSION=${OUTFILE_VERSION}-${NDATE} \
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

