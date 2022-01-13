---
title:  xPack Windows Build Tools v{{ RELEASE_VERSION }} released

TODO: select one summary

summary: "Version **{{ RELEASE_VERSION }}** is a maintenance release of the **xPack Windows Build Tools** package; it updates to the latest upstream Busybox."

Or (TODO: edit!):

summary: "Version **{{ RELEASE_VERSION }}** is a new release of the **xPack Windows Build Tools** package, following the make release."

version: {{ RELEASE_VERSION }}
npm_subversion: 1
download_url: https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/tag/v{{ RELEASE_VERSION }}/

date:   {{ RELEASE_DATE }}

categories:
  - releases
  - windows-build-tools

tags:
  - releases
  - windows-build-tools
  - build
  - make
  - rm
  - mkdir
  - busybox

---

[The xPack Windows Build Tools](https://xpack.github.io/windows-build-tools/)
is a standalone Windows binary distribution of
**GNU make** and a few of other tools required by the Eclipse Embedded CDT
(formerly GNU MCU/ARM Eclipse) project, but the binaries can also be used in
generic build environments.

There are separate binaries for **Windows** (Intel 32/64-bit).

## Download

The binary files are available from GitHub [Releases]({% raw %}{{ page.download_url }}{% endraw %}).

## Prerequisites

- Intel Windows 64-bit: Windows 7 with the Universal C Runtime
  ([UCRT](https://support.microsoft.com/en-us/topic/update-for-universal-c-runtime-in-windows-c0514201-7fe6-95a3-b0a5-287930f3560c)),
  Windows 8, Windows 10

## Install

The full details of installing the **xPack Windows Build Tools**
are presented in the separate
[Install]({% raw %}{{ site.baseurl }}{% endraw %}/windows-build-tools/install/) page.

### Easy install

The easiest way to install Windows Build Tools is with
[`xpm`]({% raw %}{{ site.baseurl }}{% endraw %}/xpm/)
by using the **binary xPack**, available as
[`@xpack-dev-tools/windows-build-tools`](https://www.npmjs.com/package/@xpack-dev-tools/windows-build-tools)
from the [`npmjs.com`](https://www.npmjs.com) registry.

With the `xpm` tool available, installing
the latest version of the package and adding it as
a dependency for a project is quite easy:

```sh
cd my-project
xpm init # Only at first use.

xpm install @xpack-dev-tools/windows-build-tools@latest

ls -l xpacks/.bin
```

To install this specific version, use:

```sh
xpm install @xpack-dev-tools/windows-build-tools@{% raw %}{{ page.version }}.{{ page.npm_subversion }}{% endraw %}
```

For xPacks aware tools, like the **Eclipse Embedded C/C++ plug-ins**,
it is also possible to install Windows Build Tools globally, in the user home folder.

```sh
xpm install --global @xpack-dev-tools/windows-build-tools@latest
```

Eclipse will automatically
identify binaries installed with
`xpm` and provide a convenient method to manage paths.

### Uninstall

To remove the links from the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/windows-build-tools
```

To completely remove the package from the global store:

```sh
xpm uninstall --global @xpack-dev-tools/windows-build-tools
```

## Compliance

The xPack Windows Build Tools uses programs from other projects.

The current version is based on:

- [GNU make](http://ftpmirror.gnu.org/make/) version 4.2.1
- [Busybox](https://github.com/rmyorston/busybox-w32), the f902184fa
commit from Dec 12, 2020.

## Changes

There are no functional changes from original projects.

## Bug fixes

- none

## Enhancements

- none

## Known problems

- none

## Shared libraries

The dependencies are either linked as static libraries or the
DLLs are included, so the binaries should run on any Windows system.

## Documentation

- none

## Build

The binaries were built using the
[xPack Build Box (XBB)](https://xpack.github.io/xbb/), a set
of build environments based on slightly older distributions, that should be
compatible with most recent systems.

The scripts used to build this distribution are in:

- `distro-info/scripts`

For the prerequisites and more details on the build procedure, please see the
[How to build](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/xpack/README-BUILD.md) page.

## CI tests

Before publishing, a set of simple tests were performed on an exhaustive
set of platforms. The results are available from:

- [GitHub Actions](https://github.com/xpack-dev-tools/windows-build-tools-xpack/actions/)

## Tests

The binaries were testes on Windows 10 Pro 32/64-bit.

Install the package with xpm.

The simple test, consists in starting the binary.

```sh
.../xpack-windows-build-tools-{{ RELEASE_VERSION }}/bin/make --version
```

A more elaborate test would be to run an Eclipse build.

## Checksums

The SHA-256 hashes for the files are:
