@echo off
@setlocal EnableExtensions DisableDelayedExpansion

set "rev=0.0.3"
set "lastupdt=2021-06-24"
title Cscratch v%rev%

set "startup_path=%~dp0"

set "VsDevCmd_default_cm=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat"
set "VsDevCmd_default_bt=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools\VsDevCmd.bat"
if not defined VsDevCmd (
    if exist "%VsDevCmd_default_cm%" (
        set "VsDevCmd=%VsDevCmd_default_cm%"
    ) else if exist "%VsDevCmd_default_bt%" (
        set "VsDevCmd=%VsDevCmd_default_bt%"
    ) else goto err_FNF
) else if not exist "%VsDevCmd%" goto err_FNF

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

:err_FNF
>&2 echo ERROR: Could not find file VsDevCmd.bat
>&2 echo Please define environment variable VsDevCmd to the location of VsDevCmd.bat on your computer.
>&2 echo Visit https://lxvs.net/cscratch for detailed information.
pause
exit /b 1
