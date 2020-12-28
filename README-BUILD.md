# How to build the xPack Windows Build Tools

## Introduction

This project includes the scripts and additional files required to
build and publish the
[xPack Windows Build Tools](https://xpack.github.io/windows-build-tools/) binaries.

## Referred URLs

The build scripts use sources from the MSYS2 and Busybox projects:

- `http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/`
- `https://github.com/rmyorston/busybox-w32.git`

## Branches

- `xpack` - the updated content, used during builds
- `xpack-develop` - the updated content, used during development
- `master` - no content

## Download the build scripts repo

The build script is available from GitHub and can be
[viewed online](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/master/scripts/build.sh).

To download it, clone the
[xpack-dev-tools/windows-build-tools-xpack](https://github.com/xpack-dev-tools/windows-build-tools-xpack)
Git repo, including submodules.

```console
$ rm -rf ~/Downloads/windows-build-tools-xpack.git
$ git clone --recurse-submodules https://github.com/xpack-dev-tools/windows-build-tools-xpack.git \
  ~/Downloads/windows-build-tools-xpack.git
```

## The `Work` folder

The script creates a temporary build `Work/windows-build-tools-${version}`
folder in the user home. Although not recommended, if for any reasons
you need to change the location of the `Work` folder,
you can redefine `WORK_FOLDER_PATH` variable before invoking the script.

## Spaces in folder names

Due to the limitations of `make`, builds started in folders which
include spaces in the names are known to fail.

If on your system the work folder in in such a location, redefine it in a
folder without spaces and set the `WORK_FOLDER_PATH` variable before invoking 
the script.

## Customizations

There are many other settings that can be redefined via
environment variables. If necessary,
place them in a file and pass it via `--env-file`. This file is
either passed to Docker or sourced to shell. The Docker syntax
**is not** identical to shell, so some files may
not be accepted by bash.

## Prerequisites

The prerequisites are common to all binary builds. Please follow the
instructions from the separate
[Prerequisites for building xPack binaries](https://xpack.github.io/xbb/prerequisites/)
page and return when ready.

## Prepare release

To prepare a new release, first determine the version (like `4.2.1-2`) and
update the `scripts/VERSION` file.

## Update CHANGELOG.txt

Check `windows-build-tools-xpack.git/CHANGELOG.txt` and add the new release.

## Build

The current platform for Windows production builds is a
Debian 10, running on an Intel NUC8i7BEH mini PC with 32 GB of RAM
and 512 GB of fast M.2 SSD.

```console
$ ssh xbbi
```

Before starting a multi-platform build, check if Docker is started:

```console
$ docker info
```

Eventually run the test image:

```console
$ docker run hello-world
```

Before running a build for the first time, it is recommended to preload the
docker images.

```console
$ bash ~/Downloads/windows-build-tools-xpack.git/scripts/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                              IMAGE ID            CREATED             SIZE
ilegeul/ubuntu      i386-12.04-xbb-v3.2              fadc6405b606        2 days ago          4.55GB
ilegeul/ubuntu      amd64-12.04-xbb-v3.2             3aba264620ea        2 days ago          4.98GB
hello-world         latest                           bf756fb1ae65        5 months ago        13.3kB
```

It is also recommended to Remove unused Docker space. This is mostly useful
after failed builds, during development, when dangling images may be left
by Docker.

To check the content of a Docker image:

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-12.04-xbb-v3.2
```

To remove unused files:

```console
$ docker system prune --force
```

To build both the 32/64-bits Windows use `--all`.

```console
$ sudo rm -rf ~/Work/windows-build-tools-*
$ bash ~/Downloads/windows-build-tools-xpack.git/scripts/build.sh --all
```

Several minutes later, the output of the build script is a set of 2
files and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l deploy
total 3556
-rw-rw-r-- 1 ilg ilg 1700582 Jul 14 11:26 xpack-windows-build-tools-4.2.1-2-win32-x32.zip
-rw-rw-r-- 1 ilg ilg     113 Jul 14 11:26 xpack-windows-build-tools-4.2.1-2-win32-x32.zip.sha
-rw-rw-r-- 1 ilg ilg 1926825 Jul 14 11:25 xpack-windows-build-tools-4.2.1-2-win32-x64.zip
-rw-rw-r-- 1 ilg ilg     113 Jul 14 11:25 xpack-windows-build-tools-4.2.1-2-win32-x64.zip.sha
```

To copy the files from the build machine to the current development machine, open the `deploy` folder in a terminal and use `scp`:

```console
$ cd ~/Work/windows-build-tools-*/deploy
$ scp * ilg@wks:Downloads/xpack-binaries/wbt
```

## Subsequent runs

### Separate platform specific builds

Instead of `--all`, you can use any combination of:

```
--win32 --win64
```

### clean

To remove most build files, use:

```console
$ bash ~/Downloads/windows-build-tools-xpack.git/scripts/build.sh clean
```

To also remove the repository and the output files, use:

```console
$ bash ~/Downloads/windows-build-tools-xpack.git/scripts/build.sh cleanall
```

For production builds it is recommended to completely remove the build folder.

### --develop

For performance reasons, the actual build folders are internal to each
Docker run, and are not persistent. This gives the best speed, but has
the disadvantage that interrupted builds cannot be resumed.

For development builds, it is possible to define the build folders in
the host file system, and resume an interrupted build.

### --debug

For development builds, it is also possible to create everything
with `-g -O0` and be able to run debug sessions.

### --jobs

By default, the build steps use all available cores. If, for any reason,
parallel builds fail, it is possible to reduce the load.

### Interrupted builds

The Docker scripts run with root privileges. This is generally not
a problem, since at the end of the script the output files are
reassigned to the actual user.

However, for an interrupted build, this step is skipped, and files
in the install folder will remain owned by root. Thus, before removing
the build folder, it might be necessary to run a recursive `chown`.

## Installed folders

After install, the package should create a structure like this (only the
first two depth levels are shown):

```console
xPacks/@xpack-dev-tools/windows-build-tools/4.2.1-2/.content/
├── README.md
├── bin
│   ├── busybox.exe
│   ├── echo.exe
│   ├── make.exe
│   ├── mkdir.exe
│   ├── rm.exe
│   └── sh.exe
└── distro-info
    ├── CHANGELOG.txt
    ├── licenses
    ├── patches
    └── scripts

5 directories, 8 files
```

No other files are installed in any system folders or other locations.

## Uninstall

The binaries are distributed as portable archives; thus they do not need
to run a setup and do not require an uninstall.

## Files cache

The XBB build scripts use a local cache such that files are downloaded only
during the first run, later runs being able to use the cached files.

However, occasionally some servers may not be available, and the builds
may fail.

The workaround is to manually download the files from an alternate
location (like
https://github.com/xpack-dev-tools/files-cache/tree/master/libs),
place them in the XBB cache (`Work/cache`) and restart the build.

## More build details

The build process is split into several scripts. The build starts on the
host, with `build.sh`, which runs `container-build.sh` several times,
once for each target, in one of the two docker containers. Both scripts
include several other helper scripts. The entire process is quite complex,
and an attempt to explain its functionality in a few words would not be
realistic. Thus, the authoritative source of details remains the source code.
