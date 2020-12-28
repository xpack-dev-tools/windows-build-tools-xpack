# -----------------------------------------------------------------------------
# This file is part of the GNU MCU Eclipse distribution.
#   (https://gnu-mcu-eclipse.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the second edition of the GNU MCU Eclipse build
# scripts. As the name implies, it should contain only functions and
# should be included with 'source' by the container build scripts.

# -----------------------------------------------------------------------------

# The surprise of this build was that building the cross guile requires
# a native guile; thus the need to build everything twice, first the
# native build, than the cross build.

# -----------------------------------------------------------------------------

function build_make()
{
  # https://www.gnu.org/software/make/
  # ftp://ftp.gnu.org/gnu/make/
  # http://ftpmirror.gnu.org/make/

  # 2016-06-11, "4.2.1"
  # 2020-01-20, "4.3" (fails with mings 7)

  local make_version="$1"

  # The folder name as resulted after being extracted from the archive.
  local make_src_folder_name="make-${make_version}"
  # The folder name  for build, licenses, etc.
  local make_folder_name="${make_src_folder_name}"

  local make_archive_file_name="${make_folder_name}.tar.gz"

  local make_url="https://ftp.gnu.org/gnu/make/${make_archive_file_name}"

  local make_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-make-${make_version}-installed"
  if [ ! -f "${make_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${make_url}" "${make_archive_file_name}" \
      "${make_src_folder_name}" 

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${make_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${make_folder_name}"

      xbb_activate
      xbb_activate_installed_bin

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running make configure..."

          # cd "${make_build_folder}"

          run_verbose bash "${SOURCES_FOLDER_PATH}/${make_folder_name}/configure" --help

          # CPPFLAGS="${XBB_CPPFLAGS} -I${SOURCES_FOLDER_PATH}/${make_folder_name}/glob"
          CPPFLAGS="${XBB_CPPFLAGS}"
          CFLAGS="${XBB_CFLAGS_NO_W}"
          LDFLAGS="${XBB_LDFLAGS_APP}"
          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            LDFLAGS+=" -static"
          fi
          if [ "${IS_DEVELOP}" == "y" ]
          then
            LDFLAGS+=" -v"
          fi

          export CPPFLAGS
          export CFLAGS
          export LDFLAGS

          config_options=()

          config_options+=("--prefix=${APP_PREFIX}")

          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--without-guile")
          config_options+=("--without-libintl-prefix")
          config_options+=("--without-libiconv-prefix")

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            config_options+=("ac_cv_dos_paths=yes")
          fi

          run_verbose bash "${SOURCES_FOLDER_PATH}/${make_folder_name}/configure" \
            ${config_options[@]}
            
          cp "config.log" "${LOGS_FOLDER_PATH}/config-make-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/configure-make-output.txt"

      fi

      (
        echo
        echo "Running make make..."

        # Build.
        run_verbose make -j ${JOBS}

        # Not on mingw.
        # run_verbose make check

        run_verbose make install-strip

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/make-make-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${make_folder_name}" \
        "${make_folder_name}"

    )

    touch "${make_stamp_file_path}"

  else
    echo "make already installed."
  fi
}

function build_busybox()
{
  # https://frippery.org/busybox/
  # https://github.com/rmyorston/busybox-w32

  # busybox_commit=master
  # busybox_commit="9fe16f6102d8ab907c056c484988057904092c06"
  # busybox_commit="977d65c1bbc57f5cdd0c8bfd67c8b5bb1cd390dd"
  # busybox_commit="9fa1e4990e655a85025c9d270a1606983e375e47"
  # busybox_commit="c2002eae394c230d6b89073c9ff71bc86a7875e8"

  # Dec 9, 2017
  # busybox_commit="096aee2bb468d1ab044de36e176ed1f6c7e3674d"

  # Apr 13, 2018
  # busybox_commit="6f7d1af269eed4b42daeb9c6dfd2ba62f9cd47e4"

  # Apr 06, 2019
  # busybox_commit="65ae5b24cc08f898e81b36421b616fc7fc25d2b1"

  # Dec 12, 2020
  # busybox_commit="f902184fa8aa37b0ce8b725da5657ef2ed2005dd

  local busybox_commit="$1"

  local busybox_archive="${busybox_commit}.zip"
  local busybox_url="https://github.com/rmyorston/busybox-w32/archive/${busybox_archive}"

  local busybox_src_folder_name="busybox-w32-${busybox_commit}"
  local busybox_folder_name="${busybox_src_folder_name}"

  local busybox_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-busybox-${busybox_commit}-installed"
  if [ ! -f "${busybox_stamp_file_path}" ]
  then
    (
      echo
      echo "BusyBox in-source building"

      if [ ! -d "${BUILD_FOLDER_PATH}/${busybox_folder_name}" ]
      then

        # Does not use configure and builds in the source folder.
        cd "${BUILD_FOLDER_PATH}"

        download_and_extract "${busybox_url}" "${busybox_archive}" \
          "${busybox_src_folder_name}"

        if [ "${busybox_src_folder_name}" != "${busybox_folder_name}" ]
        then
          mv -v "${busybox_src_folder_name}" "${busybox_folder_name}"
        fi
      fi

      mkdir -pv "${LOGS_FOLDER_PATH}/${busybox_folder_name}"

      cd "${BUILD_FOLDER_PATH}/${busybox_folder_name}"

      xbb_activate

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        LDFLAGS+=" -static"
      fi
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      if [ ${TARGET_BITS} == "32" ]
      then
        # Required since some of the host tools are built here.
        export HOST_EXTRACFLAGS="-D_FILE_OFFSET_BITS=64"
      fi

      export CPPFLAGS
      export CFLAGS
      export LDFLAGS

      if [ ! -f ".config" ]
      then
        (
          echo
          echo "Running BusyBox configure..."

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            if [ ${TARGET_BITS} == "32" ]
            then
              # On 32-bit containers running on 64-bit systems, stat() fails with
              # 'Value too large for defined data type'.
              # The solution is to add _FILE_OFFSET_BITS=64.
              export HOST_EXTRACFLAGS="-D_FILE_OFFSET_BITS=64"
              run_verbose make mingw32_defconfig \
                HOSTCC="${NATIVE_CC}" \
                HOSTCXX="${NATIVE_CXX}"
            elif [ ${TARGET_BITS} == "64" ]
            then
              run_verbose make mingw64_defconfig \
                HOSTCC="${NATIVE_CC}" \
                HOSTCXX="${NATIVE_CXX}"
            fi
          else
            run_verbose make defconfig
          fi

        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${busybox_folder_name}/configure-output.txt"
      fi

      if [ ! -f "busybox.exe" -a ! -f "busybox" ]
      then
        (
          echo
          echo "Running BusyBox make..."

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            run_verbose make -j ${JOBS} \
              HOSTCC="${NATIVE_CC}" \
              HOSTCXX="${NATIVE_CXX}"

            mkdir -pv "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}/bin"
            cp -v "busybox.exe" \
              "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}/bin"

            ${CROSS_COMPILE_PREFIX}-strip \
              "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}/bin/busybox.exe"

            (
              cd "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}/bin"

              cp -v "busybox.exe" "sh.exe"
              cp -v "busybox.exe" "rm.exe"
              cp -v "busybox.exe" "echo.exe"
              cp -v "busybox.exe" "mkdir.exe"

              # Requested for ChibiOS build.
              cp -v "busybox.exe" "cp.exe"
            )            

          else
            run_verbose make -j ${JOBS}

            # TODO: install
          fi

        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${busybox_folder_name}/make-output.txt"
      fi

      copy_license \
        "${BUILD_FOLDER_PATH}/${busybox_src_folder_name}" \
        "busybox-w32"

    )

    touch "${busybox_stamp_file_path}"

  else
    echo "BusyBox already installed."
  fi

}

# -----------------------------------------------------------------------------
