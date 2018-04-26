# GNU MCU Eclipse Windows Build Tools

The **GNU MCU Eclipse Windows Build Tools** subproject (formerly GNU ARM Eclipse Windows Build Tools) is a Windows specific package, customised for the requirements of the Eclipse CDT managed build projects. It includes a recent version of **GNU make** and a recent version of **BusyBox**, which provides a convenient implementation for `sh`/`rm`/`echo`.

## Easy install

The **GNU MCU Eclipse Windows Build Tools** are also available as a binary [xPack](https://www.npmjs.com/package/@gnu-mcu-eclipse/windows-build-tools) and can be conveniently installed with [xpm](https://www.npmjs.com/package/xpm):

```console
$ xpm install @gnu-mcu-eclipse/windows-build-tools --global
```

For more details on how to install the Windows Build Tools, please see [How to install the Windows Build Tools?](https://gnu-mcu-eclipse.github.io/windows-build-tools/install/) page.

## Changes

There are currently no changes from the official MSYS2 distribution or from the official BusyBox distribution.

## Compatibility

The binaries were built using [xPack Build Box (XBB)](https://github.com/xpack/xpack-build-box), a set of build environments based on slightly older systems that should be compatible with most recent systems.

- Windows: all binaries built with mingw-w64 GCC 7.2, running in a CentOS 6 Docker container.

## Build

The scripts used to build this distribution are in:

- `gnu-mcu-eclipse/scripts`

For the prerequisites and more details on the build procedure, please see the [How to build the Windows Build Tools binaries?](https://gnu-mcu-eclipse.github.io/windows-build-tools/build-procedure/) page. 

## Documentation

The package does not include any documentation.

## More info

For more info and support, please see the GNU MCU Eclipse project pages from:

http://gnu-mcu-eclipse.github.io


Thank you for using **GNU MCU Eclipse**,

Liviu Ionescu
