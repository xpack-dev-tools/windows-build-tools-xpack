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

function do_gmp()
{
  # https://gmplib.org
  # https://gmplib.org/download/gmp/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gmp-hg

  # 01-Nov-2015
  # GMP_VERSION="6.1.0"
  # 16-Dec-2016
  # GMP_VERSION="6.1.2"
  GMP_VERSION="6.1.0"

  GMP_FOLDER_NAME="gmp-${GMP_VERSION}"
  local gmp_archive="${GMP_FOLDER_NAME}.tar.xz"
  # local gmp_url="https://gmplib.org/download/gmp/${gmp_archive}"
  local gmp_url="https://github.com/gnu-mcu-eclipse/files/raw/master/libs/${gmp_archive}"

  local gmp_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-gmp-installed"
  if [ ! -f "${gmp_stamp_file_path}" ]
  then

    cd "${WORK_FOLDER_PATH}"

    download_and_extract "${gmp_url}" "${gmp_archive}" "${GMP_FOLDER_NAME}"

    # Native build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}-native/${GMP_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}-native/${GMP_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running native gmp configure..."

        # ABI is mandatory, otherwise configure fails on 32-bits.
        # (see https://gmplib.org/manual/ABI-and-ISA.html)

        bash "${WORK_FOLDER_PATH}/${GMP_FOLDER_NAME}/configure" --help

        export CFLAGS="-Wno-unused-value -Wno-empty-translation-unit -Wno-tautological-compare -Wno-overflow"
        export CPPFLAGS="-I${INSTALL_FOLDER_PATH}-native/include"
        export LDFLAGS="-L${INSTALL_FOLDER_PATH}-native/lib"
        export ABI="${TARGET_BITS}"
     
        bash "${WORK_FOLDER_PATH}/${GMP_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}-native" \
          \
          --build=${BUILD} \
          --host=${BUILD} \
          --target=${BUILD} \
          \
          --disable-shared \
          --enable-static \
          --enable-cxx \
        | tee "${INSTALL_FOLDER_PATH}/configure-native-gmp-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-native-gmp-log.txt

      fi

      echo
      echo "Running native gmp make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-gmp-output.txt"
    )

    # Cross build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${GMP_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${GMP_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running gmp configure..."

        # ABI is mandatory, otherwise configure fails on 32-bits.
        # (see https://gmplib.org/manual/ABI-and-ISA.html)

        bash "${WORK_FOLDER_PATH}/${GMP_FOLDER_NAME}/configure" --help

        export CFLAGS="-Wno-unused-value -Wno-empty-translation-unit -Wno-tautological-compare -Wno-overflow"
        export CPPFLAGS="${EXTRA_CPPFLAGS}"
        export LDFLAGS="${EXTRA_LDFLAGS}"
        export ABI="${TARGET_BITS}"
     
        bash "${WORK_FOLDER_PATH}/${GMP_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}" \
          \
          --build=${BUILD} \
          --host=${HOST} \
          --target=${TARGET} \
          \
          --disable-shared \
          --enable-static \
          --enable-cxx \
        | tee "${INSTALL_FOLDER_PATH}/configure-gmp-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-gmp-log.txt

      fi

      echo
      echo "Running gmp make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-gmp-output.txt"
    )

    touch "${gmp_stamp_file_path}"

  else
    echo "Library gmp already installed."
  fi
}

