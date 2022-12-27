[![GitHub package.json version](https://img.shields.io/github/package-json/v/xpack-dev-tools/windows-build-tools-xpack)](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/xpack/package.json)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/xpack-dev-tools/windows-build-tools-xpack)](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/)
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/windows-build-tools.svg?color=blue)](https://www.npmjs.com/package/@xpack-dev-tools/windows-build-tools/)
[![license](https://img.shields.io/github/license/xpack-dev-tools/windows-build-tools-xpack)](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/xpack/LICENSE)

# The xPack Windows Build Tools

A standalone Windows specific package (not a full multi-platform xPack),
customised for the requirements of the Eclipse Embedded CDT managed build
projects; it includes a recent version of **GNU make** and a recent version of
**BusyBox**, which provides a convenient implementation for `sh`/`rm`/`echo`.

In addition to the package meta data, this project also includes
the build scripts.

## Overview

This open source project is hosted on GitHub as
[`xpack-dev-tools/windows-build-tools-xpack`](https://github.com/xpack-dev-tools/windows-build-tools-xpack)
and provides the platform specific binaries for the
[xPack Windows Build Tools](https://xpack.github.io/windows-build-tools/).

The binaries can be installed automatically as **binary xPacks** or manually as
**portable archives**.

## Release schedule

This distribution generally follows the official make, but there
is no commitment of a quick release cycle.

## User info

This section is intended as a shortcut for those who plan
to use the xPack Windows Build Tools binaries. For full details please read the
[xPack Windows Build Tools](https://xpack.github.io/windows-build-tools/) pages.

### Easy install

The easiest way to install Windows Build Tools is using the **binary xPack**, available as
[`@xpack-dev-tools/windows-build-tools`](https://www.npmjs.com/package/@xpack-dev-tools/windows-build-tools)
from the [`npmjs.com`](https://www.npmjs.com) registry.

#### Prerequisites

A recent [xpm](https://xpack.github.io/xpm/),
which is a portable [Node.js](https://nodejs.org/) command line application.

It is recommended to update to the latest version with:

```sh
npm install --location=global xpm@latest
```

For details please follow the instructions in the
[xPack install](https://xpack.github.io/install/) page.

#### Install

With the `xpm` tool available, installing
the latest version of the package and adding it as
a dependency for a project is quite easy:

```sh
cd my-project
xpm init # Only at first use.

xpm install @xpack-dev-tools/windows-build-tools@latest

ls -l xpacks/.bin
```

This command will:

- install the latest available version,
into the central xPacks store, if not already there
- add symbolic links to the central store
(or `.cmd` forwarders on Windows) into
the local `xpacks/.bin` folder.

The central xPacks store is a platform dependent
folder; check the output of the `xpm` command for the actual
folder used on your platform).
This location is configurable via the environment variable
`XPACKS_STORE_FOLDER`; for more details please check the
[xpm folders](https://xpack.github.io/xpm/folders/) page.

For xPacks aware tools, like the **Eclipse Embedded C/C++ plug-ins**,
it is also possible to install Windows Build Tools globally, in the user home folder:

```sh
xpm install --global @xpack-dev-tools/windows-build-tools@latest
```

Eclipse will automatically
identify binaries installed with
`xpm` and provide a convenient method to manage paths.

After install, the package should create a structure like this (macOS files;
only the first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/.local/xPacks/@xpack-dev-tools/windows-build-tools/4.4.0-1/.content/
/Users/ilg/.local/xPacks/@xpack-dev-tools/windows-build-tools/4.4.0-1/.content/
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

#### Uninstall

To remove the links created by xpm in the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/windows-build-tools
```

To completely remove the package from the global store:

```sh
xpm uninstall --global @xpack-dev-tools/windows-build-tools
```

### Manual install

For all platforms, the **xPack Windows Build Tools**
binaries are released as portable
archives that can be installed in any location.

The archives can be downloaded from the
GitHub [Releases](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/)
page.

For more details please read the
[Install](https://xpack.github.io/windows-build-tools/install/) page.

### Versioning

The version strings used by the GNU make project are three number strings
like `4.4.0`; to this string the xPack distribution adds a four number,
but since semver allows only three numbers, all additional ones can
be added only as pre-release strings, separated by a dash,
like `4.4.0-1`. When published as a npm package, the version gets
a fifth number, like `4.4.0-1.1`.

Since adherence of third party packages to semver is not guaranteed,
it is recommended to use semver expressions like `^4.4.0` and `~4.4.0`
with caution, and prefer exact matches, like `4.4.0-1.1`.

## Maintainer info

For maintainer info, please see the
[README-MAINTAINER](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/xpack/README-MAINTAINER.md)

## Support

The quick advice for getting support is to use the GitHub
[Discussions](https://github.com/xpack-dev-tools/windows-build-tools-xpack/discussions/).

For more details please read the
[Support](https://xpack.github.io/windows-build-tools/support/) page.

## License

The original content is released under the
[MIT License](https://opensource.org/licenses/MIT), with all rights
reserved to [Liviu Ionescu](https://github.com/ilg-ul/).

The binary distributions include several open-source components; the
corresponding licenses are available in the installed
`distro-info/licenses` folder.

## Download analytics

- GitHub [gnu-mcu-eclipse/windows-build-tools.git](https://github.com/gnu-mcu-eclipse/windows-build-tools/)
  - latest release
[![Github All Releases](https://img.shields.io/github/downloads/gnu-mcu-eclipse/windows-build-tools/latest/total.svg)](https://github.com/gnu-mcu-eclipse/windows-build-tools/releases/)
  - all releases [![Github All Releases](https://img.shields.io/github/downloads/gnu-mcu-eclipse/windows-build-tools/total.svg)](https://github.com/gnu-mcu-eclipse/windows-build-tools/releases/)
- xPack [@gnu-mcu-eclipse/windows-build-tools](https://github.com/gnu-mcu-eclipse/windows-build-tools-xpack/)
  - latest release, per month
[![npm (scoped)](https://img.shields.io/npm/v/@gnu-mcu-eclipse/windows-build-tools.svg)](https://www.npmjs.com/package/@gnu-mcu-eclipse/windows-build-tools/)
[![npm](https://img.shields.io/npm/dm/@gnu-mcu-eclipse/windows-build-tools.svg)](https://www.npmjs.com/package/@gnu-mcu-eclipse/windows-build-tools/)
  - all releases [![npm](https://img.shields.io/npm/dt/@gnu-mcu-eclipse/windows-build-tools.svg)](https://www.npmjs.com/package/@gnu-mcu-eclipse/windows-build-tools/)
- [individual file counters](https://somsubhra.github.io/github-release-stats/?username=gnu-mcu-eclipse&repository=windows-build-tools) (grouped per release)

Credits to [Shields IO](https://shields.io) and [Somsubhra/github-release-stats](https://github.com/Somsubhra/github-release-stats).
