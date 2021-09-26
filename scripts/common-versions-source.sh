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

  if [[ "${RELEASE_VERSION}" =~ 4\.3\.0-* ]]
  then

    build_make "4.3" # fails on gcc 9 & mingw 7

    build_busybox "f902184fa8aa37b0ce8b725da5657ef2ed2005dd"

  elif [[ "${RELEASE_VERSION}" =~ 4\.2\.1-* ]]
  then

    build_make "4.2.1" # "4.3" fails on gcc 9 & mingw 7

    build_busybox "f902184fa8aa37b0ce8b725da5657ef2ed2005dd"

  else
    echo "Unsupported version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