function do_libtool()
{
  # https://www.gnu.org/software/libtool/
  # http://gnu.mirrors.linux.ro/libtool/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libtool-git

  # 2015-02-16
  LIBTOOL_VERSION="2.4.6"

  LIBTOOL_FOLDER_NAME="libtool-${LIBTOOL_VERSION}"
  local libtool_archive="${LIBTOOL_FOLDER_NAME}.tar.gz"
  # local libtool_url="http://www.mr511.de/software/${libtool_archive}"
  local libtool_url="http://mirrors.nav.ro/gnu/libtool/${libtool_archive}"

  local libtool_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libtool-installed"
  if [ ! -f "${libtool_stamp_file_path}" ]
  then

    cd "${WORK_FOLDER_PATH}"

    download_and_extract "${libtool_url}" "${libtool_archive}" "${LIBTOOL_FOLDER_NAME}"

    # Native build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}-native/${LIBTOOL_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}-native/${LIBTOOL_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running native libtool configure..."

        bash "${WORK_FOLDER_PATH}/${LIBTOOL_FOLDER_NAME}/configure" --help

        export CFLAGS="${EXTRA_CFLAGS}"
        export CPPFLAGS="-I${INSTALL_FOLDER_PATH}-native/include"
        export LDFLAGS="-L${INSTALL_FOLDER_PATH}-native/lib"

        bash "${WORK_FOLDER_PATH}/${LIBTOOL_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}-native" \
          \
          --build=${BUILD} \
          --host=${BUILD} \
          --target=${BUILD} \
          \
          --disable-shared \
          --enable-static \
          --disable-nls \
          --disable-rpath \
        | tee "${INSTALL_FOLDER_PATH}/configure-native-libtool-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-native-libtool-log.txt

      fi

      echo
      echo "Running native libtool make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-native-libtool-output.txt"
    )

    # Cross build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${LIBTOOL_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${LIBTOOL_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running libtool configure..."

        bash "${WORK_FOLDER_PATH}/${LIBTOOL_FOLDER_NAME}/configure" --help

        export CFLAGS="${EXTRA_CFLAGS}"
        export CPPFLAGS="${EXTRA_CPPFLAGS}"
        export LDFLAGS="${EXTRA_LDFLAGS}"

        bash "${WORK_FOLDER_PATH}/${LIBTOOL_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}" \
          \
          --build=${BUILD} \
          --host=${HOST} \
          --target=${TARGET} \
          \
          --disable-shared \
          --enable-static \
          --disable-nls \
          --disable-rpath \
        | tee "${INSTALL_FOLDER_PATH}/configure-libtool-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-libtool-log.txt

      fi

      echo
      echo "Running libtool make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-libtool-output.txt"
    )

    touch "${libtool_stamp_file_path}"

  else
    echo "Library libtool already installed."
  fi
}

function do_libunistring()
{
  # https://www.gnu.org/software/libunistring/
  # https://ftp.gnu.org/gnu/libunistring/

  # 2018-02-28
  LIBUNISTRING_VERSION="0.9.9"

  LIBUNISTRING_FOLDER_NAME="libunistring-${LIBUNISTRING_VERSION}"
  local libunistring_archive="${LIBUNISTRING_FOLDER_NAME}.tar.xz"
  local libunistring_url="http://ftp.gnu.org/gnu/libunistring/${libunistring_archive}"

  local libunistring_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libunistring-installed"
  if [ ! -f "${libunistring_stamp_file_path}" ]
  then

    cd "${WORK_FOLDER_PATH}"

    download_and_extract "${libunistring_url}" "${libunistring_archive}" "${LIBUNISTRING_FOLDER_NAME}"

    # Native build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}-native/${LIBUNISTRING_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}-native/${LIBUNISTRING_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running native libunistring configure..."

        bash "${WORK_FOLDER_PATH}/${LIBUNISTRING_FOLDER_NAME}/configure" --help

        export CFLAGS="${EXTRA_CFLAGS} -Wno-pointer-to-int-cast"
        export CPPFLAGS="-I${INSTALL_FOLDER_PATH}-native/include"
        export LDFLAGS="-L${INSTALL_FOLDER_PATH}-native/lib"

        bash "${WORK_FOLDER_PATH}/${LIBUNISTRING_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}-native" \
          \
          --build=${BUILD} \
          --host=${BUILD} \
          --target=${BUILD} \
          \
          --disable-shared \
          --enable-static \
        | tee "${INSTALL_FOLDER_PATH}/configure-native-libunistring-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-native-libunistring-log.txt

      fi

      echo
      echo "Running native libunistring make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-native-libunistring-output.txt"
    )

    # Cross build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${LIBUNISTRING_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${LIBUNISTRING_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running libunistring configure..."

        bash "${WORK_FOLDER_PATH}/${LIBUNISTRING_FOLDER_NAME}/configure" --help

        export CFLAGS="${EXTRA_CFLAGS} -Wno-pointer-to-int-cast"
        export CPPFLAGS="${EXTRA_CPPFLAGS}"
        export LDFLAGS="${EXTRA_LDFLAGS_LIB}"

        bash "${WORK_FOLDER_PATH}/${LIBUNISTRING_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}" \
          \
          --build=${BUILD} \
          --host=${HOST} \
          --target=${TARGET} \
          \
          --disable-shared \
          --enable-static \
        | tee "${INSTALL_FOLDER_PATH}/configure-libunistring-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-libunistring-log.txt

      fi

      echo
      echo "Running libunistring make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-libunistring-output.txt"
    )

    touch "${libunistring_stamp_file_path}"

  else
    echo "Library libunistring already installed."
  fi
}

