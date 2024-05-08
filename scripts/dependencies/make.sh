# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# https://www.gnu.org/software/make/
# https://savannah.gnu.org/projects/make/
# ftp://ftp.gnu.org/gnu/make/
# https://ftpmirror.gnu.org/make/

# 2016-06-11, "4.2.1"
# 2020-01-20, "4.3" (fails with duplicate fcntl; fixed in git)
# 2022-10-31, "4.4"

function make_build()
{
  echo_develop
  echo_develop "[${FUNCNAME[0]} $@]"

  local make_version="$1"
  shift

  local git_commit=""

  while [ $# -gt 0 ]
  do

    case "$1" in
      --git-commit )
        git_commit="$2"
        shift 2
        ;;

      * )
        echo "Unsupported option $1 in ${FUNCNAME[0]}()"
        exit 1

    esac

  done

  # The folder name as resulted after being extracted from the archive.
  local make_src_folder_name="make-${make_version}"
  if [ ! -z "${git_commit}" ]
  then
    make_src_folder_name="make-${git_commit}"
  fi

  # The folder name  for build, licenses, etc.
  local make_folder_name="${make_src_folder_name}"

  local make_archive_file_name="${make_folder_name}.tar.gz"

  local make_url="https://ftp.gnu.org/gnu/make/${make_archive_file_name}"
  local make_git_url="https://git.savannah.gnu.org/git/make.git"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${make_folder_name}"

  local make_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-make-${make_version}-installed"
  if [ ! -f "${make_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${make_src_folder_name}" ]
    then
      if [ ! -z "${git_commit}" ]
      then
        run_verbose git clone "${make_git_url}" "${make_src_folder_name}"
        (
          cd "${make_src_folder_name}"
          run_verbose git checkout -qf "${git_commit}"

          # TODO: Check if still needed.
          # run_verbose echo sed -i.bak \
          #   -e 's|^isatty (int fd)$|__isatty (int fd)|' \
          #   -e 's|^ttyname (int fd)$|__ttyname (int fd)|' \
          #   src/w32/compat/posixfcn.c
        )
      else
        download_and_extract "${make_url}" "${make_archive_file_name}" \
          "${make_src_folder_name}"
      fi
    fi

    if [ ! -x "${XBB_SOURCES_FOLDER_PATH}/${make_src_folder_name}/configure" ]
    then
      (
        cd "${XBB_SOURCES_FOLDER_PATH}/${make_src_folder_name}"

        if [ -f "bootstrap" ]
        then
          echo "Running make bootstrap..."

          # Disable gettext, to simplify dependencies.
          run_verbose sed -i.bak \
            -e 's|^AM_GNU_GETTEXT|# AM_GNU_GETTEXT|' \
            configure.ac

          run_verbose diff configure.ac.bak configure.ac || true

          run_verbose bash ${DEBUG} bootstrap
        fi
      )
    fi

    (
      mkdir -p "${XBB_BUILD_FOLDER_PATH}/${make_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${make_folder_name}"

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running make configure..."

          # cd "${make_build_folder}"

          if is_develop
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${make_src_folder_name}/configure" --help
          fi

          # CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_SOURCES_FOLDER_PATH}/${make_folder_name}/glob"
          CPPFLAGS="${XBB_CPPFLAGS} -DWINDOWS32 -DHAVE_CONFIG_H"
          CFLAGS="${XBB_CFLAGS_NO_W} -mthreads -std=gnu99"
          LDFLAGS="${XBB_LDFLAGS_APP} -mthreads -std=gnu99 -Wl,--allow-multiple-definition"

          export CPPFLAGS
          export CFLAGS
          export LDFLAGS

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--without-guile")
          config_options+=("--without-libintl-prefix")
          config_options+=("--without-libiconv-prefix")

          config_options+=("ac_cv_dos_paths=yes")
          # config_options+=("ac_cv_func_fcntl=no")

          run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${make_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/config-make-log.txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/configure-make-output.txt"

      fi

      (
        echo
        echo "Running make make..."

        # Build.
        run_verbose make -j ${XBB_JOBS}

        # Not on mingw.
        # run_verbose make check

        run_verbose make install-strip

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/make-make-output.txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${make_folder_name}" \
        "${make_folder_name}"

      (
        mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin"

        run_verbose ${CC} "${XBB_BUILD_GIT_PATH}/tests/src/test-env.c" -o "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/test-env.exe"
        run_verbose ${CC} "${XBB_BUILD_GIT_PATH}/tests/src/test-sh.c" -o "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/test-sh.exe" -Wno-incompatible-pointer-types
        run_verbose ${CC} "${XBB_BUILD_GIT_PATH}/tests/src/test-sh.c" -o "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/test-sh-null.exe" -Wno-incompatible-pointer-types -D__USE_NULL_ENVP
      )
    )


    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${make_stamp_file_path}"

  else
    echo "make already installed"
  fi

  tests_add "make_test" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"

  run_host_app_verbose "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/test-env" one two
  run_host_app_verbose "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/test-sh" -c "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/test-env.exe" one two

  if true
  then
  (
    mkdir -pv "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/test"
    cd "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/test"

    cp -v "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/test-env.exe" "test-env.exe"
    cp -v "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/test-sh.exe" "sh.exe"
    cp -v "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/bin/test-sh-null.exe" "sh-null.exe"
    cp -v "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/make.exe" "make.exe"
    cp -v "${XBB_BUILD_GIT_PATH}/tests/src/makefile" "makefile"
    (
      export WINEPATH="${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/test"
      run_host_app_verbose "${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/test/make"
    )
  )
  fi
}

function make_test()
{
  local test_bin_path="$1"

  echo
  echo "Checking the make shared libraries..."
  show_host_libs "${test_bin_path}/make"

  echo
  echo "Checking if make starts..."

  run_host_app_verbose "${test_bin_path}/make" --version
}

# -----------------------------------------------------------------------------
