;!/usr/bin/makensis

; This NSIS script creates an installer for GNU ARM Eclipse Build Tools.

; Copyright (C) 2006-2012 Stefan Weil
; Copyright (c) 2014-2015 Liviu Ionescu
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

!define PRODNAME 	"Build Tools"
!define PRODLCNAME 	"build-tools"
!define PRODUCT 	"GNU ARM Eclipse\${PRODNAME}"
!define URL     	"http://gnuarmeclipse.livius.net"

!define UNINST_EXE 	"$INSTDIR\${PRODLCNAME}-uninstall.exe"
!define UNINST_KEY 	"Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}"

!define INSTALL_LOCATION_KEY "InstallFolder"

; Use maximum compression.
SetCompressor /SOLID lzma

; Non-empty registry key that is created during the installation in either 
; HKCU or HKLM. The default installation mode will automatically be set to 
; the previously selected mode depending on the location of the key.
; Will set $MultiUser.DefaultKeyValue
;;!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "SOFTWARE\${PRODUCT}"
;;!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME "${INSTALL_LOCATION_KEY}"

; Name of the folder in which to install the application, without a path. 
; This folder will be located in Program Files for a per-machine installation 
; and in the local Application Data folder for a per-user installation 
; (if supported).
!define MULTIUSER_INSTALLMODE_INSTDIR "GNU ARM Eclipse\${PRODNAME}"

; Registry key from which to obtain a previously stored installation folder. 
; It will be retrieved from HKCU for per-user and HKLM for per-machine.
; Will set $MultiUser.InstDir and $INSTDIR
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "SOFTWARE\${PRODUCT}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUENAME "${INSTALL_LOCATION_KEY}"

; Multi-user not yet functional
;!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_EXECUTIONLEVEL Admin

!define MULTIUSER_MUI
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!include "${NSIS_FOLDER}/MyMultiUser.nsh"

; The variable $MultiUser.Privileges will contain the current execution level 
; (Admin, Power, User or Guest).
; The variable $MultiUser.InstallMode will contain the current installation mode
; (AllUsers or CurrentUser).

; The installation mode can also be set using the /AllUsers or /CurrentUser 
; command line parameters.

; The name of the installer. Displayed as windows title.
Name "GNU ARM Eclipse ${PRODNAME}"

; The file to write.
OutFile "${OUTFILE}"

;--------------------------------
; Interface Settings.

!define MUI_ICON "${NSIS_FOLDER}\${PRODLCNAME}-nsis.ico"
!define MUI_UNICON "${NSIS_FOLDER}\${PRODLCNAME}-nsis.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSIS_FOLDER}\${PRODLCNAME}-nsis.bmp"

;--------------------------------
; Pages.

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${INSTALL_FOLDER}\COPYING"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_LINK "Visit the GNU ARM Eclipse site!"
!define MUI_FINISHPAGE_LINK_LOCATION "${URL}"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Languages.

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"

;--------------------------------
; The stuff to install.

Section "${PRODNAME} (required)"

SectionIn RO

; Set output path to the installation directory.
SetOutPath "$INSTDIR\bin"
File /r "${INSTALL_FOLDER}\bin\*.exe"

SetOutPath "$INSTDIR\license"
File /r "${INSTALL_FOLDER}\license\*"

SetOutPath "$INSTDIR"
File "${INSTALL_FOLDER}\INFO.txt"

SetOutPath "$INSTDIR\gnuarmeclipse"
File /r "${INSTALL_FOLDER}\gnuarmeclipse\*"

!ifdef W64
SetRegView 64
!endif

${if} $MultiUser.InstallMode == "AllUsers"

  ; Write the installation path into the registry
  WriteRegStr HKLM "SOFTWARE\${PRODUCT}" "${INSTALL_LOCATION_KEY}" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "SOFTWARE\${UNINST_KEY}" "DisplayName" "GNU ARM Eclipse ${PRODNAME}"
  WriteRegStr HKLM "SOFTWARE\${UNINST_KEY}" "UninstallString" '"${UNINST_EXE}"'
  WriteRegDWORD HKLM "SOFTWARE\${UNINST_KEY}" "NoModify" 1
  WriteRegDWORD HKLM "SOFTWARE\${UNINST_KEY}" "NoRepair" 1

${else}

  ; Write the installation path into the registry
  WriteRegStr HKCU "Software\${PRODUCT}" "${INSTALL_LOCATION_KEY}" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKCU "Software\${UNINST_KEY}" "DisplayName" "GNU ARM Eclipse ${PRODNAME}"
  WriteRegStr HKCU "Software\${UNINST_KEY}" "UninstallString" '"${UNINST_EXE}"'
  WriteRegDWORD HKCU "Software\${UNINST_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "Software\${UNINST_KEY}" "NoRepair" 1

${endif}

WriteUninstaller "${PRODLCNAME}-uninstall.exe"

SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts" SectionMenu
CreateDirectory "$SMPROGRAMS\${PRODUCT}"
CreateShortCut "$SMPROGRAMS\${PRODUCT}\Uninstall.lnk" "${UNINST_EXE}" "" "${UNINST_EXE}" 0
SectionEnd

;--------------------------------
; Uninstaller

Section "Uninstall"

; Remove registry keys
!ifdef W64
SetRegView 64
!endif

${if} $MultiUser.InstallMode == "AllUsers"

  DeleteRegKey HKLM "SOFTWARE\${UNINST_KEY}"
  DeleteRegKey HKLM "SOFTWARE\${PRODUCT}"

${else}

  DeleteRegKey HKCU "Software\${UNINST_KEY}"
  DeleteRegKey HKCU "Software\${PRODUCT}"

${endif}

; Remove shortcuts, if any
Delete "$SMPROGRAMS\${PRODUCT}\Uninstall.lnk"
RMDir "$SMPROGRAMS\${PRODUCT}"

; Remove uninstaller
Delete "${UNINST_EXE}"

; Remove files and directories used
SetOutPath "$INSTDIR"

RMDir /r "$INSTDIR\*"
RMDir /r "$INSTDIR"

SectionEnd

;--------------------------------
; Descriptions (for mouse-over).

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN

!insertmacro MUI_DESCRIPTION_TEXT ${SectionMenu}	"Menu entries."

!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Functions.

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
  !insertmacro MULTIUSER_INIT
FunctionEnd

Function un.onInit
  !insertmacro MULTIUSER_UNINIT
FunctionEnd

;--------------------------------

