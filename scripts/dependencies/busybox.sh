# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://busybox.net
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

# 9 June, 2022
# FRP-4716-g31467ddfc

# 9 Nov 9
# FRP-4784-g5507c8744

function busybox_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local busybox_commit="$1"
  local busybox_src_folder_name="busybox-w32-${busybox_commit}"

  local busybox_archive="${busybox_commit}.zip"
  local busybox_url="https://github.com/rmyorston/busybox-w32/archive/${busybox_archive}"

  local busybox_folder_name="${busybox_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${busybox_folder_name}"

  local busybox_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-busybox-${busybox_commit}-installed"
  if [ ! -f "${busybox_stamp_file_path}" ]
  then
    (
      echo
      echo "BusyBox in-source building..."

      if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${busybox_folder_name}" ]
      then

        # Does not use configure and builds in the source folder.
        mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
        cd "${XBB_BUILD_FOLDER_PATH}"

        download_and_extract "${busybox_url}" "${busybox_archive}" \
          "${busybox_src_folder_name}"

        if [ "${busybox_src_folder_name}" != "${busybox_folder_name}" ]
        then
          mv -v "${busybox_src_folder_name}" "${busybox_folder_name}"
        fi
      fi

      cd "${XBB_BUILD_FOLDER_PATH}/${busybox_folder_name}"

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_APP}"

      if [ ${XBB_TARGET_BITS} == "32" ]
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
          xbb_show_env_develop

          echo
          echo "Running BusyBox configure..."

          if [ ${XBB_TARGET_BITS} == "32" ]
          then
            # On 32-bit containers running on 64-bit systems, stat() fails with
            # 'Value too large for defined data type'.
            # The solution is to add _FILE_OFFSET_BITS=64.
            export HOST_EXTRACFLAGS="-D_FILE_OFFSET_BITS=64"
            run_verbose make mingw32_defconfig \
              HOSTCC="${XBB_NATIVE_CC}" \
              HOSTCXX="${XBB_NATIVE_CXX}"
          elif [ ${XBB_TARGET_BITS} == "64" ]
          then
            run_verbose make mingw64_defconfig \
              HOSTCC="${XBB_NATIVE_CC}" \
              HOSTCXX="${XBB_NATIVE_CXX}"
          fi

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${busybox_folder_name}/configure-output.txt"
      fi

      if [ ! -f "busybox.exe" -a ! -f "busybox" ]
      then
        (
          echo
          echo "Running BusyBox make..."

          if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            run_verbose make -j ${XBB_JOBS} \
              HOSTCC="${XBB_NATIVE_CC}" \
              HOSTCXX="${XBB_NATIVE_CXX}"

            mkdir -pv "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
            cp -v "busybox.exe" \
              "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"

            ${STRIP} \
              "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/busybox.exe"

            (
              cd "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"

              cp -v "busybox.exe" "sh.exe"
              cp -v "busybox.exe" "rm.exe"
              cp -v "busybox.exe" "echo.exe"
              cp -v "busybox.exe" "mkdir.exe"

              # Requested for ChibiOS build.
              cp -v "busybox.exe" "cp.exe"
            )

          else
            run_verbose make -j ${XBB_JOBS}

            # TODO: install
            echo "Not implemented"
            exit 1
          fi

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${busybox_folder_name}/make-output.txt"
      fi

      copy_license \
        "${XBB_BUILD_FOLDER_PATH}/${busybox_src_folder_name}" \
        "busybox-w32"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${busybox_stamp_file_path}"

  else
    echo "BusyBox already installed"
  fi

  tests_add "busybox_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function busybox_test()
{
  local test_bin_path="$1"

  echo
  echo "Checking the busybox shared libraries..."
  show_host_libs "${test_bin_path}/busybox"

  echo
  echo "Checking if busybox starts..."

  run_host_app_verbose "${test_bin_path}/busybox" --help
}

# -----------------------------------------------------------------------------
