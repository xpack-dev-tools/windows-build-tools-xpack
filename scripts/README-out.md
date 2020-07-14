# xPack Windows Build Tools

The **xPack Windows Build Tools** subproject (formerly GNU MCU/ARM Eclipse
Windows Build Tools) is a Windows specific package, customised for the
requirements of the Eclipse CDT managed build projects. It includes a
recent version of **GNU make** and a recent version of **BusyBox**,
which provides a convenient implementation for `sh`/`rm`/`echo`.

## Easy install

The **xPack Windows Build Tools** are also available as a binary
[xPack](https://www.npmjs.com/package/@xpack-dev-tools/windows-build-tools)
and can be conveniently installed with [xpm](https://www.npmjs.com/package/xpm):

```console
$ xpm install --global @xpack-dev-tools/windows-build-tools
```

For more details please see the
[How to install the Windows Build Tools](https://xpack.github.io/windows-build-tools/install/) page.

## Changes

There are currently no changes from the official MSYS2 distribution
the official BusyBox distribution.

## Compatibility

The binaries were built using
[xPack Build Box (XBB)](https://github.com/xpack/xpack-build-box), a
set of build environments based on slightly older systems that should
be compatible with most recent systems.

- Windows: all binaries were built with mingw-w64 GCC 9.3, running in a
  Ubuntu 12.04 LTS Docker container

## Build

The scripts used to build this distribution are in:

- `distro-info/scripts`

For the prerequisites and more details on the build procedure, please see the
[How to build the Windows Build Tools binaries](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/xpack/README-BUILD.md) page.

## Documentation

The package does not include any documentation.

## More info

For more info and support, please see the xPack project pages from:

http://xpack.github.io/windows-build-tools/

Thank you for using open source software,

Liviu Ionescu
