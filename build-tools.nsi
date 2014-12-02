;!/usr/bin/makensis

; This NSIS script creates an installer for GNU ARM Eclipse Build Tools.

; Copyright (C) 2006-2012 Stefan Weil
; Copyright (c) 2014 Liviu Ionescu
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 2 of the License, or
; (at your option) version 3 or any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; NSIS_WIN32_MAKENSIS

!define PRODUCT "Build_Tools"
!define PRODUCT_KEY "GNU_ARM_Eclipse\Build_Tools"
!define URL     "http://gnuarmeclipse.livius.net"

!define UNINST_EXE "$INSTDIR\build-tools-uninstall.exe"
!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_KEY}"

!ifndef BINDIR
!define BINDIR nsis.tmp
!endif
!ifndef SRCDIR
!define SRCDIR source
!endif
!ifndef OUTFILE
!define OUTFILE "build-tools-setup.exe"
!endif

; Optionally install documentation.
!ifndef CONFIG_DOCUMENTATION
!define CONFIG_DOCUMENTATION
!endif

; Use maximum compression.
SetCompressor /SOLID lzma

!include "MUI2.nsh"

; The name of the installer.
Name "GNU ARM Eclipse Build Tools"

; The file to write
OutFile "${OUTFILE}"

; The default installation directory.
!ifdef W64
InstallDir "$PROGRAMFILES64\GNU ARM Eclipse\Build Tools"
!else
InstallDir "$PROGRAMFILES\GNU ARM Eclipse\Build Tools"
!endif

; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
!ifdef W64
InstallDirRegKey HKLM "Software\${PRODUCT_KEY}_64" "Install_Dir"
!else
InstallDirRegKey HKLM "Software\${PRODUCT_KEY}_32" "Install_Dir"
!endif

; Request administrator privileges for Windows Vista.
RequestExecutionLevel admin

;--------------------------------
; Interface Settings.
;!define MUI_HEADERIMAGE "qemu-nsis.bmp"
; !define MUI_SPECIALBITMAP "qemu.bmp"
!define MUI_ICON "${SRCDIR}\build-tools-nsi.ico"
!define MUI_UNICON "${SRCDIR}\build-tools-nsi.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${SRCDIR}\build-tools-nsi.bmp"
; !define MUI_HEADERIMAGE_BITMAP "qemu-install.bmp"
; !define MUI_HEADERIMAGE_UNBITMAP "qemu-uninstall.bmp"
; !define MUI_COMPONENTSPAGE_SMALLDESC
; !define MUI_WELCOMEPAGE_TEXT "Insert text here.$\r$\n$\r$\n$\r$\n$_CLICK"

;--------------------------------
; Pages.

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${SRCDIR}\COPYING"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_LINK "Visit the GNU ARM Eclipse site!"
!define MUI_FINISHPAGE_LINK_LOCATION "${URL}"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
; Languages.

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"

;--------------------------------

; The stuff to install.
Section "${PRODUCT} (required)"

SectionIn RO

; Set output path to the installation directory.
SetOutPath "$INSTDIR"

File "${SRCDIR}\LICENSE.txt"
File "${SRCDIR}\README.txt"
File "${SRCDIR}\echo.exe"
File "${SRCDIR}\make.exe"
File "${SRCDIR}\rm.exe"

!ifdef W64
SetRegView 64
!endif

; Write the installation path into the registry
WriteRegStr HKLM SOFTWARE\${PRODUCT_KEY} "Install_Dir" "$INSTDIR"

; Write the uninstall keys for Windows
WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "Build Tools"
WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" '"${UNINST_EXE}"'
WriteRegDWORD HKLM "${UNINST_KEY}" "NoModify" 1
WriteRegDWORD HKLM "${UNINST_KEY}" "NoRepair" 1
WriteUninstaller "build-tools-uninstall.exe"

SectionEnd

Section "Libraries (DLL)" SectionDll
SetOutPath "$INSTDIR"
File "${SRCDIR}\*.dll"
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
; Remove registry keys
!ifdef W64
SetRegView 64
!endif
DeleteRegKey HKLM "${UNINST_KEY}"
DeleteRegKey HKLM SOFTWARE\${PRODUCT_KEY}

; Remove files and directories used
Delete "$INSTDIR\LICENSE.txt"
Delete "$INSTDIR\README.txt"
Delete "$INSTDIR\echo.exe"
Delete "$INSTDIR\make.exe"
Delete "$INSTDIR\rm.exe"
; Remove all DLLs
Delete "$INSTDIR\*.dll"
; Remove uninstaller
Delete "${UNINST_EXE}"
RMDir "$INSTDIR"
SectionEnd

;--------------------------------

; Descriptions (mouse-over).
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Functions.

Function .onInit
!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd
