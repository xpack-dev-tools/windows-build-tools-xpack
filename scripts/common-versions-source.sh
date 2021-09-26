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

  if [[ "${RELEASE_VERSION}" =~ 4\.3\.0-* ]]
  then
    (
      xbb_activate

      # Fails with
      # src/output.h:92:5: error: conflicting types for ‘fcntl’; have ‘int(intptr_t,  int, ...)’ {aka ‘int(long long int,  int, ...)’}
      build_make "4.3"

      build_busybox "90b3ba992ecb39e32e5a66b2e37579becc56d286"
    )
  elif [[ "${RELEASE_VERSION}" =~ 4\.2\.1-* ]]
  then
    (
      xbb_activate

      build_make "4.2.1"

      if [ "${RELEASE_VERSION}" == "4.2.1-3" ]
      then
        build_busybox "90b3ba992ecb39e32e5a66b2e37579becc56d286"
      else
        build_busybox "f902184fa8aa37b0ce8b725da5657ef2ed2005dd"
      fi
    )
  else
    echo "Unsupported version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
