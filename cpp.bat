@REM This script is used in repo github.com/lxvs/cpp
@REM Author:        lxvs <jn.apsd+batch@gmail.com>
@REM Created:       2021-04-01
@REM Last updated:  2021-04-02
@REM
@REM Usage: cpp <operation> [<argument> ...]
@REM
@REM    Operation: init, cl, edit
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
@REM    107         file TEMPLATE does not exist
@REM
@REM cpp cl <chapter> <exercise> [ r[un] [ c[lean] ] ]
@REM
@REM    Build ch-<chapter>\<chapter>-<exercise>.c
@REM
@REM    If "run" is specified, run it if built successfully
@REM    If "clean" is specified, delete generated .exe and .obj files
@REM    You can use "rc" to specify run and clean
@REM
@REM    errorlevel value returned
@REM    0           exit expectedly
@REM    201         chapter is not provided
@REM    202         number of exercises is not provided
@REM    203/204     chapter number is too low/ too high
@REM    205/206     exercise number is too low/ too high
@REM    207         the specified c file does not exist
@REM
@REM cpp edit <chapter> [ <exercise> | n[ext] ] [<editor>]
@REM
@REM    Use <editor> to edit ch-<chapter>\<chapter>-<exercise>.c
@REM
@REM    If "next" is specified, will open the first c file different
@REM        from TEMPLATE. If all c files are different from TEMPLATE,
@REM        will create a new c file of next exercise from TEMPLATE and
@REM        open it with <editor>
@REM    If <exercise> and "next" are both omitted, "next" is implied
@REM    If <editor> is omitted, will use gvim
@REM
@REM    errorlevel value returned
@REM    0           exit expectedly
@REM    301         chapter is not provided
@REM    302         exercise provided is invalid
@REM    303/304     chapter number is too low/ too high
@REM    306         the number of existed exercises is MAX_EX
@REM    307         file TEMPLATE does not exist
@REM    310         editor provided is invalid

@if "%~1" == "" (
    echo Error: no operation provided
    echo Read this script in editor for detailed usage
    exit /b 1
)

@setlocal EnableExtensions EnableDelayedExpansion

@set /a "MIN_CH=1"
@set /a "MAX_CH=17"
@set /a "MIN_EX=1"
@set /a "MAX_EX=99"

@set "TEMPLATE=template.c"

@set op=
@if /i "%~1" == "init" set "op=%~1"
@if /i "%~1" == "cl" set "op=%~1"
@if /i "%~1" == "edit" set "op=%~1"

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
@call:%op%%allArgs%
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

    @if not exist "%TEMPLATE%" exit /b 107

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
        (copy ..\%TEMPLATE% %ch%-%%i.c)>NUL && (
            echo cpp-init: %ch%-%%i.c copied.
        ) || echo cpp-init: warning: failed to copy %ch%-%%i.c
    ) else echo cpp-init: warning: %ch%-%%i.c exists, skipped.

    @if %errorlevel% NEQ 0 echo cpp-init: warning: error level is %errorlevel% while script ended expectedly.
    @exit /b 0

:CL
@REM cl <chapter> <exercise> [ r[un] [ c[lean] ] ]

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

    @if /i "%run%" == "r" set "run=run"
    @if /i "%clean%" == "c" set "clean=clean"
    @if /i "%run%" == "rc" if "%clean%" == "" (
        set "run=run"
        set "clean=clean"
    )

    @call cl ch-%ch%\%ch%-%ex%.c
    @if %errorlevel% EQU 0 (
        if /i "%run%" == "run" call %ch%-%ex%.exe
        if /i "%clean%" == "clean" del %ch%-%ex%.exe %ch%-%ex%.obj
    ) else exit /b

    @if %errorlevel% NEQ 0 echo cpp-init: warning: error level is %errorlevel% while script ended expectedly.
    @exit /b 0

:Edit
@REM edit <chapter> [ <exercise> | n[ext] ] [<editor>]

    @if "%~1" == "" exit /b 301

    @if not exist %TEMPLATE% exit /b 307

    @set ex=
    @if "%~2" == "" (set "ex=next") else (
        if /i "%~2" == "n" (set "ex=next") else (
            if /i "%~2" == "next" (set "ex=next") else set /a "ex=%~2"
        )
    )

    @if not "%ex%" == "next" if not "%ex%" == "%~2" exit /b 302

    @set /a "ch=%~1"
    @if %ch% LSS %MIN_CH% exit /b 303
    @if %ch% GTR %MAX_CH% exit /b 304

    @set found=
    @if "%ex%" == "next" (
        for /L %%i in (%MIN_EX%, 1, %MAX_EX%) do @if not defined found (
            if exist "ch-%ch%\%ch%-%%i.c" (
                fc %TEMPLATE% "ch-%ch%\%ch%-%%i.c" 1>NUL 2>&1 && set "found=%%i"
            ) else (
                set "found=%%i"
            )
        )

        if not defined found exit /b 306

        set "fte=ch-%ch%\%ch%-!found!.c"
        REM fte means file to edit

        if not exist !fte! (
            echo cpp-edit: would create file !fte!
            copy %TEMPLATE% !fte! 1>NUL
            if !errorlevel! NEQ 0 (
                echo cpp-edit: error: failed to copy %TEMPLATE% to !fte!
                exit /b
            )
        )
    )

    @if "%~3" == "" (set "editor=gvim") else set "editor=%~3"

    @where %editor% 1>NUL 2>&1 && (call %editor% %fte%) || exit /b 310

    @if %errorlevel% NEQ 0 echo cpp-edit: warning: error level is %errorlevel% while script ended expectedly.
    @exit /b 0
