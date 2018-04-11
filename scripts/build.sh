#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is -x.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------

# Script to cross build the 32/64-bit Windows version of Build Tools 
# with MinGW-w64 on GNU/Linux.
#
# Developed on OS X 10.12 Sierra.
# Also tested on:
#   GNU/Linux Arch (Manjaro 16.08)
#
# The Windows packages are build using Debian 8 x64 Docker containers.
# The build is structured in 2 steps, one running on the host machine
# and one running inside the Docker container.
#
# At first run, Docker will download/build a relatively large
# image (2.5GB) from Docker Hub.
#
# Prerequisites:
#
#   Docker
#   curl, git, automake, patch, tar, unzip, zip
#
# When running on OS X, a custom Homebrew is required to provide the 
# missing libraries and TeX binaries.
#

# Mandatory definitions.
APP_NAME="Windows Build Tools"

# Used as part of file/folder paths.
APP_LC_NAME="build-tools"
APP_UC_NAME="Build Tools"

DISTRO_UC_NAME="GNU MCU Eclipse"
DISTRO_LC_NAME="gnu-mcu-eclipse"

jobs="--jobs=2"

# On Parallels virtual machines, prefer host Work folder.
# Second choice are Work folders on secondary disks.
# Final choice is a Work folder in HOME.
if [ -d /media/psf/Home/Work ]
then
  WORK_FOLDER_PATH=${WORK_FOLDER_PATH:-"/media/psf/Home/Work/${APP_LC_NAME}"}
elif [ -d /media/${USER}/Work ]
then
  WORK_FOLDER_PATH=${WORK_FOLDER_PATH:-"/media/${USER}/Work/${APP_LC_NAME}"}
elif [ -d /media/Work ]
then
  WORK_FOLDER_PATH=${WORK_FOLDER_PATH:-"/media/Work/${APP_LC_NAME}"}
else
  # Final choice, a Work folder in HOME.
  WORK_FOLDER_PATH=${WORK_FOLDER_PATH:-"${HOME}/Work/${APP_LC_NAME}"}
fi

# ----- Define build constants. -----

BUILD_FOLDER_NAME=${BUILD_FOLDER_NAME:-"build"}
BUILD_FOLDER_PATH=${BUILD_FOLDER_PATH:-"${WORK_FOLDER_PATH}/${BUILD_FOLDER_NAME}"}

DOWNLOAD_FOLDER_NAME=${DOWNLOAD_FOLDER_NAME:-"download"}
DOWNLOAD_FOLDER_PATH=${DOWNLOAD_FOLDER_PATH:-"${WORK_FOLDER_PATH}/${DOWNLOAD_FOLDER_NAME}"}
DEPLOY_FOLDER_NAME=${DEPLOY_FOLDER_NAME:-"deploy"}

# ----- Define build Git constants. -----

PROJECT_GIT_FOLDER_NAME="windows-build-tools.git"
PROJECT_GIT_FOLDER_PATH="${WORK_FOLDER_PATH}/${PROJECT_GIT_FOLDER_NAME}"
PROJECT_GIT_DOWNLOADS_FOLDER_PATH="${HOME}/Downloads/${PROJECT_GIT_FOLDER_NAME}"
PROEJCT_GIT_URL="https://github.com/gnu-mcu-eclipse/${PROJECT_GIT_FOLDER_NAME}"

# ----- Docker images. -----

docker_linux64_image="ilegeul/centos:6-xbb-v1"
docker_linux32_image="ilegeul/centos32:6-xbb-v1"

# ----- Create Work folder. -----

echo
echo "Work folder: \"${WORK_FOLDER_PATH}\"."

mkdir -p "${WORK_FOLDER_PATH}"

# ----- Parse actions and command line options. -----

ACTION=""
DO_BUILD_WIN32=""
DO_BUILD_WIN64=""
helper_script_path=""
do_no_pdf=""
do_develop=""

