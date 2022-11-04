# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# The surprise of this build was that building the cross guile requires
# a native guile; thus the need to build everything twice, first the
# native build, than the cross build.

# -----------------------------------------------------------------------------


function build_bash()
{
  # https://www.gnu.org/software/bash/
  # https://savannah.gnu.org/projects/bash/
  # https://ftp.gnu.org/gnu/bash/
  # https://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz

  # https://archlinuxarm.org/packages/aarch64/bash/files/PKGBUILD
  # https://github.com/msys2/MSYS2-packages/blob/master/bash/PKGBUILD

  # 2018-01-30, "4.4.18"
  # 2019-01-07, "5.0"
  # 2020-12-06, "5.1"

  local bash_version="$1"

  local bash_src_folder_name="bash-${bash_version}"

  local bash_archive="${bash_src_folder_name}.tar.gz"
  local bash_url="https://ftp.gnu.org/gnu/bash/${bash_archive}"

  local bash_folder_name="${bash_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${bash_folder_name}"

  local bash_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${bash_folder_name}-installed"
  if [ ! -f "${bash_stamp_file_path}" ]
  then

    echo
    echo "bash in-source building..."

    mkdir -pv "${XBB_BUILD_FOLDER_PATH}"
    cd "${XBB_BUILD_FOLDER_PATH}"

    if [ ! -d "${XBB_BUILD_FOLDER_PATH}/${bash_folder_name}" ]
    then

      download_and_extract "${bash_url}" "${bash_archive}" \
        "${bash_src_folder_name}"

      if [ "${bash_src_folder_name}" != "${bash_folder_name}" ]
      then
        mv -v "${bash_src_folder_name}" "${bash_folder_name}"
      fi
    fi


    (
      cd "${XBB_BUILD_FOLDER_PATH}/${bash_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS} -DWORDEXP_OPTION"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_APP}"

      CC_FOR_BUILD="${XBB_NATIVE_CC}"

      if [ "${XBB_TARGET_PLATFORM}" == "linux" ] # Not really.
      then
        xbb_activate_cxx_rpath
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      export CC_FOR_BUILD

      env | sort

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          run_verbose autoconf

          echo
          echo "Running bash configure..."

          run_verbose bash "${XBB_BUILD_FOLDER_PATH}/${bash_src_folder_name}/configure" --help

          config_options=()
          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--with-curses")
          config_options+=("--without-libintl-prefix")
          config_options+=("--without-libiconv-prefix")
          config_options+=("--without-bash-malloc")

          # config_options+=("--with-installed-readline")
          config_options+=("--enable-readline")
          config_options+=("--enable-static-link")
          config_options+=("--enable-threads=windows")

          config_options+=("bash_cv_dev_stdin=present")
          config_options+=("bash_cv_dev_fd=standard")
          config_options+=("bash_cv_termcap_lib=libncurses")

          run_verbose bash ${DEBUG} "${XBB_BUILD_FOLDER_PATH}/${bash_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${bash_folder_name}/config-log.txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${bash_folder_name}/configure-output.txt"
      fi

      (
        echo
        echo "Running bash make..."

        # Build.
        run_verbose make -j ${XBB_JOBS} \
          HISTORY_LDFLAGS= \
          READLINE_LDFLAGS= \
          LOCAL_LDFLAGS='-Wl,--export-all,--out-implib,lib$(@:.exe=.dll.a)'

        # make install-strip
        run_verbose make install-strip

        # run_verbose make -j1 check

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${bash_folder_name}/make-output.txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${bash_stamp_file_path}"

  else
    echo "Component bash already installed."
  fi

  test_functions+=("test_bash")
}

function test_bash()
{
  (
    # xbb_activate_installed_bin

    echo
    echo "Checking the bash binaries shared libraries..."

    show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/bash"

    echo
    echo "Testing if bash binaries start properly..."

    run_app "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/bash" --version

    echo
    echo "Testing if bash binaries display help..."

    run_app "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/bash" --help
  )
}

# -----------------------------------------------------------------------------