function do_libffi()
{
  # https://sourceware.org/libffi/
  # https://sourceware.org/pub/libffi/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libffi-git

  LIBFFI_VERSION="3.2.1"

  LIBFFI_FOLDER_NAME="libffi-${LIBFFI_VERSION}"
  local libffi_archive="${LIBFFI_FOLDER_NAME}.tar.gz"

  # local libffi_url="http://isl.gforge.inria.fr/${libffi_archive}"
  local libffi_url="https://sourceware.org/pub/libffi/${libffi_archive}"

  local libffi_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libffi-installed"
  if [ ! -f "${libffi_stamp_file_path}" ]
  then

    cd "${WORK_FOLDER_PATH}"

    download_and_extract "${libffi_url}" "${libffi_archive}" "${LIBFFI_FOLDER_NAME}"

    # Native build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}-native/${LIBFFI_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}-native/${LIBFFI_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running native libffi configure..."

        bash "${WORK_FOLDER_PATH}/${LIBFFI_FOLDER_NAME}/configure" --help

        export CFLAGS="${EXTRA_CFLAGS}"
        export CPPFLAGS="-I${INSTALL_FOLDER_PATH}-native/include"
        export LDFLAGS="-L${INSTALL_FOLDER_PATH}-native/lib"

        bash "${WORK_FOLDER_PATH}/${LIBFFI_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}-native" \
          \
          --build=${BUILD} \
          --host=${BUILD} \
          --target=${BUILD} \
          \
          --disable-shared \
          --enable-static \
          --disable-nls \
        | tee "${INSTALL_FOLDER_PATH}"/configure-native-libffi-output.txt
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-native-libffi-log.txt

      fi

      echo
      echo "Running native libffi make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-native-libffi-output.txt"
    )

    # Cross build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${LIBFFI_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${LIBFFI_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running libffi configure..."

        bash "${WORK_FOLDER_PATH}/${LIBFFI_FOLDER_NAME}/configure" --help

        export CFLAGS="${EXTRA_CFLAGS}"
        export CPPFLAGS="${EXTRA_CPPFLAGS}"
        export LDFLAGS="${EXTRA_LDFLAGS_LIB}"

        bash "${WORK_FOLDER_PATH}/${LIBFFI_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}" \
          \
          --build=${BUILD} \
          --host=${HOST} \
          --target=${TARGET} \
          \
          --disable-shared \
          --enable-static \
        | tee "${INSTALL_FOLDER_PATH}"/configure-libffi-output.txt
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-libffi-log.txt

      fi

      echo
      echo "Running libffi make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-libffi-output.txt"
    )

    touch "${libffi_stamp_file_path}"

  else
    echo "Library libffi already installed."
  fi
}

function do_bdwgc()
{
  # http://www.hboehm.info/gc/
  # http://www.hboehm.info/gc/gc_source/

  BDWGC_VERSION="7.6.4"

  BDWGC_FOLDER_NAME="gc-${BDWGC_VERSION}"
  local bdwgc_archive="${BDWGC_FOLDER_NAME}.tar.gz"

  local bdwgc_url="http://www.hboehm.info/gc/gc_source/${bdwgc_archive}"

  LIBATOMIC_VERSION="7.6.2"
  LIBATOMIC_FOLDER_NAME="libatomic_ops-${LIBATOMIC_VERSION}"
  local libatomic_archive="${LIBATOMIC_FOLDER_NAME}.tar.gz"

  local libatomic_url="http://www.hboehm.info/gc/gc_source/${libatomic_archive}"

  local bdwgc_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-bdwgc-installed"
  if [ ! -f "${bdwgc_stamp_file_path}" ]
  then

    cd "${WORK_FOLDER_PATH}"

    download_and_extract "${bdwgc_url}" "${bdwgc_archive}" "${BDWGC_FOLDER_NAME}"
    download_and_extract "${libatomic_url}" "${libatomic_archive}" "${LIBATOMIC_FOLDER_NAME}"

    cd "${WORK_FOLDER_PATH}/${BDWGC_FOLDER_NAME}"
    if [ ! -d libatomic_ops ]
    then
      ln -s "${WORK_FOLDER_PATH}/${LIBATOMIC_FOLDER_NAME}" libatomic_ops
    fi

    (
      xbb_activate
      autoreconf -vif
      automake --add-missing
    )

    # Native build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}-native/${BDWGC_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}-native/${BDWGC_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running native bdwgc configure..."

        bash "${WORK_FOLDER_PATH}/${BDWGC_FOLDER_NAME}/configure" --help

        export CFLAGS="${EXTRA_CFLAGS}"
        export CPPFLAGS="-I${INSTALL_FOLDER_PATH}-native/include"
        export LDFLAGS="-L${INSTALL_FOLDER_PATH}-native/lib"

        bash "${WORK_FOLDER_PATH}/${BDWGC_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}-native" \
          \
          --build=${BUILD} \
          --host=${BUILD} \
          --target=${BUILD} \
          \
          --disable-shared \
          --enable-static \
          --disable-nls \
        | tee "${INSTALL_FOLDER_PATH}/configure-native-bdwgc-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-native-bdwgc-log.txt

      fi

      echo
      echo "Running native bdwgc make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-native-bdwgc-output.txt"
    )

    # Cross build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${BDWGC_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${BDWGC_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running bdwgc configure..."

        bash "${WORK_FOLDER_PATH}/${BDWGC_FOLDER_NAME}/configure" --help

        export CFLAGS="${EXTRA_CFLAGS}"
        export CPPFLAGS="${EXTRA_CPPFLAGS}"
        export LDFLAGS="${EXTRA_LDFLAGS_LIB}"

        bash "${WORK_FOLDER_PATH}/${BDWGC_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}" \
          \
          --build=${BUILD} \
          --host=${HOST} \
          --target=${TARGET} \
          \
          --disable-shared \
          --enable-static \
          --disable-nls \
        | tee "${INSTALL_FOLDER_PATH}/configure-bdwgc-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-bdwgc-log.txt

      fi

      echo
      echo "Running bdwgc make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-bdwgc-output.txt"
    )

    touch "${bdwgc_stamp_file_path}"

  else
    echo "Library bdwgc already installed."
  fi
}