while [ $# -gt 0 ]
do
  case "$1" in

    clean|cleanall|preload-images)
      ACTION="$1"
      shift
      ;;

    --win32|--window32)
      DO_BUILD_WIN32="y"
      shift
      ;;

    --win64|--windows64)
      DO_BUILD_WIN64="y"
      shift
      ;;

    --all)
      DO_BUILD_WIN32="y"
      DO_BUILD_WIN64="y"
      shift
      ;;

    --helper-script)
      helper_script_path=$2
      shift 2
      ;;

    --jobs)
      jobs="--jobs=$2"
      shift 2
      ;;

    --develop)
      do_develop="y"
      shift
      ;;

    --help)
      echo "Build the GNU MCU Eclipse ${APP_NAME} distributions."
      echo "Usage:"
      echo "    bash $0 [--helper-script file.sh] [--win32] [--win64] [--all] [clean|cleanall|preload-images] [--develop] [--help]"
      echo
      exit 1
      ;;

    *)
      echo "Unknown action/option $1"
      exit 1
      ;;
  esac

done

# ----- Prepare build scripts. -----

build_script_path=$0
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path=$(pwd)/$0
fi

# Copy the current script to Work area, to later copy it into the install folder.
mkdir -p "${WORK_FOLDER_PATH}/scripts"
cp "${build_script_path}" "${WORK_FOLDER_PATH}/scripts/build-${APP_LC_NAME}.sh"

# ----- Build helper. -----

if [ -z "${helper_script_path}" ]
then
  script_folder_path="$(dirname ${build_script_path})"
  script_folder_name="$(basename ${script_folder_path})"
  if [ \( "${script_folder_name}" == "scripts" \) \
    -a \( -f "${script_folder_path}/helper/build-helper.sh" \) ]
  then
    helper_script_path="${script_folder_path}/helper/build-helper.sh"
  elif [ \( "${script_folder_name}" == "scripts" \) \
    -a \( -d "${script_folder_path}/helper" \) ]
  then
    (
      cd "$(dirname ${script_folder_path})"
      git submodule update --init --recursive --remote
    )
    helper_script_path="${script_folder_path}/helper/build-helper.sh"
  elif [ -f "${WORK_FOLDER_PATH}/scripts/build-helper.sh" ]
  then
    helper_script_path="${WORK_FOLDER_PATH}/scripts/build-helper.sh"
  fi
