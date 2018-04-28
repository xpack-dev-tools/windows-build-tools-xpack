# -----------------------------------------------------------------------------

# Helper script used in the second edition of the GNU MCU Eclipse build 
# scripts. As the name implies, it should contain only functions and 
# should be included with 'source' by the container build scripts.

# -----------------------------------------------------------------------------

# The surprise of this build was that building the cross guile requires
# a native guile; thus the need to build everything twice, first the
# native build, than the cross build.

# -----------------------------------------------------------------------------

function do_make() 
{
  # The make executable is built using the source package from  
  # the open source MSYS2 project.
  # https://sourceforge.net/projects/msys2/

  MSYS2_MAKE_PACK_URL_BASE="http://sourceforge.net/projects/msys2/files"

  # http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/
  # http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/make-4.1-4.src.tar.gz/download

  # Warning! 4.2 does not build on Debian 8, it requires gettext-0.19.4.
  # 2016-06-15
  MAKE_VERSION="4.2.1"
  MSYS2_MAKE_VERSION_RELEASE="${MAKE_VERSION}-1"

  MSYS2_MAKE_FOLDER_NAME="make-${MSYS2_MAKE_VERSION_RELEASE}"
  local msys2_make_archive="${MSYS2_MAKE_FOLDER_NAME}.src.tar.gz"
  local msys2_make_url="${MSYS2_MAKE_PACK_URL_BASE}/REPOS/MSYS2/Sources/${msys2_make_archive}"

  MAKE_FOLDER_NAME="make-${MAKE_VERSION}"
  local make_archive="${MAKE_FOLDER_NAME}.tar.bz2"

  local make_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-make-installed"
  if [ ! -f "${make_stamp_file_path}" ]
  then

    if [ ! -f "${WORK_FOLDER_PATH}/msys2/make/${make_archive}" ]
    then
      (
        mkdir -p "${WORK_FOLDER_PATH}/msys2"
        cd "${WORK_FOLDER_PATH}/msys2"

        download_and_extract "${msys2_make_url}" "${msys2_make_archive}" "make"
      )
    fi

    if [ ! -d "${WORK_FOLDER_PATH}/${MAKE_FOLDER_NAME}" ]
    then
      (
        cd "${WORK_FOLDER_PATH}"
        echo
        echo "Unpacking ${make_archive}..."

        tar -xvf "${WORK_FOLDER_PATH}/msys2/make/${make_archive}"

        cd "${WORK_FOLDER_PATH}/${MAKE_FOLDER_NAME}"
        
        xbb_activate

        echo "Running make autoreconf..."
        autoreconf -fi
      )
    fi

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${MAKE_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${MAKE_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then 
        echo
        echo "Running make configure..."

        # cd "${make_build_folder}"

        bash "${WORK_FOLDER_PATH}/${MAKE_FOLDER_NAME}"/configure --help

        export CFLAGS="${EXTRA_CFLAGS}"
        export LDFLAGS="${EXTRA_LDFLAGS} -static"

        echo
        bash "${WORK_FOLDER_PATH}/${MAKE_FOLDER_NAME}"/configure \
          --prefix="${INSTALL_FOLDER_PATH}/make-${MAKE_VERSION}"  \
          --build=${BUILD} \
          --host=${HOST} \
          --target=${TARGET} \
          \
          --without-guile \
          --without-libintl-prefix \
          --without-libiconv-prefix \
          ac_cv_dos_paths=yes \
          \
        | tee "${INSTALL_FOLDER_PATH}/configure-make-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-make-log.txt

      fi

      echo
      echo "Running make make..."

      (
        # Build.
        make ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}"/make-make-output.txt
    )

    touch "${make_stamp_file_path}"

  else
    echo "make already installed."
  fi
}

function do_busybox() 
{
  # https://frippery.org/busybox/
  # https://github.com/rmyorston/busybox-w32

  # BUSYBOX_COMMIT=master
  # BUSYBOX_COMMIT="9fe16f6102d8ab907c056c484988057904092c06"
  # BUSYBOX_COMMIT="977d65c1bbc57f5cdd0c8bfd67c8b5bb1cd390dd"
  # BUSYBOX_COMMIT="9fa1e4990e655a85025c9d270a1606983e375e47"
  # BUSYBOX_COMMIT="c2002eae394c230d6b89073c9ff71bc86a7875e8"
  # Dec 9, 2017
  # BUSYBOX_COMMIT="096aee2bb468d1ab044de36e176ed1f6c7e3674d"
  # Apr 13, 2018
  BUSYBOX_COMMIT="6f7d1af269eed4b42daeb9c6dfd2ba62f9cd47e4"

  BUSYBOX_ARCHIVE="${BUSYBOX_COMMIT}.zip"
  BUSYBOX_URL="https://github.com/rmyorston/busybox-w32/archive/${BUSYBOX_ARCHIVE}"

  BUSYBOX_SRC_FOLDER="${BUSYBOX_COMMIT}/busybox-w32-${BUSYBOX_COMMIT}"

  # Does not use configure and builds in the source folder.
  cd "${BUILD_FOLDER_PATH}"

  download_and_extract "${BUSYBOX_URL}" "${BUSYBOX_ARCHIVE}" "${BUSYBOX_SRC_FOLDER}"

  local busybox_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-busybox-installed"
  if [ ! -f "${busybox_stamp_file_path}" ]
  then

    (
      cd "${BUILD_FOLDER_PATH}"

      xbb_activate

      if [ ! -f "${BUILD_FOLDER_PATH}/${BUSYBOX_SRC_FOLDER}"/.config ]
      then

        echo
        echo "Running BusyBox configure..."

        (
          cd "${BUILD_FOLDER_PATH}/${BUSYBOX_SRC_FOLDER}"/configs
          sed \
            -e 's/CONFIG_CROSS_COMPILER_PREFIX=".*"/CONFIG_CROSS_COMPILER_PREFIX="i686-w64-mingw32-"/' \
            <mingw32_defconfig >gnu-mcu-eclipse_32_mingw_defconfig

          sed \
            -e 's/CONFIG_CROSS_COMPILER_PREFIX=".*"/CONFIG_CROSS_COMPILER_PREFIX="x86_64-w64-mingw32-"/' \
            <mingw32_defconfig >gnu-mcu-eclipse_64_mingw_defconfig

          echo 
          echo "Running BusyBox make gnu-mcu-eclipse_${TARGET_BITS}_mingw_defconfig..."

          cd "${BUILD_FOLDER_PATH}/${BUSYBOX_SRC_FOLDER}"

          make  "${JOBS}" "gnu-mcu-eclipse_${TARGET_BITS}_mingw_defconfig"
          
        ) | tee "${INSTALL_FOLDER_PATH}/configure-busybox-output.txt"
      fi

      if [ ! -f "${BUILD_FOLDER_PATH}/${BUSYBOX_SRC_FOLDER}"/busybox.exe ]
      then

        echo 
        echo "Running BusyBox make..."

        (
          export CFLAGS="${EXTRA_CFLAGS} -Wno-format-extra-args -Wno-format -Wno-overflow -Wno-unused-variable -Wno-implicit-function-declaration -Wno-unused-parameter -Wno-maybe-uninitialized -Wno-pointer-to-int-cast -Wno-strict-prototypes -Wno-old-style-definition -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-discarded-qualifiers -Wno-strict-prototypes -Wno-old-style-definition -Wno-unused-function -Wno-int-to-pointer-cast"
          export LDFLAGS="${EXTRA_LDFLAGS} -static"

          cd "${BUILD_FOLDER_PATH}/${BUSYBOX_SRC_FOLDER}"
          if [ ${TARGET_BITS} == "32" ]
          then
            make  "${JOBS}"
          elif [ ${TARGET_BITS} == "64" ]
          then
            make "${JOBS}" mingw64_defconfig
            make "${JOBS}"
          fi

          mkdir -p "${INSTALL_FOLDER_PATH}"/busybox-w32/bin
          cp busybox.exe "${INSTALL_FOLDER_PATH}"/busybox-w32/bin
        ) | tee "${INSTALL_FOLDER_PATH}"/make-busybox-output.txt
      fi
    )
    touch "${busybox_stamp_file_path}"

  else
    echo "BusyBox already installed."
  fi

}

function copy_binaries()
{
  mkdir -p "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}"/bin

  (
    xbb_activate

    echo
    echo "Copy make to install bin..."

    cp -v "${INSTALL_FOLDER_PATH}/make-${MAKE_VERSION}"/bin/make.exe \
      "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}"/bin

    ${CROSS_COMPILE_PREFIX}-strip \
      "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}"/bin/make.exe

    echo
    echo "Copy BusyBox to install bin..."

    cp -v "${INSTALL_FOLDER_PATH}"/busybox-w32/bin/busybox.exe \
      "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}"/bin

    ${CROSS_COMPILE_PREFIX}-strip \
      "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}"/bin/busybox.exe

    (
      cd "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}"/bin

      cp -v "busybox.exe" "sh.exe"
      cp -v "busybox.exe" "rm.exe"
      cp -v "busybox.exe" "echo.exe"
      cp -v "busybox.exe" "mkdir.exe"
    )
  )
}

function check_binaries()
{
  echo
  echo "Checking binaries for unwanted DLLs..."

  local binaries=$(find "${INSTALL_FOLDER_PATH}/${APP_LC_NAME}"/bin -name \*.exe)
  for bin in ${binaries} 
  do
    check_binary ${bin}
  done
}

function copy_gme_files()
{
  rm -rf "${APP_PREFIX}"/${DISTRO_LC_NAME}
  mkdir -p "${APP_PREFIX}"/${DISTRO_LC_NAME}

  echo
  echo "Copying license files..."

  copy_license \
    "${WORK_FOLDER_PATH}/${MAKE_FOLDER_NAME}" \
    "${MAKE_FOLDER_NAME}"

  copy_license \
    "${BUILD_FOLDER_PATH}/${BUSYBOX_SRC_FOLDER}" \
    "busybox-w32"

  copy_build_files

  echo
  echo "Copying GME files..."

  cd "${WORK_FOLDER_PATH}"/build.git
  /usr/bin/install -v -c -m 644 "README-out.md" \
    "${APP_PREFIX}"/README.md
}
