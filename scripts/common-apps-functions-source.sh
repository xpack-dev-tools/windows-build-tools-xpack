# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
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
  # https://savannah.gnu.org/projects/make/
  # ftp://ftp.gnu.org/gnu/make/
  # http://ftpmirror.gnu.org/make/

  # 2016-06-11, "4.2.1"
  # 2020-01-20, "4.3" (fails with duplicate fcntl; fixed in git)

  local make_version="$1"
  shift

  local git_commit=""

  while [ $# -gt 0 ]
  do

    case "$1" in
      --git-commit)
        git_commit="$2"
        shift 2
        ;;

      *)
        echo "Unknown option $1, exit."
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

  local make_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-make-${make_version}-installed"
  if [ ! -f "${make_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    if [ ! -d "${SOURCES_FOLDER_PATH}/${make_src_folder_name}" ]
    then
      if [ ! -z "${git_commit}" ]
      then
        run_verbose git clone "${make_git_url}" "${make_src_folder_name}"
        (
          cd "${make_src_folder_name}"
          run_verbose git checkout -qf "${git_commit}"

          run_verbose echo sed -i.bak \
            -e 's|^isatty (int fd)$|__isatty (int fd)|' \
            -e 's|^ttyname (int fd)$|__ttyname (int fd)|' \
            src/w32/compat/posixfcn.c
        )
      else
        download_and_extract "${make_url}" "${make_archive_file_name}" \
          "${make_src_folder_name}" 
      fi

      if [ ! -x "${SOURCES_FOLDER_PATH}/${make_src_folder_name}/configure" ]
      then
        (
          cd "${SOURCES_FOLDER_PATH}/${make_src_folder_name}"

          xbb_activate_installed_bin

          if [ -f "bootstrap" ]
          then
            echo "Running make bootstrap..."
            run_verbose bash ${DEBUG} bootstrap      
          fi
        )
      fi
    fi

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${make_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${make_folder_name}"

      xbb_activate_installed_bin

      if [ ! -f "config.status" ]
      then
        (
          if [ "${IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running make configure..."

          # cd "${make_build_folder}"

          if [ "${IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${SOURCES_FOLDER_PATH}/${make_src_folder_name}/configure" --help
          fi

          # CPPFLAGS="${XBB_CPPFLAGS} -I${SOURCES_FOLDER_PATH}/${make_folder_name}/glob"
          CPPFLAGS="${XBB_CPPFLAGS} -DWINDOWS32 -DHAVE_CONFIG_H"
          CFLAGS="${XBB_CFLAGS_NO_W} -mthreads -std=gnu99"
          LDFLAGS="${XBB_LDFLAGS_APP} -mthreads -std=gnu99 -Wl,--allow-multiple-definition"

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

          config_options+=("ac_cv_dos_paths=yes")
          # config_options+=("ac_cv_func_fcntl=no")

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

      (
        mkdir -pv "${LIBS_INSTALL_FOLDER_PATH}/bin"

        run_verbose ${CC} "${BUILD_GIT_PATH}/tests/src/test-env.c" -o "${LIBS_INSTALL_FOLDER_PATH}/bin/test-env.exe"
        run_verbose ${CC} "${BUILD_GIT_PATH}/tests/src/test-sh.c" -o "${LIBS_INSTALL_FOLDER_PATH}/bin/test-sh.exe" -Wno-incompatible-pointer-types
        run_verbose ${CC} "${BUILD_GIT_PATH}/tests/src/test-sh.c" -o "${LIBS_INSTALL_FOLDER_PATH}/bin/test-sh-null.exe" -Wno-incompatible-pointer-types -D__USE_NULL_ENVP
      )
    )


    touch "${make_stamp_file_path}"

  else
    echo "make already installed."
  fi

  tests_add "test_make"

  run_app "${LIBS_INSTALL_FOLDER_PATH}/bin/test-env" one two
  run_app "${LIBS_INSTALL_FOLDER_PATH}/bin/test-sh" -c "${LIBS_INSTALL_FOLDER_PATH}/bin/test-env.exe" one two

  if true
  then
  (
    mkdir -pv "${LIBS_INSTALL_FOLDER_PATH}/test"
    cd "${LIBS_INSTALL_FOLDER_PATH}/test"

    cp -v "${LIBS_INSTALL_FOLDER_PATH}/bin/test-env.exe" "test-env.exe"
    cp -v "${LIBS_INSTALL_FOLDER_PATH}/bin/test-sh.exe" "sh.exe"
    cp -v "${LIBS_INSTALL_FOLDER_PATH}/bin/test-sh-null.exe" "sh-null.exe"
    cp -v "${APP_PREFIX}/bin/make.exe" "make.exe"
    cp -v "${BUILD_GIT_PATH}/tests/src/makefile" "makefile"
    (
      export WINEPATH="${LIBS_INSTALL_FOLDER_PATH}/test"
      run_app "${LIBS_INSTALL_FOLDER_PATH}/test/make"
    )
  )
  fi
}

function test_make()
{
  if [ -d "xpacks/.bin" ]
  then
    MAKE="xpacks/.bin/make"
  elif [ -d "${APP_PREFIX}/bin" ]
  then
    MAKE="${APP_PREFIX}/bin/make"
  else
    echo "Wrong folder."
    exit 1
  fi

  echo
  echo "Checking the make shared libraries..."
  show_libs "${MAKE}"

  echo
  echo "Checking if make starts..."

  run_app "${MAKE}" --version
}


function build_busybox()
{
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

  local busybox_commit="$1"
  local busybox_src_folder_name="busybox-w32-${busybox_commit}"

  local busybox_archive="${busybox_commit}.zip"
  local busybox_url="https://github.com/rmyorston/busybox-w32/archive/${busybox_archive}"

  local busybox_folder_name="${busybox_src_folder_name}"

  mkdir -pv "${LOGS_FOLDER_PATH}/${busybox_folder_name}"

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

      cd "${BUILD_FOLDER_PATH}/${busybox_folder_name}"

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_APP}"

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
          if [ "${IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running BusyBox configure..."

          if [ ${TARGET_BITS} == "32" ]
          then
            # On 32-bit containers running on 64-bit systems, stat() fails with
            # 'Value too large for defined data type'.
            # The solution is to add _FILE_OFFSET_BITS=64.
            export HOST_EXTRACFLAGS="-D_FILE_OFFSET_BITS=64"
            run_verbose make mingw32_defconfig \
              HOSTCC="${HOSTCC}" \
              HOSTCXX="${HOSTCXX}"
          elif [ ${TARGET_BITS} == "64" ]
          then
            run_verbose make mingw64_defconfig \
              HOSTCC="${HOSTCC}" \
              HOSTCXX="${HOSTCXX}"
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
              HOSTCC="${HOSTCC}" \
              HOSTCXX="${HOSTCXX}"

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

  tests_add "test_busybox"
}

function test_busybox()
{
  if [ -d "xpacks/.bin" ]
  then
    BUSYBOX="xpacks/.bin/busybox"
  elif [ -d "${APP_PREFIX}/bin" ]
  then
    BUSYBOX="${APP_PREFIX}/bin/busybox"
  else
    echo "Wrong folder."
    exit 1
  fi

  echo
  echo "Checking the busybox shared libraries..."
  show_libs "${BUSYBOX}"

  echo
  echo "Checking if busybox starts..."

  run_app "${BUSYBOX}" --help
}

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

  mkdir -pv "${LOGS_FOLDER_PATH}/${bash_folder_name}"

  local bash_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${bash_folder_name}-installed"
  if [ ! -f "${bash_stamp_file_path}" ]
  then

    echo
    echo "bash in-source building"

    if [ ! -d "${BUILD_FOLDER_PATH}/${bash_folder_name}" ]
    then 

      cd "${BUILD_FOLDER_PATH}"

      download_and_extract "${bash_url}" "${bash_archive}" \
        "${bash_src_folder_name}"

      if [ "${bash_src_folder_name}" != "${bash_folder_name}" ]
      then
        mv -v "${bash_src_folder_name}" "${bash_folder_name}"
      fi
    fi


    (
      cd "${BUILD_FOLDER_PATH}/${bash_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS} -DWORDEXP_OPTION"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_APP}"

      CC_FOR_BUILD="${HOSTCC}" 

      if [ "${TARGET_PLATFORM}" == "linux" ] # Not really.
      then
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
          if [ "${IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          run_verbose autoconf
          
          echo
          echo "Running bash configure..."

          run_verbose bash "${BUILD_FOLDER_PATH}/${bash_src_folder_name}/configure" --help

          config_options=()
          config_options+=("--prefix=${APP_PREFIX}")

          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

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

          run_verbose bash ${DEBUG} "${BUILD_FOLDER_PATH}/${bash_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${LOGS_FOLDER_PATH}/${bash_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${bash_folder_name}/configure-output.txt"
      fi

      (
        echo
        echo "Running bash make..."

        # Build.
        run_verbose make -j ${JOBS} \
          HISTORY_LDFLAGS= \
          READLINE_LDFLAGS= \
          LOCAL_LDFLAGS='-Wl,--export-all,--out-implib,lib$(@:.exe=.dll.a)'

        # make install-strip
        run_verbose make install-strip

        # run_verbose make -j1 check

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${bash_folder_name}/make-output.txt"
    )

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

    show_libs "${APP_PREFIX}/bin/bash"

    echo
    echo "Testing if bash binaries start properly..."

    run_app "${APP_PREFIX}/bin/bash" --version

    echo
    echo "Testing if bash binaries display help..."

    run_app "${APP_PREFIX}/bin/bash" --help
  ) 
}

# -----------------------------------------------------------------------------
