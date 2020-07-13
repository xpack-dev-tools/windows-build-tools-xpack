# The Windows Build Tools

The **GNU MCU Eclipse Windows Build Tools** subproject (formerly GNU ARM
Eclipse Windows Build Tools) is a Windows specific package, customised
for the requirements of the Eclipse CDT managed build projects. It
includes a recent version of **GNU make** and a recent version of
**BusyBox**, which provides a convenient implementation for `sh`/`rm`/`echo`.


## Prerequisites

The prerequisites are common to all binary builds. Please follow the
instructions in the separate
[Prerequisites for building binaries](https://gnu-mcu-eclipse.github.io/developer/build-binaries-prerequisites-xbb/)
page and return when ready.

## Download the build scripts repo

The build script is available from GitHub and can be
[viewed online](https://github.com/gnu-mcu-eclipse/windows-build-tools/blob/master/scripts/build.sh).

To download it, clone the
[gnu-mcu-eclipse/windows-build-tools](https://github.com/gnu-mcu-eclipse/windows-build-tools)
Git repo, including submodules.

```console
$ rm -rf ~/Downloads/windows-build-tools.git
$ git clone --recurse-submodules https://github.com/gnu-mcu-eclipse/windows-build-tools.git \
  ~/Downloads/windows-build-tools.git
```

## Check the script

The script creates a temporary build `Work/build-tools` folder in the user
home. Although not recommended, if for any reasons you need to change this,
you can redefine `WORK_FOLDER_PATH` variable before invoking the script.

## Preload the Docker images

Docker does not require to explicitly download new images, but does this
automatically at first use.

However, since the images used for this build are relatively large, it
is recommended to load them explicitly before starting the build:

```console
$ bash ~/Downloads/windows-build-tools.git/scripts/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ilegeul/centos      6-xbb-v2.1          3644716694e8        2 weeks ago         2.99GB
ilegeul/centos32    6-xbb-v2.1          921d03805e50        2 weeks ago         2.91GB
hello-world         latest              f2a91732366c        2 months ago        1.85kB
```

## Prepare release

To prepare a new release, first determine the version (like `2.10`) and
update the `scripts/VERSION` file.

## Update CHANGELOG.txt

Check `windows-build-tools.git/CHANGELOG.txt` and add the new release.

## Build

The current platform for Windows production builds is an Ubuntu 18 LTS
VirtualBox image running on a macMini with 16 GB of RAM and a fast SSD.

Before starting a multi-platform build, check if Docker is started:

```console
$ docker info
```

To build both the 32/64-bits Windows use `--all`.

```console
$ bash ~/Downloads/windows-build-tools.git/scripts/build.sh --all
```

On macOS, to prevent entering sleep, use:

```console
$ caffeinate bash ~/Downloads/windows-build-tools.git/scripts/build.sh --all
```

Several minutes later, the output of the build script is a set of 2
files and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l deploy
total 7384
-rw-rw-rw-@ 1 ilg  staff  1773647 Apr  8 12:07 gnu-mcu-eclipse-windows-build-tools-2.12-20190408-0844-win32.zip
-rw-rw-rw-@ 1 ilg  staff      131 Apr  8 12:07 gnu-mcu-eclipse-windows-build-tools-2.12-20190408-0844-win32.zip.sha
-rw-rw-rw-@ 1 ilg  staff  1992179 Apr  8 11:56 gnu-mcu-eclipse-windows-build-tools-2.12-20190408-0844-win64.zip
-rw-rw-rw-@ 1 ilg  staff      131 Apr  8 11:56 gnu-mcu-eclipse-windows-build-tools-2.12-20190408-0844-win64.zip.sha
```

To copy the files from the build machine to the current development machine, open the `deploy` folder in a terminal and use `scp`:

```console
$ scp * ilg@ilg-mbp.local:Downloads/gme-binaries/wbt
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
$ bash ~/Downloads/windows-build-tools.git/scripts/build.sh clean
```

To also remove the repository and the output files, use:

```console
$ bash ~/Downloads/windows-build-tools.git/scripts/build.sh cleanall
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

### Interrupted builds

The Docker scripts run with root privileges. This is generally not
a problem, since at the end of the script the output files are
reassigned to the actual user.

However, for an interrupted build, this step is skipped, and files
in the install folder will remain owned by root. Thus, before removing
the build folder, it might be necessary to run a recursive `chown`.

## Install

The procedure to install GNU MCU Eclipse Windows Build Tools is
relatively straight forward, expanding a .zip archive on Windows.

A portable method is to use [`xpm`](https://www.npmjs.com/package/xpm):

```console
$ xpm install --global @gnu-mcu-eclipse/windows-build-tools
```

More details are available on the
[How to install the Windows Build Tools?](https://gnu-mcu-eclipse.github.io/windows-build-tools/install/)
page.

After install, the package should create a structure like this (only the
first two depth levels are shown):

```console
xPacks/@gnu-mcu-eclipse/build-tools/2.11/.content/
├── README.md
├── bin
│   ├── busybox.exe
│   ├── echo.exe
│   ├── make.exe
│   ├── mkdir.exe
│   ├── rm.exe
│   └── sh.exe
└── gnu-mcu-eclipse
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

## More build details

The build process is split into several scripts. The build starts on the
host, with `build.sh`, which runs `container-build.sh` several times,
once for each target, in one of the two docker containers. Both scripts
include several other helper scripts. The entire process is quite complex,
and an attempt to explain its functionality in a few words would not be
realistic. Thus, the authoritative source of details remains the source code.

## Download analytics

* GitHub [gnu-mcu-eclipse/windows-build-tools.git](https://github.com/gnu-mcu-eclipse/windows-build-tools/)
  * latest release
[![Github All Releases](https://img.shields.io/github/downloads/gnu-mcu-eclipse/windows-build-tools/latest/total.svg)](https://github.com/gnu-mcu-eclipse/windows-build-tools/releases/)
  * all releases [![Github All Releases](https://img.shields.io/github/downloads/gnu-mcu-eclipse/windows-build-tools/total.svg)](https://github.com/gnu-mcu-eclipse/windows-build-tools/releases/)
* xPack [@gnu-mcu-eclipse/windows-build-tools](https://github.com/gnu-mcu-eclipse/windows-build-tools-xpack/)
  * latest release, per month
[![npm (scoped)](https://img.shields.io/npm/v/@gnu-mcu-eclipse/windows-build-tools.svg)](https://www.npmjs.com/package/@gnu-mcu-eclipse/windows-build-tools/)
[![npm](https://img.shields.io/npm/dm/@gnu-mcu-eclipse/windows-build-tools.svg)](https://www.npmjs.com/package/@gnu-mcu-eclipse/windows-build-tools/)
  * all releases [![npm](https://img.shields.io/npm/dt/@gnu-mcu-eclipse/windows-build-tools.svg)](https://www.npmjs.com/package/@gnu-mcu-eclipse/windows-build-tools/)
* [individual file counters](https://www.somsubhra.com/github-release-stats/?username=gnu-mcu-eclipse&repository=windows-build-tools) (grouped per release)
 
Credits to [Shields IO](https://shields.io) and [Somsubhra/github-release-stats](https://github.com/Somsubhra/github-release-stats).
