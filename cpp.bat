@REM This script is used in repo github.com/lxvs/cpp
@REM Author:        lxvs <jn.apsd+batch@gmail.com>
@REM Created:       2021-04-01
@REM Last updated:  2021-04-02
@REM
@REM Usage: cpp <operation> [<argument> ...]
@REM
@REM    Operation: init, cl
@REM
@REM cpp init <chapter> <number-of-exercises>
@REM 
@REM    init a new chapter (e.g. ch.6, having 18 exercises) by:
@REM        creating the folder ch-6
@REM        copying template.c to ch-6\6-1.c ch-6\6-2.c ... ch-6\6-18.c
@REM
@REM    errorlevel value returned
@REM    0           exit expectedly
@REM    101         chapter is not provided
@REM    102         number of exercises is not provided    
@REM    103/104     chapter number is too low/ too high
@REM    105/106     exercise number is too low/ too high
@REM    107         file INIT_TEMPLATE does not exist
@REM
@REM cpp cl <chapter> <exercise> [run]
@REM
@REM    Build ch-<chapter>\<chapter>-<exercise>.c
@REM    If "run" is specified, run it if built successfully
@REM
@REM    errorlevel value returned
@REM    0           exit expectedly
@REM    201         chapter is not provided
@REM    202         number of exercises is not provided    
@REM    203/204     chapter number is too low/ too high
@REM    205/206     exercise number is too low/ too high
@REM    207         the specified c file does not exist

@if "%~1" == "" (
    echo Error: no operation provided
    echo Read this script in editor for detailed usage
    exit /b 1
)

@setlocal

@set /a "MIN_CH=1"
@set /a "MAX_CH=17"
@set /a "MIN_EX=1"
@set /a "MAX_EX=99"

@set "INIT_TEMPLATE=template.c"

@set op=
@if /i "%~1" == "init" set "op=%~1"
@if /i "%~1" == "cl" set "op=%~1"

@if "%op%" == "" (
    echo Error: invalid operation: %~1
    exit /b 1
)

@set allArgs=
@shift
:loop_gather_arg
@if "%~1" == "" goto post_loop_gather_arg
@set allArgs=%allArgs% %1
@shift
@goto loop_gather_arg

:post_loop_gather_arg
@call:%op% %allArgs%
@if %errorlevel% NEQ 0 echo cpp-%op%: warning: exit with error %errorlevel%
@exit /b

:Init
@REM init <chapter> <number-of-exercises>

    @if "%~1" == "" exit /b 101
    @if "%~2" == "" exit /b 102
    
    @set /a "ch=%~1"
    @if %ch% LSS %MIN_CH% exit /b 103
    @if %ch% GTR %MAX_CH% exit /b 104
    
    @set /a "ex=%~2"
    @if %ex% LSS %MIN_EX% exit /b 105
    @if %ex% GTR %MAX_EX% exit /b 106
    
    @if not exist "%INIT_TEMPLATE%" exit /b 107

    @if not exist ch-%ch% md ch-%ch%
    @if %errorlevel% NEQ 0 (
        echo cpp-init: error: failed to make directory "ch-%ch%"
        exit /b
    )
    
    @pushd ch-%ch%
    @if %errorlevel% NEQ 0 (
        echo cpp-init: error: failed to navigate to directory "ch-%ch%"
        exit /b
    )
    
    @for /L %%i in (1, 1, %ex%) do @if not exist %ch%-%%i.c (
        (copy ..\%INIT_TEMPLATE% %ch%-%%i.c)>NUL && (
            echo cpp-init: %ch%-%%i.c copied.
        ) || echo cpp-init: warning: failed to copy %ch%-%%i.c
    ) else echo cpp-init: warning: %ch%-%%i.c exists, skipped.
    
    @if %errorlevel% NEQ 0 echo cpp-init: warning: error level is %errorlevel% while script ended expectedly.
    @exit /b 0

:CL
@REM cl <chapter> <exercise> [run [clean]]

    @if "%~1" == "" exit /b 201
    @if "%~2" == "" exit /b 202

    @set /a "ch=%~1"
    @if %ch% LSS %MIN_CH% exit /b 203
    @if %ch% GTR %MAX_CH% exit /b 204
    
    @set /a "ex=%~2"
    @if %ex% LSS %MIN_EX% exit /b 205
    @if %ex% GTR %MAX_EX% exit /b 206

    @if not exist ch-%ch%\%ch%-%ex%.c exit /b 207

    @set "run=%~3"
    @set "clean=%~4"

    @cl ch-%ch%\%ch%-%ex%.c
    @if %errorlevel% EQU 0 (
        if /i "%run%" == "run" %ch%-%ex%.exe
        if /i "%clean%" == "clean" del %ch%-%ex%.exe %ch%-%ex%.obj
    ) else exit /b

    @if %errorlevel% NEQ 0 echo cpp-init: warning: error level is %errorlevel% while script ended expectedly.
    @exit /b 0
