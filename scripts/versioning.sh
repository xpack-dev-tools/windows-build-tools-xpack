# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function application_build_versioned_components()
{
  if [ "${XBB_REQUESTED_TARGET_PLATFORM}" != "win32" ]
  then
    echo
    echo "XBB_REQUESTED_TARGET_PLATFORM ${XBB_REQUESTED_TARGET_PLATFORM} not supported."
    exit 1
  fi

  if [[ "${XBB_RELEASE_VERSION}" =~ 4\.4\.0-* ]]
  then

    # -------------------------------------------------------------------------
    # Build the native dependencies.

    # None.

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_set_target "requested"

    # None.

    # -------------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_binaries_install "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"
    xbb_set_binaries_install "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"

    # http://ftpmirror.gnu.org/make/
    make_build "4.4"

    busybox_build "FRP-4716-g31467ddfc" # 9 Jun, 2022

    # -------------------------------------------------------------------------
  else
    echo "Unsupported version ${XBB_RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
