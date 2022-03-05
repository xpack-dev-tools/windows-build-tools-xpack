# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the second edition of the GNU MCU Eclipse build
# scripts. As the name implies, it should contain only functions and
# should be included with 'source' by the container build scripts.

# -----------------------------------------------------------------------------

function build_versions()
{
  if [ "${TARGET_PLATFORM}" != "win32" ]
  then
    echo
    echo "TARGET_PLATFORM ${TARGET_PLATFORM} not supported."
    exit 1
  fi

  # Test to build guile
  if false
  then

    do_gmp
    do_libtool
    do_libunistring
    do_libffi
    do_bdwgc
    do_libiconv

    do_guile
  fi

  # Remember the host compiler.
  HOSTCC=${CC}
  HOSTCXX=${CXX}

  prepare_gcc_env "${CROSS_COMPILE_PREFIX}-"

  # Note: 4.3 not functional yet.
  if [[ "${RELEASE_VERSION}" =~ 4\.3\.0-* ]]
  then
    (
      xbb_activate

      # Fails with
      # src/output.h:92:5: error: conflicting types for ‘fcntl’; have ‘int(intptr_t,  int, ...)’ {aka ‘int(long long int,  int, ...)’}
      build_make "4.3" --git-commit "667d70eac2b5c0d7b70941574fd51a76ae93b0f4"

      build_busybox "f3c5e8bc316af658260369fc2d4d1270c1f609b4" # Fwb 27, 2022

      if false
      then
        build_ncurses "6.2"
        # build_readline "8.1" # ncurses

        build_gettext "0.21"

        build_bash "5.1"
      fi
    )
  elif [[ "${RELEASE_VERSION}" =~ 4\.2\.1-* ]]
  then
    (
      xbb_activate

      build_make "4.2.1"

      # https://github.com/rmyorston/busybox-w32
      if [ "${RELEASE_VERSION}" == "4.2.1-3" ]
      then
        build_busybox "d239d2d5273e1620a6146d8f5076f6532e3569b1" # Oct 17, 2021
      else
        build_busybox "f902184fa8aa37b0ce8b725da5657ef2ed2005dd" # Dec 12, 2020
      fi
    )
  else
    echo "Unsupported version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