else
  if [[ "${helper_script_path}" != /* ]]
  then
    # Make relative path absolute.
    helper_script_path="$(pwd)/${helper_script_path}"
  fi
fi

# Copy the current helper script to Work area, to later copy it into the install folder.
mkdir -p "${WORK_FOLDER_PATH}/scripts"
if [ "${helper_script_path}" != "${WORK_FOLDER_PATH}/scripts/build-helper.sh" ]
then
  cp "${helper_script_path}" "${WORK_FOLDER_PATH}/scripts/build-helper.sh"
fi

echo "Helper script: \"${helper_script_path}\"."
source "$helper_script_path"

# ----- Library sources. -----

# For updates, please check the corresponding pages.

# The make executable is built using the source package from  
# the open source MSYS2 project.
# https://sourceforge.net/projects/msys2/

MSYS2_MAKE_PACK_URL_BASE="http://sourceforge.net/projects/msys2/files"

# http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/
# http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/make-4.1-4.src.tar.gz/download

# MAKE_VERSION="4.2"
# MSYS2_MAKE_VERSION_RELEASE="${MAKE_VERSION}-1"

# Warning! 4.2 does not build on Debian 8, it requires gettext-0.19.4.
# 2016-06-15
MAKE_VERSION="4.2.1"
MSYS2_MAKE_VERSION_RELEASE="${MAKE_VERSION}-1"

MSYS2_MAKE_PACK_ARCH="make-${MSYS2_MAKE_VERSION_RELEASE}.src.tar.gz"
MSYS2_MAKE_PACK_URL="${MSYS2_MAKE_PACK_URL_BASE}/REPOS/MSYS2/Sources/${MSYS2_MAKE_PACK_ARCH}"


# http://intgat.tigress.co.uk/rmy/busybox/index.html
# https://github.com/rmyorston/busybox-w32

# BUSYBOX_COMMIT=master
# BUSYBOX_COMMIT="9fe16f6102d8ab907c056c484988057904092c06"
# BUSYBOX_COMMIT="977d65c1bbc57f5cdd0c8bfd67c8b5bb1cd390dd"
# BUSYBOX_COMMIT="9fa1e4990e655a85025c9d270a1606983e375e47"
# BUSYBOX_COMMIT="c2002eae394c230d6b89073c9ff71bc86a7875e8"
# Dec 9, 2017
BUSYBOX_COMMIT="096aee2bb468d1ab044de36e176ed1f6c7e3674d"

BUSYBOX_ARCHIVE="${BUSYBOX_COMMIT}.zip"
BUSYBOX_URL="https://github.com/rmyorston/busybox-w32/archive/${BUSYBOX_ARCHIVE}"

BUSYBOX_SRC_FOLDER="${WORK_FOLDER_PATH}/busybox-w32-${BUSYBOX_COMMIT}"

# ----- Define build constants. -----

DOWNLOAD_FOLDER_PATH="${WORK_FOLDER_PATH}/download"
DEPLOY_FOLDER_NAME="deploy"

# ----- Process actions. -----

if [ \( "${ACTION}" == "clean" \) -o \( "${ACTION}" == "cleanall" \) ]
then
  # Remove most build and temporary folders.
  echo
  if [ "${ACTION}" == "cleanall" ]
  then
    echo "Remove all the build folders..."
  else
    echo 'Remove most of the build folders (except output)...'
  fi

  rm -rf "${BUILD_FOLDER_PATH}"
  rm -rf "${WORK_FOLDER_PATH}/install"

  rm -rf "${WORK_FOLDER_PATH}/msys2"
  rm -rf "${WORK_FOLDER_PATH}/install"

  rm -rf "${WORK_FOLDER_PATH}/scripts"

  if [ "${ACTION}" == "cleanall" ]
  then
    rm -rf "${WORK_FOLDER_PATH}/output"
  fi

  echo
  echo "Clean completed. Proceed with a regular build."

  exit 0
fi

# ----- Start build. -----

do_host_start_timer

do_host_detect

# ----- Prepare prerequisites. -----

do_host_prepare_prerequisites

# ----- Process "preload-images" action. -----

if [ "${ACTION}" == "preload-images" ]
then
  do_host_prepare_docker

  echo
  echo "Check/Preload Docker images..."

  echo
  docker run --interactive --tty "${docker_linux64_image}" \
    lsb_release --description --short
  docker run --interactive --tty "${docker_linux32_image}" \
    lsb_release --description --short

  echo
  docker images

  do_host_stop_timer

  exit 0
fi


# ----- Prepare Docker. -----

if [ -n "${DO_BUILD_WIN32}${DO_BUILD_WIN64}" ]
then
  do_host_prepare_docker
fi

# ----- Check some more prerequisites. -----

echo "Checking host automake..."
automake --version 2>/dev/null | grep automake

echo "Checking host patch..."
patch --version | grep patch

echo "Checking host tar..."
tar --version

echo "Checking host unzip..."
unzip | grep UnZip

# ----- Get the project git repository. -----

if [ ! -d "${PROJECT_GIT_FOLDER_PATH}" ]
then

  cd "${WORK_FOLDER_PATH}"

  echo "If asked, enter ${USER} GitHub password for git clone"
  git clone "${PROEJCT_GIT_URL}" "${PROJECT_GIT_FOLDER_PATH}"

fi


# ----- Get current date. -----

do_host_get_current_date

# ----- Get make. -----

# The make executable is built using the source package from  
# the open source MSYS2 project.
# https://sourceforge.net/projects/msys2/

if [ ! -f "${DOWNLOAD_FOLDER_PATH}/${MSYS2_MAKE_PACK_ARCH}" ]
then
  mkdir -p "${DOWNLOAD_FOLDER_PATH}"

  cd "${DOWNLOAD_FOLDER_PATH}"
  echo "Downloading \"${MSYS2_MAKE_PACK_ARCH}\"..."
  curl --fail -L "${MSYS2_MAKE_PACK_URL}" \
    --output "${MSYS2_MAKE_PACK_ARCH}"
fi

MAKE_ARCH="make-${MAKE_VERSION}.tar.bz2"
if [ ! -f "${WORK_FOLDER_PATH}/msys2/make/${MAKE_ARCH}" ]
then
  mkdir -p "${WORK_FOLDER_PATH}/msys2"

  echo
  echo "Unpacking ${MSYS2_MAKE_PACK_ARCH}..."
  cd "${WORK_FOLDER_PATH}/msys2"
  tar -xvf "${DOWNLOAD_FOLDER_PATH}/${MSYS2_MAKE_PACK_ARCH}"
fi

# The actual unpack will be done later, directly in the build folder.

# ----- Get BusyBox. -----

# http://intgat.tigress.co.uk/rmy/busybox/index.html

if [ ! -f "${DOWNLOAD_FOLDER_PATH}/${BUSYBOX_ARCHIVE}" ]
then
  cd "${DOWNLOAD_FOLDER_PATH}"
  echo "Downloading \"${BUSYBOX_ARCHIVE}\"..."
  curl --fail -L "${BUSYBOX_URL}" --output "${BUSYBOX_ARCHIVE}"
fi

# The unpack will be done later, directly in the build folder.

# v===========================================================================v
# Create the build script (needs to be separate for Docker).

script_name="build.sh"
script_file_path="${WORK_FOLDER_PATH}/scripts/${script_name}"

rm -f "${script_file_path}"
mkdir -p "$(dirname ${script_file_path})"
touch "${script_file_path}"

# Note: __EOF__ is quoted to prevent substitutions here.
cat <<'__EOF__' >> "${script_file_path}"
#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set -x # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------

__EOF__
# The above marker must start in the first column.

# Note: __EOF__ is not quoted to allow local substitutions.
cat <<__EOF__ >> "${script_file_path}"

APP_NAME="${APP_NAME}"
APP_LC_NAME="${APP_LC_NAME}"
APP_UC_NAME="${APP_UC_NAME}"
DISTRO_UC_NAME="${DISTRO_UC_NAME}"
DISTRO_LC_NAME="${DISTRO_LC_NAME}"

DISTRIBUTION_FILE_DATE="${DISTRIBUTION_FILE_DATE}"
PROJECT_GIT_FOLDER_NAME="${PROJECT_GIT_FOLDER_NAME}"

MAKE_VERSION="${MAKE_VERSION}"
MAKE_ARCH="${MAKE_ARCH}"

BUSYBOX_COMMIT="${BUSYBOX_COMMIT}"
BUSYBOX_ARCHIVE="${BUSYBOX_ARCHIVE}"

jobs="${jobs}"

__EOF__
# The above marker must start in the first column.

# Propagate DEBUG to guest.
set +u
if [[ ! -z ${DEBUG} ]]
then
  echo "DEBUG=${DEBUG}" "${script_file_path}"
  echo
fi
set -u

# Note: __EOF__ is quoted to prevent substitutions here.
cat <<'__EOF__' >> "${script_file_path}"

PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR:-""}

# For just in case.
export LC_ALL="C"
export CONFIG_SHELL="/bin/bash"

script_name="$(basename "$0")"
args="$@"
docker_container_name=""

while [ $# -gt 0 ]
do
  case "$1" in
    --container-build-folder)
      container_build_folder_path="$2"
      shift 2
      ;;

    --container-install-folder)
      container_install_folder_path="$2"
      shift 2
      ;;

    --container-output-folder)
      container_output_folder_path="$2"
      shift 2
      ;;

    --shared-install-folder)
      shared_install_folder_path="$2"
      shift 2
      ;;

    --docker-container-name)
      docker_container_name="$2"
      shift 2
      ;;

    --target-os)
      target_os="$2"
      shift 2
      ;;

    --target-bits)
      target_bits="$2"
      shift 2
      ;;

    --work-folder)
      work_folder_path="$2"
      shift 2
      ;;

    --distribution-folder)
      distribution_folder="$2"
      shift 2
      ;;

    --download-folder)
      download_folder="$2"
      shift 2
      ;;

    --helper-script)
      helper_script_path="$2"
      shift 2
      ;;

    --group-id)
      group_id="$2"
      shift 2
      ;;

    --user-id)
      user_id="$2"
      shift 2
      ;;

    --host-uname)
      host_uname="$2"
      shift 2
      ;;

    *)
      echo "Unknown option $1, exit."
      exit 1
  esac
done

# -----------------------------------------------------------------------------

# XBB not available when running from macOS.
if [ -f "/opt/xbb/xbb.sh" ]
then
  source "/opt/xbb/xbb.sh"
fi

# -----------------------------------------------------------------------------

# Run the helper script in this shell, to get the support functions.
source "${helper_script_path}"

# Requires XBB_FOLDER.
do_container_detect

if [ -f "/opt/xbb/xbb.sh" ]
then

  # Required by jimtcl, building their bootstrap fails on 32-bits.
  # Must be installed befoare activating XBB, otherwise yum fails,
  # with python failing some crypto.
  yum install -y tcl

  xbb_activate

  # Don't forget to add `-static-libstdc++` to app LDFLAGS,
  # otherwise the final executable may have a reference to 
  # a wrong `libstdc++.so.6`.

  export PATH="/opt/texlive/bin/${CONTAINER_MACHINE}-linux":${PATH}

fi

# -----------------------------------------------------------------------------

git_folder_path="${work_folder_path}/${PROJECT_GIT_FOLDER_NAME}"

EXTRA_CFLAGS="-ffunction-sections -fdata-sections -m${target_bits} -pipe"
EXTRA_CXXFLAGS="-ffunction-sections -fdata-sections -m${target_bits} -pipe"
EXTRA_CPPFLAGS="-I${install_folder}/include"
EXTRA_LDFLAGS="-L${install_folder}/lib64 -L${install_folder}/lib -static-libstdc++ -Wl,--gc-sections"

# export PKG_CONFIG_PREFIX="${install_folder}"
# export PKG_CONFIG="${git_folder_path}/gnu-mcu-eclipse/scripts/cross-pkg-config"
export PKG_CONFIG=pkg-config-verbose
export PKG_CONFIG_LIBDIR="${install_folder}/lib64/pkgconfig":"${install_folder}/lib/pkgconfig"

# -----------------------------------------------------------------------------

download_folder_path=${download_folder_path:-"${work_folder_path}/download"}
distribution_file_version=$(cat "${git_folder_path}/gnu-mcu-eclipse/VERSION")-${DISTRIBUTION_FILE_DATE}

# -----------------------------------------------------------------------------

mkdir -p ${build_folder_path}
cd ${build_folder_path}

# ----- Test if various tools are present -----

echo
echo "Checking automake..."
automake --version 2>/dev/null | grep automake

echo "Checking ${cross_compile_prefix}-gcc..."
${cross_compile_prefix}-gcc --version 2>/dev/null | egrep -e 'gcc|clang'

echo "Checking unix2dos..."
unix2dos --version 2>&1 | grep unix2dos

echo "Checking makensis..."
echo "makensis $(makensis -VERSION)"

echo "Checking shasum..."
shasum --version

echo "Checking zip..."
zip -v | grep "This is Zip"

# ----- Recreate the output folder. -----

# rm -rf "${output_folder_path}"
mkdir -p "${output_folder_path}"

# Always clear the destination folder, to have a consistent package.
echo
echo "Removing install..."
rm -rf "${install_folder}"

# ----- Build make. -----

make_build_folder="${build_folder_path}/make-${MAKE_VERSION}"

if [ ! -d "${make_build_folder}" ]
then
  mkdir -p "${build_folder_path}"

  cd "${build_folder_path}"
  echo
  echo "Unpacking ${MAKE_ARCH}..."
  set +e
  tar -xvf "${work_folder_path}/msys2/make/${MAKE_ARCH}"
  set -e

  cd "${make_build_folder}"
  if [ -f "${work_folder_path}/msys2/make/make-autoconf.patch" ]
  then
    patch -p1 -i "${work_folder_path}/msys2/make/make-autoconf.patch"
  fi
fi

(
  if [ ! -f "${make_build_folder}/config.h" ]
  then

    cd "${make_build_folder}"

    echo
    echo "Running make autoreconf..."
    autoreconf -fi

    echo
    echo "Running make configure..."

    cd "${make_build_folder}"

    bash "configure" --help

    export CFLAGS="${EXTRA_CFLAGS}"
    export LDFLAGS="${EXTRA_LDFLAGS} -static"

    bash "configure" \
      --prefix="${install_folder}/make-${MAKE_VERSION}"  \
      --build=${BUILD} \
      --host=${HOST} \
      --target=${TARGET} \
      --without-libintl-prefix \
      --without-libiconv-prefix \
      ac_cv_dos_paths=yes \
      | tee "${output_folder_path}/configure-output.txt"

  fi

  cd "${make_build_folder}"
  # Read only files
  rm -rf "${output_folder_path}"/config.*
  cp config.* "${output_folder_path}"

  cd "${make_build_folder}"
  make  "${jobs}" \
    | tee "${output_folder_path}/make-all-output.txt"

  make  "${jobs}" install \
    | tee "${output_folder_path}/make-install-output.txt"

  ${cross_compile_prefix}-strip "${install_folder}/make-${MAKE_VERSION}/bin/make.exe"
)

# ----- Copy files to the install bin folder -----

echo 
mkdir -p "${install_folder}/${APP_LC_NAME}/bin"
cp -v "${install_folder}/make-${MAKE_VERSION}/bin/make.exe" \
  "${install_folder}/${APP_LC_NAME}/bin"

# ----- Copy dynamic libraries to the install bin folder. -----

# No DLLs required.

# ----- Build BusyBox. -----

busybox_build_folder="${build_folder_path}/busybox-w32-${BUSYBOX_COMMIT}"

(
  if [ ! -f "${busybox_build_folder}/.config" ]
  then

    if [ ! -d "${busybox_build_folder}" ]
    then

      cd "${build_folder_path}"
      unzip "${download_folder}/${BUSYBOX_ARCHIVE}"

      cd "${busybox_build_folder}/configs"
      sed \
      -e 's/CONFIG_CROSS_COMPILER_PREFIX=".*"/CONFIG_CROSS_COMPILER_PREFIX="i686-w64-mingw32-"/' \
      <mingw32_defconfig >gnu-mcu-eclipse_32_mingw_defconfig

      sed \
      -e 's/CONFIG_CROSS_COMPILER_PREFIX=".*"/CONFIG_CROSS_COMPILER_PREFIX="x86_64-w64-mingw32-"/' \
      <mingw32_defconfig >gnu-mcu-eclipse_64_mingw_defconfig

    fi

    echo 
    echo "Running BusyBox make gnu-mcu-eclipse_${target_bits}_mingw_defconfig..."

    cd "${busybox_build_folder}"
    make  "${jobs}" "gnu-mcu-eclipse_${target_bits}_mingw_defconfig"

  fi

  if [ ! -f "${busybox_build_folder}/busybox.exe" ]
  then

    echo 
    echo "Running BusyBox make..."

    export CFLAGS="${EXTRA_CFLAGS} -Wno-format-extra-args -Wno-format -Wno-overflow -Wno-unused-variable -Wno-implicit-function-declaration -Wno-unused-parameter -Wno-maybe-uninitialized -Wno-pointer-to-int-cast -Wno-strict-prototypes -Wno-old-style-definition -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-discarded-qualifiers -Wno-strict-prototypes -Wno-old-style-definition -Wno-unused-function -Wno-int-to-pointer-cast"
    export LDFLAGS="${EXTRA_LDFLAGS} -static"

    cd "${busybox_build_folder}"
    if [ ${target_bits} == "32" ]
    then
      make  "${jobs}"
    elif [ ${target_bits} == "64" ]
    then
      make "${jobs}" mingw64_defconfig
      make "${jobs}"
    fi

  fi
)

# ----- Copy BusyBox with 3 different names. -----

echo
echo "Installing BusyBox..."

mkdir -p "${install_folder}/build-tools/bin"
cp -v "${busybox_build_folder}/busybox.exe" "${install_folder}/build-tools/bin/busybox.exe"
${cross_compile_prefix}-strip "${install_folder}/build-tools/bin/busybox.exe"

cp -v "${install_folder}/build-tools/bin/busybox.exe" "${install_folder}/build-tools/bin/sh.exe"
cp -v "${install_folder}/build-tools/bin/busybox.exe" "${install_folder}/build-tools/bin/rm.exe"
cp -v "${install_folder}/build-tools/bin/busybox.exe" "${install_folder}/build-tools/bin/echo.exe"
cp -v "${install_folder}/build-tools/bin/busybox.exe" "${install_folder}/build-tools/bin/mkdir.exe"

# ----- Copy the license files. -----

echo
echo "Copying license files..."

do_container_copy_license "${make_build_folder}" "make-${MAKE_VERSION}"
do_container_copy_license "${busybox_build_folder}" "busybox"

# For Windows, process cr lf
find "${install_folder}/${APP_LC_NAME}/licenses" -type f \
  -exec unix2dos {} \;


# ----- Copy the GNU MCU Eclipse info files. -----

echo 
echo "Copying info files..."

mkdir -p "${install_folder}/build-tools/gnu-mcu-eclipse"

cp -v "${git_folder_path}/gnu-mcu-eclipse/info/INFO.txt" \
  "${install_folder}/build-tools/INFO.txt"
do_unix2dos "${install_folder}/build-tools/INFO.txt"
cp -v "${git_folder_path}/gnu-mcu-eclipse/info/BUILD.txt" \
  "${install_folder}/build-tools/gnu-mcu-eclipse/BUILD.txt"
do_unix2dos "${install_folder}/build-tools/gnu-mcu-eclipse/BUILD.txt"
cp -v "${git_folder_path}/gnu-mcu-eclipse/info/CHANGES.txt" \
  "${install_folder}/build-tools/gnu-mcu-eclipse/"
do_unix2dos "${install_folder}/build-tools/gnu-mcu-eclipse/CHANGES.txt"

# Copy the current build script
cp -v "${work_folder_path}/scripts/build-${APP_LC_NAME}.sh" \
  "${install_folder}/${APP_LC_NAME}/gnu-mcu-eclipse/build-${APP_LC_NAME}.sh"
do_unix2dos "${install_folder}/${APP_LC_NAME}/gnu-mcu-eclipse/build-${APP_LC_NAME}.sh"

# Copy the current build helper script
cp -v "${work_folder_path}/scripts/build-helper.sh" \
  "${install_folder}/${APP_LC_NAME}/gnu-mcu-eclipse/build-helper.sh"
do_unix2dos "${install_folder}/${APP_LC_NAME}/gnu-mcu-eclipse/build-helper.sh"

cp -v "${output_folder_path}/config.log" \
  "${install_folder}/${APP_LC_NAME}/gnu-mcu-eclipse/config.log"
do_unix2dos "${install_folder}/${APP_LC_NAME}/gnu-mcu-eclipse/config.log"

# Not passed as is, used by makensis for the MUI_PAGE_LICENSE; must be DOS.
cp -v "${git_folder_path}/LICENSE" \
  "${install_folder}/build-tools/COPYING"
do_unix2dos "${install_folder}/build-tools/COPYING"


# ----- Create the distribution setup. -----

mkdir -p "${output_folder_path}"

do_container_create_distribution

do_check_application "make" --version

# Requires ${distribution_file} and ${result}
do_container_completed

exit 0

__EOF__
# The above marker must start in the first column.
# ^===========================================================================^


# ----- Build the Windows 64-bits distribution. -----

if [ "${DO_BUILD_WIN64}" == "y" ]
then
  do_host_build_target "Creating the Windows 64-bits distribution..." \
    --target-os win \
    --target-bits 64 \
    --docker-image "${docker_linux64_image}"
fi

# ----- Build the Windows 32-bits distribution. -----

if [ "${DO_BUILD_WIN32}" == "y" ]
then
  do_host_build_target "Creating the Windows 32-bits distribution..." \
    --target-os win \
    --target-bits 32 \
    --docker-image "${docker_linux32_image}"
fi

do_host_show_sha

do_host_stop_timer

# ----- Done. -----
exit 0