function do_libiconv()
{
  # https://www.gnu.org/software/libiconv/
  # https://ftp.gnu.org/pub/gnu/libiconv/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libiconv

  # 2011-08-07
  # LIBICONV_VERSION="1.14"
  # 2017-02-02
  # LIBICONV_VERSION="1.15"
  LIBICONV_VERSION="1.14"

  LIBICONV_FOLDER_NAME="libiconv-${LIBICONV_VERSION}"
  local libiconv_archive="${LIBICONV_FOLDER_NAME}.tar.gz"
  local libiconv_url="https://ftp.gnu.org/pub/gnu/libiconv/${libiconv_archive}"

  local libiconv_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-libiconv-installed"
  if [ ! -f "${libiconv_stamp_file_path}" ]
  then

    cd "${WORK_FOLDER_PATH}"

    download_and_extract "${libiconv_url}" "${libiconv_archive}" "${LIBICONV_FOLDER_NAME}"

    # Native build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}-native/${LIBICONV_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}-native/${LIBICONV_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running native libiconv configure..."

        bash "${WORK_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}/configure" --help

        # -fgnu89-inline fixes "undefined reference to `aliases2_lookup'"
        #  https://savannah.gnu.org/bugs/?47953
        export CFLAGS="${EXTRA_CFLAGS} -fgnu89-inline -Wno-tautological-compare -Wno-parentheses-equality -Wno-static-in-inline -Wno-pointer-to-int-cast"
        export CPPFLAGS="-I${INSTALL_FOLDER_PATH}-native/include"
        export LDFLAGS="-L${INSTALL_FOLDER_PATH}-native/lib"

        bash "${WORK_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}-native" \
          \
          --build=${BUILD} \
          --host=${BUILD} \
          --target=${BUILD} \
          \
          --disable-shared \
          --enable-static \
          --disable-nls \
        | tee "${INSTALL_FOLDER_PATH}/configure-native-libiconv-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-native-libiconv-log.txt

      fi

      echo
      echo "Running native libiconv make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-native-libiconv-output.txt"
    )

    # Cross build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running libiconv configure..."

        bash "${WORK_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}/configure" --help

        # -fgnu89-inline fixes "undefined reference to `aliases2_lookup'"
        #  https://savannah.gnu.org/bugs/?47953
        export CFLAGS="${EXTRA_CFLAGS} -fgnu89-inline -Wno-tautological-compare -Wno-parentheses-equality -Wno-static-in-inline -Wno-pointer-to-int-cast"
        export CPPFLAGS="${EXTRA_CPPFLAGS}"
        export LDFLAGS="${EXTRA_LDFLAGS}"

        bash "${WORK_FOLDER_PATH}/${LIBICONV_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}" \
          \
          --build=${BUILD} \
          --host=${HOST} \
          --target=${TARGET} \
          \
          --disable-shared \
          --enable-static \
          --disable-nls \
        | tee "${INSTALL_FOLDER_PATH}/configure-libiconv-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-libiconv-log.txt

      fi

      echo
      echo "Running libiconv make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-libiconv-output.txt"
    )

    touch "${libiconv_stamp_file_path}"

  else
    echo "Library libiconv already installed."
  fi
}

function do_guile()
{
  # https://www.gnu.org/software/guile/
  # https://ftp.gnu.org/gnu/guile/
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=guile-git

  # 2017-02-13
  # make searches for 2.0 or 1.8
  GUILE_VERSION="2.0.14"
  # 2017-12-01
  # GUILE_VERSION="2.2.3"

  GUILE_FOLDER_NAME="guile-${GUILE_VERSION}"
  # local guile_archive="${GUILE_FOLDER_NAME}.tar.xz"
  # local guile_url="https://ftp.gnu.org/gnu/guile/${guile_archive}"

  MSYS2_GUILE_PACK_URL_BASE="http://sourceforge.net/projects/msys2/files"

  # http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/
  # https://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/guile-2.0.14-1.src.tar.gz/download

  MSYS2_GUILE_VERSION_RELEASE="${GUILE_VERSION}-1"

  MSYS2_GUILE_FOLDER_NAME="guile-${MSYS2_GUILE_VERSION_RELEASE}"
  local msys2_guile_archive="${MSYS2_GUILE_FOLDER_NAME}.src.tar.gz"
  local msys2_guile_url="${MSYS2_GUILE_PACK_URL_BASE}/REPOS/MSYS2/Sources/${msys2_guile_archive}"
  local guile_archive="${GUILE_FOLDER_NAME}.tar.gz"

  local guile_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-guile-installed"
  if [ ! -f "${guile_stamp_file_path}" ]
  then

    cd "${WORK_FOLDER_PATH}"

    # download_and_extract "${guile_url}" "${guile_archive}" "${GUILE_FOLDER_NAME}"

    if [ ! -f "${WORK_FOLDER_PATH}/msys2/guile/${guile_archive}" ]
    then
      (
        mkdir -p "${WORK_FOLDER_PATH}/msys2"
        cd "${WORK_FOLDER_PATH}/msys2"

        download_and_extract "${msys2_guile_url}" "${msys2_guile_archive}" "guile"
      )
    fi

    if [ ! -d "${WORK_FOLDER_PATH}/${GUILE_FOLDER_NAME}" ]
    then
      (
        cd "${WORK_FOLDER_PATH}"
        echo
        echo "Unpacking ${guile_archive}..."

        tar -xvf "${WORK_FOLDER_PATH}/msys2/guile/${guile_archive}"

        cd "${WORK_FOLDER_PATH}/${GUILE_FOLDER_NAME}"

        patch -p1 -i "${WORK_FOLDER_PATH}"/msys2/guile/guile-2.2.2-msys2.patch

        xbb_activate

        cp -rf build-aux/snippet "${WORK_FOLDER_PATH}"/msys2/guile/snippet
        autoreconf -fi
        cp -f "${WORK_FOLDER_PATH}"/msys2/guile/snippet/*.* build-aux/snippet/
      )
    fi

    # Native build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}-native/${GUILE_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}-native/${GUILE_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running native guile configure..."

        bash "${WORK_FOLDER_PATH}/${GUILE_FOLDER_NAME}"/configure --help

        export CFLAGS="${EXTRA_CFLAGS} -Wno-implicit-fallthrough -Wno-unused-but-set-variable -Wno-shift-count-overflow"
        export CPPFLAGS="-I${INSTALL_FOLDER_PATH}-native/include"
        export LDFLAGS="-L${INSTALL_FOLDER_PATH}-native/lib"
        # Without it, two GC definitions will have conflicting defs.
        export LIBS="-lpthread"
        export PKG_CONFIG_LIBDIR="${INSTALL_FOLDER_PATH}-native"/lib/pkgconfig

        bash "${WORK_FOLDER_PATH}/${GUILE_FOLDER_NAME}"/configure \
          --prefix="${INSTALL_FOLDER_PATH}-native" \
          \
          --build=${BUILD} \
          --host=${BUILD} \
          --target=${BUILD} \
          \
          --disable-shared \
          --enable-static \
          \
          --disable-rpath \
          --disable-nls \
          --disable-error-on-warning \
          --with-threads \
          --with-libiconv-prefix="${INSTALL_FOLDER_PATH}-native" \
          --with-libunistring-prefix="${INSTALL_FOLDER_PATH}-native" \
        | tee "${INSTALL_FOLDER_PATH}"/configure-native-guile-output.txt
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-native-guile-log.txt

      fi

      echo
      echo "Running native guile make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}"/make-native-guile-output.txt
    )

    # Cross build.
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${GUILE_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${GUILE_FOLDER_NAME}"

      xbb_activate

      if [ ! -f "config.status" ]
      then

        echo
        echo "Running guile configure..."

        bash "${WORK_FOLDER_PATH}/${GUILE_FOLDER_NAME}/configure" --help

        export CFLAGS="${EXTRA_CFLAGS} -Wno-implicit-fallthrough -Wno-unused-but-set-variable -Wno-shift-count-overflow -Wno-implicit-function-declaration -Wno-return-type -Wno-unused-function -Wno-pointer-to-int-cast"
        export CPPFLAGS="${EXTRA_CPPFLAGS}"
        export LDFLAGS="${EXTRA_LDFLAGS}"
        export GUILE_FOR_BUILD="${INSTALL_FOLDER_PATH}-native"/bin/guile

        # Config inspired from msys2, but with threads, without nls.
        # --disable-networking due to missing netinet/tcp.h
        bash "${WORK_FOLDER_PATH}/${GUILE_FOLDER_NAME}/configure" \
          --prefix="${INSTALL_FOLDER_PATH}" \
          \
          --build=${BUILD} \
          --host=${HOST} \
          --target=${TARGET} \
          \
          --disable-shared \
          --enable-static \
          \
          --disable-nls \
          --with-threads \
          \
          --disable-debug-malloc \
          --disable-guile-debug \
          --disable-error-on-warning \
          --disable-rpath \
          --enable-deprecated \
          --enable-networking \
          --enable-posix \
          --enable-regex \
          --with-modules \
          \
        | tee "${INSTALL_FOLDER_PATH}/configure-guile-output.txt"
        cp "config.log" "${INSTALL_FOLDER_PATH}"/config-guile-log.txt

      fi

      echo
      echo "Running guile make..."

      (
        # Build.
        make -j ${JOBS}
        make install-strip
      ) | tee "${INSTALL_FOLDER_PATH}/make-guile-output.txt"
    )

    touch "${guile_stamp_file_path}"

  else
    echo "Library guile already installed."
  fi
}

# -----------------------------------------------------------------------------
