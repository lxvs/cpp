@echo off
@setlocal EnableExtensions DisableDelayedExpansion

set "rev=0.0.2"
set "lastupdt=2021-06-23"
title Cscratch v%rev%

set "VsDevCmd_default=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat"
if not defined VsDevCmd set "VsDevCmd=%VsDevCmd_default%"
set "startup_path=%~dp0"

if not exist "%VsDevCmd%" (
    >&2 echo ERROR: Could not find file VsDevCmd.bat
    >&2 echo Please define environment variable VsDevCmd to the location of VsDevCmd.bat on your computer.
    >&2 echo For example, set "VsDevCmd=%VsDevCmd_default%"
    exit /b 1
)

set "batchname=%~nx0"
set "batchfolder=%~dp0"
if "%batchfolder:~-1%" == "\" set "batchfolder=%batchfolder:~0,-1%"
fltmc 1>nul 2>&1 || goto GetAdmin

@call:logo

if defined startup_path pushd "%startup_path%"
cmd /k call "%VsDevCmd%"
exit /b

:GetAdmin
@echo;
@echo     Requesting Administrative Privileges...
@echo     Press YES in UAC Prompt to Continue
@echo;
>"%TEMP%\uac.vbs" (
echo Set UAC = CreateObject^("Shell.Application"^)
echo args = "ELEV "
echo For Each strArg in WScript.Arguments
echo args = args ^& strArg ^& " "
echo Next
echo UAC.ShellExecute "%batchname%", args, "%batchfolder%", "runas", 1
)
cscript //nologo "%TEMP%\uac.vbs"
del /f "%TEMP%\uac.vbs"
exit /b

:logo
echo;
echo     Cscratch v%rev%
echo     https://lxvs.net/cscratch
echo     Last updated: %lastupdt%
echo;
exit /b
