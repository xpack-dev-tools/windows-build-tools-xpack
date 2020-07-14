[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/windows-build-tools.svg)](https://www.npmjs.com/package/@xpack-dev-tools/windows-build-tools)
[![npm](https://img.shields.io/npm/dt/@xpack-dev-tools/windows-build-tools.svg)](https://www.npmjs.com/package/@xpack-dev-tools/windows-build-tools/)

# The xPack Windows Build Tools

This open source project is hosted on GitHub as
[`xpack-dev-tools/windows-build-tools-xpack`](https://github.com/xpack-dev-tools/windows-build-tools-xpack).

It is a Windows specific package (not a full multi-platform xPack), customised
for the requirements of the Eclipse Embedded CDT managed build projects;
it includes a recent version of **GNU make** and a recent version of
**BusyBox**, which provides a convenient implementation for `sh`/`rm`/`echo`.

The binaries can be installed automatically as **binary xPacks** or manually as
**portable archives**.

In addition to the package meta data, this project also includes
the build scripts.

## Install

The procedure to install GNU MCU Eclipse Windows Build Tools is
relatively straight forward, expanding a .zip archive on Windows.

A portable method is to use [`xpm`](https://www.npmjs.com/package/xpm):

```console
$ xpm install --global @gnu-mcu-eclipse/windows-build-tools
```

More details are available on the
[How to install the Windows Build Tools](https://xpack.github.io/windows-build-tools/install/)
page.

## User info

This section is intended as a shortcut for those who plan
to use the GNU Arm Embedded GCC binaries. For full details please read the
[xPack Windows Build Tools](https://xpack.github.io/windows-build-tools/) pages.

### Easy install

The easiest way to install GNU Arm Embedded GCC is using the **binary xPack**, available as
[`@xpack-dev-tools/windows-build-tools`](https://www.npmjs.com/package/@xpack-dev-tools/windows-build-tools)
from the [`npmjs.com`](https://www.npmjs.com) registry.

#### Prerequisites

The only requirement is a recent
`xpm`, which is a portable
[Node.js](https://nodejs.org) command line application. To install it,
follow the instructions from the
[xpm](https://xpack.github.io/xpm/install/) page.

#### Install

With the `xpm` tool available, installing
the latest version of the package is quite easy:

```console
$ xpm install --global @xpack-dev-tools/windows-build-tools@latest
```

This command will always install the latest available version,
into the central xPacks repository, which is a platform dependent folder
(check the output of the `xpm` command for the actual folder used on
your platform).

This location is configurable using the environment variable
`XPACKS_REPO_FOLDER`; for more details please check the
[xpm folders](https://xpack.github.io/xpm/folders/) page.

xPacks aware tools, like the **GNU MCU Eclipse plug-ins** automatically
identify binaries installed with
`xpm` and provide a convenient method to manage paths.

#### Uninstall

To remove the installed xPack, the command is similar:

```console
$ xpm uninstall --global @xpack-dev-tools/windows-build-tools
```

(Note: not yet implemented. As a temporary workaround, simply remove the
`xPacks/@xpack-dev-tools/windows-build-tools` folder, or one of the the versioned
subfolders.)

### Manual install

For all platforms, the **xPack GNU Arm Embedded GCC** binaries are released as portable
archives that can be installed in any location.

The archives can be downloaded from the
[GitHub Releases](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/) page.

For more details please read the [Install](https://xpack.github.io/windows-build-tools/install/) page.

## Maintainer info

- [How to build](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/xpack/README-BUILD.md)
- [How to publish](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/xpack/README-PUBLISH.md)

## Support

The quick answer is to use the [xPack forums](https://www.tapatalk.com/groups/xpack/);
please select the correct forum.

For more details please read the [Support](https://xpack.github.io/windows-build-tools/support/) page.

## License

The original content is released under the
[MIT License](https://opensource.org/licenses/MIT), with all rights
reserved to [Liviu Ionescu](https://github.com/ilg-ul).

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
- [individual file counters](https://www.somsubhra.com/github-release-stats/?username=gnu-mcu-eclipse&repository=windows-build-tools) (grouped per release)

Credits to [Shields IO](https://shields.io) and [Somsubhra/github-release-stats](https://github.com/Somsubhra/github-release-stats).
