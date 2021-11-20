# How to build the xPack Windows Build Tools binaries

## Introduction

This project also includes the scripts and additional files required to
build and publish the
[xPack Windows Build Tools](https://github.com/xpack-dev-tools/windows-build-tools-xpack) binaries.

The build scripts use the
[xPack Build Box (XBB)](https://xpack.github.io/xbb/),
a set of elaborate build environments based on recent GCC versions
(Docker containers
for GNU/Linux and Windows or a custom folder for MacOS).

There are two types of builds:

- **local/native builds**, which use the tools available on the
  host machine; generally the binaries do not run on a different system
  distribution/version; intended mostly for development purposes;
- **distribution builds**, which create the archives distributed as
  binaries; expected to run on most modern systems.

This page documents the distribution builds.

For native builds, see the `build-native.sh` script.

## Repositories

- <https://github.com/xpack-dev-tools/windows-build-tools-xpack.git> -
  the URL of the xPack build scripts repository
- <https://github.com/xpack-dev-tools/build-helper> - the URL of the
  xPack build helper, used as the `scripts/helper` submodule.
- <http://sourceforge.net/projects/msys2/files/REPOS/MSYS2/Sources/>
- <https://github.com/rmyorston/busybox-w32.git>

The build scripts use the first repo; to merge
changes from upstream it is necessary to add a remote named
`upstream`, and merge the `upstream/master` into the local `master`.

### Branches

- `xpack` - the updated content, used during builds
- `xpack-develop` - the updated content, used during development
- `master` - no content

## Download the build scripts

The build scripts are available in the `scripts` folder of the
[`xpack-dev-tools/windows-build-tools-xpack`](https://github.com/xpack-dev-tools/windows-build-tools-xpack)
Git repo.

To download them, issue the following commands:

```sh
rm -rf ~/Downloads/windows-build-tools-xpack.git; \
git clone https://github.com/xpack-dev-tools/windows-build-tools-xpack.git \
  ~/Downloads/windows-build-tools-xpack.git; \
git -C ~/Downloads/windows-build-tools-xpack.git submodule update --init --recursive 
```

> Note: the repository uses submodules; for a successful build it is
> mandatory to recurse the submodules.

For development purposes, clone the `xpack-develop`
branch:

```sh
rm -rf ~/Downloads/windows-build-tools-xpack.git; \
git clone \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/windows-build-tools-xpack.git \
  ~/Downloads/windows-build-tools-xpack.git; \
git -C ~/Downloads/windows-build-tools-xpack.git submodule update --init --recursive
```

## The `Work` folder

The scripts create a temporary build `Work/windows-build-tools-${version}` folder in
the user home. Although not recommended, if for any reasons you need to
change the location of the `Work` folder,
you can redefine `WORK_FOLDER_PATH` variable before invoking the script.

## Spaces in folder names

Due to the limitations of `make`, builds started in folders with
spaces in names are known to fail.

If on your system the work folder is in such a location, redefine it in a
folder without spaces and set the `WORK_FOLDER_PATH` variable before invoking
the script.

## Customizations

There are many other settings that can be redefined via
environment variables. If necessary,
place them in a file and pass it via `--env-file`. This file is
either passed to Docker or sourced to shell. The Docker syntax
**is not** identical to shell, so some files may
not be accepted by bash.

## Versioning

The version string is an extension to semver, the format looks like `4.3.0-1`.
It includes the three digits with the original **GNU make** version and a fourth
digit with the xPack release number.

When publishing on the **npmjs.com** server, a fifth digit is appended.

## Changes

Compared to the original Windows Build Tools distribution, there should be no
functional changes.

The actual changes for each version are documented in the
release web pages.

## How to build local/native binaries

### README-DEVELOP.md

The details on how to prepare the development environment for Windows Build Tools are in the
[`README-DEVELOP.md`](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/xpack/README-DEVELOP.md)
file.

## How to build distributions

## Build

The builds currently run on a dedicated machines (Intel GNU/Linux).

### Build the Windows binaries

The current platform for Windows production builds is a
Debian 10, running on an Intel NUC8i7BEH mini PC with 32 GB of RAM
and 512 GB of fast M.2 SSD. The machine name is `xbbi`.

```sh
caffeinate ssh xbbi
```

Before starting a build, check if Docker is started:

```sh
docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```sh
bash ~/Downloads/windows-build-tools-xpack.git/scripts/helper/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                    IMAGE ID            CREATED             SIZE
ilegeul/ubuntu      i386-12.04-xbb-v3.3    35fb0236572c        23 hours ago        5GB
ilegeul/ubuntu      amd64-12.04-xbb-v3.3   1c4ba2e7e87e        29 hours ago        5.43GB
```

It is also recommended to Remove unused Docker space. This is mostly useful
after failed builds, during development, when dangling images may be left
by Docker.

To check the content of a Docker image:

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-12.04-xbb-v3.3
```

To remove unused files:

```sh
docker system prune --force
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```sh
screen -S windows-build-tools

sudo rm -rf ~/Work/windows-build-tools-*
bash ~/Downloads/windows-build-tools-xpack.git/scripts/helper/build.sh --develop --all
```

or, for development builds:

```sh
sudo rm -rf ~/Work/windows-build-tools-*
bash ~/Downloads/windows-build-tools-xpack.git/scripts/helper/build.sh --develop --without-pdf --without-html --disable-tests --win64 --win32
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r windows-build-tools`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

Several minutes later, the output of the build script is a set of 2
archives and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l ~/Work/windows-build-tools-*/deploy
total 3556
-rw-rw-r-- 1 ilg ilg 1700582 Jul 14 11:26 xpack-windows-build-tools-4.3.0-1-win32-x32.zip
-rw-rw-r-- 1 ilg ilg     113 Jul 14 11:26 xpack-windows-build-tools-4.3.0-1-win32-x32.zip.sha
-rw-rw-r-- 1 ilg ilg 1926825 Jul 14 11:25 xpack-windows-build-tools-4.3.0-1-win32-x64.zip
-rw-rw-r-- 1 ilg ilg     113 Jul 14 11:25 xpack-windows-build-tools-4.3.0-1-win32-x64.zip.sha
```

## Subsequent runs

### Separate platform specific builds

Instead of `--all`, you can use any combination of:

```console
--win32 --win64
```

### `clean`

To remove most build temporary files, use:

```sh
bash ~/Downloads/windows-build-tools-xpack.git/scripts/helper/build.sh --all clean
```

To also remove the library build temporary files, use:

```sh
bash ~/Downloads/windows-build-tools-xpack.git/scripts/helper/build.sh --all cleanlibs
```

To remove all temporary files, use:

```sh
bash ~/Downloads/windows-build-tools-xpack.git/scripts/helper/build.sh --all cleanall
```

Instead of `--all`, any combination of `--win32 --win64`
will remove the more specific folders.

For production builds it is recommended to **completely remove the build folder**:

```sh
rm -rf ~/Work/windows-build-tools-*
```

### `--develop`

For performance reasons, the actual build folders are internal to each
Docker run, and are not persistent. This gives the best speed, but has
the disadvantage that interrupted builds cannot be resumed.

For development builds, it is possible to define the build folders in
the host file system, and resume an interrupted build.

In addition, the builds are more verbose.

### `--debug`

For development builds, it is also possible to create everything with
`-g -O0` and be able to run debug sessions.

### --jobs

By default, the build steps use all available cores. If, for any reason,
parallel builds fail, it is possible to reduce the load.

### Interrupted builds

The Docker scripts may run with root privileges. This is generally not a
problem, since at the end of the script the output files are reassigned
to the actual user.

However, for an interrupted build, this step is skipped, and files in
the install folder will remain owned by root. Thus, before removing
the build folder, it might be necessary to run a recursive `chown`.

## Testing

A simple test is performed by the script at the end, by launching the
executable to check if all shared/dynamic libraries are correctly used.

For a true test you need to build some Eclipse projects.

## Installed folders

After install, the package should create a structure like this (only the
first two depth levels are shown):

```console
xPacks/@xpack-dev-tools/windows-build-tools/4.3.0-1/.content/
├── README.md
├── bin
│   ├── busybox.exe
│   ├── cp.exe
│   ├── echo.exe
│   ├── make.exe
│   ├── mkdir.exe
│   ├── rm.exe
│   └── sh.exe
├── distro-info
│   ├── CHANGELOG.md
│   ├── licenses
│   ├── patches
│   └── scripts
├── include
│   └── gnumake.h
└── share
    ├── info
    └── man

9 directories, 10 files
```

No other files are installed in any system folders or other locations.

## Uninstall

The binaries are distributed as portable archives; thus they do not need
to run a setup and do not require an uninstall; simply removing the
folder is enough.

## Files cache

The XBB build scripts use a local cache such that files are downloaded only
during the first run, later runs being able to use the cached files.

However, occasionally some servers may not be available, and the builds
may fail.

The workaround is to manually download the files from an alternate
location (like
<https://github.com/xpack-dev-tools/files-cache/tree/master/libs>),
place them in the XBB cache (`Work/cache`) and restart the build.

## More build details

The build process is split into several scripts. The build starts on
the host, with `build.sh`, which runs `container-build.sh` several
times, once for each target, in one of the two docker containers.
Both scripts include several other helper scripts. The entire process
is quite complex, and an attempt to explain its functionality in a few
words would not be realistic. Thus, the authoritative source of details
remains the source code.
