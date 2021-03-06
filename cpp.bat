@REM https://lxvs.net/cpp
@REM Version:       v0.3.0
@REM Last updated:  2021-06-24
@REM
@REM Usage: cpp <operation> [<argument> ...]
@REM
@REM    Operation: init, cl, edit, clean, ls
@REM
@REM cpp init <chapter> <number-of-exercises> [<template>]
@REM
@REM    init a new chapter (e.g. ch.6, having 18 exercises) by:
@REM        creating the folder ch-6
@REM        copying <template> to ch-6\6-1.c, ch-6\6-2.c, ..., ch-6\6-18.c
@REM
@REM    If <template> does not exist, will use TEMPLATE and throw a warnning.
@REM
@REM    errorlevel value returned
@REM    0           0x00        exit expectedly
@REM    33          0x21        number of exercises is not provided
@REM    34/35       0x22/0x23   chapter number is too low/ too high
@REM    36/37       0x24/0x25   exercise number is too low/ too high
@REM    38          0x26        file TEMPLATE does not exist
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
@REM    0           0x00        exit expectedly
@REM    65          0x41        number of exercises is not provided
@REM    66/67       0x42/0x43   chapter number is too low/ too high
@REM    68/69       0x44/0x45   exercise number is too low/ too high
@REM    71          0x47        the specified C file does not exist
@REM
@REM cpp edit <chapter> [ <exercise> | n[ext] ] [<editor>]
@REM
@REM    Use <editor> to edit ch-<chapter>\<chapter>-<exercise>.c
@REM
@REM    If "next" is specified, will open the first C file different
@REM        from TEMPLATE. If all C files are different from TEMPLATE,
@REM        will create a new C file of next exercise from TEMPLATE and
@REM        open it with <editor>
@REM    If <exercise> and "next" are both omitted, "next" is implied
@REM    If <editor> is omitted, will use DEFAULT_EDITOR (default is Vim)
@REM
@REM    errorlevel value returned
@REM    0           0x00        exit expectedly
@REM    96          0x60        chapter is not provided
@REM    97          0x61        exercise provided is invalid
@REM    98/99       0x62/0x63   chapter number is too low/ too high
@REM    100/101     0x64/0x65   exercise number is too low/ too high
@REM    102         0x66        file TEMPLATE does not exist
@REM    103         0x67        the number of existed exercises is MAX_EX
@REM    104         0x68        editor provided or DEFAULT_EDITOR is invalid
@REM
@REM cpp clean [ n | dry ]
@REM
@REM    clean C files that are same with TEMPLATE
@REM
@REM    If "dry" or "n" is specified, won't actually delete anything, just
@REM        show what would be done
@REM
@REM    errorlevel value returned
@REM    0           0x00        exit expectedly
@REM    128         0x80        argument provided is invalid
@REM
@REM cpp ls [ f[ast] ] [<opening-chapter>]
@REM
@REM    If "fast" is specified, show existing exercises. Otherwise, will not
@REM    display files that are same with TEMPLATE.
@REM
@REM    If <opening-chapter> is specified, will not displays chapters that
@REM    are before it.

@echo off

@if "%~1" == "" (
    >&2 echo cpp: ERROR: No operation provided.
    >&2 echo Read this script or visit https://lxvs.net/cpp for detailed usage.
    exit /b 1
)

@setlocal EnableExtensions EnableDelayedExpansion

@if not defined MIN_CH set /a "MIN_CH=1"
@if not defined MAX_CH set /a "MAX_CH=17"
@if not defined MIN_EX set /a "MIN_EX=1"
@if not defined MAX_EX set /a "MAX_EX=99"

@if not defined TEMPLATE set "TEMPLATE=template.c"
@if not defined DEFAULT_EDITOR set "DEFAULT_EDITOR=Vim"

@set op=
@if "%~1" == "/?" (
    @echo Read this script or visit https://lxvs.net/cpp for detailed usage.
    exit /b
)
@if /i "%~1" == "init" set "op=%~1"
@if /i "%~1" == "cl" set "op=%~1"
@if /i "%~1" == "edit" set "op=%~1"
@if /i "%~1" == "clean" set "op=%~1"
@if /i "%~1" == "ls" set "op=%~1"

@if "%op%" == "" (
    >&2 echo cpp: ERROR: invalid operation: %~1
    exit /b 1
)

@set allArgs=
@shift
:loop_gather_arg
@if "%~1" == "" goto post_loop_gather_arg
@if "%~1" == "/?" (
    @echo Read this script or visit https://lxvs.net/cpp for detailed usage.
    exit /b
)
@set allArgs=%allArgs% %1
@shift
@goto loop_gather_arg

:post_loop_gather_arg
@call:%op%%allArgs%
@if %errorlevel% NEQ 0 if /i not "%op%" == "cl" @echo cpp-%op% terminated with error %errorlevel%
@exit /b

:Init
@REM init <chapter> <number-of-exercises> [<template>]

    @if "%~2" == "" exit /b 33

    @set /a "ch=%~1"
    @if %ch% LSS %MIN_CH% exit /b 34
    @if %ch% GTR %MAX_CH% exit /b 35

    @set /a "ex=%~2"
    @if %ex% LSS %MIN_EX% exit /b 36
    @if %ex% GTR %MAX_EX% exit /b 37

    @set "template_init=%~3"
    @if defined template_init (
        if not exist "%template_init%" (
            if exist "%TEMPLATE%" (
                >&2 echo cpp-init: warning: Invalid specified template: %template_init%
                >&2 echo                    Will use default template ^(%TEMPLATE%^).
                set "template_init=%TEMPLATE%"
            ) else (
                exit /b 38
            )
        )
    ) else (
        if exist "%TEMPLATE%" (
            set "template_init=%TEMPLATE%"
        ) else (
            exit /b 38
        )
    )

    @if not exist ch-%ch% md ch-%ch%
    @if %errorlevel% NEQ 0 (
        >&2 echo cpp-init: ERROR: failed to make directory "ch-%ch%".
        exit /b
    )

    @pushd ch-%ch%
    @if %errorlevel% NEQ 0 (
        >&2 echo cpp-init: ERROR: failed to navigate to directory "ch-%ch%".
        exit /b
    )

    @for /L %%i in (1, 1, %ex%) do @if not exist %ch%-%%i.c (
        (copy ..\%template_init% %ch%-%%i.c)>NUL && (
            @echo cpp-init: %ch%-%%i.c copied.
        ) || >&2 echo cpp-init: warning: failed to copy %ch%-%%i.c
    ) else >&2 echo cpp-init: warning: %ch%-%%i.c exists, skipped.

    @exit /b 0

:CL
@REM cl <chapter> <exercise> [ r[un] [ c[lean] ] ]

    @if "%~2" == "" exit /b 65

    @set /a "ch=%~1"
    @if %ch% LSS %MIN_CH% exit /b 66
    @if %ch% GTR %MAX_CH% exit /b 67

    @set /a "ex=%~2"
    @if %ex% LSS %MIN_EX% exit /b 68
    @if %ex% GTR %MAX_EX% exit /b 69

    @if not exist ch-%ch%\%ch%-%ex%.c exit /b 71

    @set "run=%~3"
    @set "clean=%~4"

    @if /i "%run%" == "rc" (
        if "%clean%" == "" (
            set "run=run"
            set "clean=clean"
        )
    ) else (
        if /i "%run%" == "r" set "run=run"
        if /i "%clean%" == "c" set "clean=clean"
    )

    @cl /nologo ch-%ch%\%ch%-%ex%.c
    @if %errorlevel% EQU 0 (
        if /i "%run%" == "run" (
            %ch%-%ex%.exe
            @if not "!errorlevel!" == "0" @echo cpp-cl: %ch%-%ex%.exe returns !errorlevel!
        )
        if /i "%clean%" == "clean" del %ch%-%ex%.exe %ch%-%ex%.obj
    ) else exit /b

    @exit /b

:Edit
@REM edit <chapter> [ <exercise> | n[ext] ] [<editor>]

    @if "%~1" == "" exit /b 96

    @if not exist %TEMPLATE% exit /b 102

    @set ex=
    @if "%~2" == "" (set "ex=next") else (
        if /i "%~2" == "n" (set "ex=next") else (
            if /i "%~2" == "next" (set "ex=next") else set /a "ex=%~2"
        )
    )

    @if not "%ex%" == "next" if not "%ex%" == "%~2" exit /b 97

    @set /a "ch=%~1"
    @if %ch% LSS %MIN_CH% exit /b 98
    @if %ch% GTR %MAX_CH% exit /b 99

    @if not exist ch-%ch%\ md ch-%ch% || (
        >&2 echo cpp-edit: ERROR: failed to create directory ch-%ch%
        exit /b 1
    )

    @set found=
    @if "%ex%" == "next" (
        for /L %%i in (%MIN_EX%, 1, %MAX_EX%) do @if not defined found (
            if exist "ch-%ch%\%ch%-%%i.c" (
                fc %TEMPLATE% "ch-%ch%\%ch%-%%i.c" 1>NUL 2>&1 && set "found=%%i"
            ) else (
                set "found=%%i"
            )
        )

        if not defined found exit /b 103

        set "fte=ch-%ch%\%ch%-!found!.c"
        @REM fte means file to edit
    ) else (
        @REM else of if "%ex%" == "next"

        if %ex% LSS %MIN_EX% exit /b 100
        if %ex% GTR %MAX_EX% exit /b 101
        set "fte=ch-%ch%\%ch%-%ex%.c"
    )

    @if not exist %fte% (
        @echo cpp-edit: would create file %fte%
        copy %TEMPLATE% %fte% 1>NUL
        if !errorlevel! NEQ 0 (
            >&2 echo cpp-edit: ERROR: failed to copy %TEMPLATE% to %fte%
            exit /b
        )
    )

    @if "%~3" == "" (set "editor=%DEFAULT_EDITOR%") else set "editor=%~3"

    @where %editor% 1>NUL 2>&1 && (%editor% %fte%) || exit /b 104

    @exit /b 0

:Clean
@REM clean [ n | dry ]

    @set dry=

    @if not "%~1" == "" (
        if /i "%~1" == "n" (
            set "dry=dry"
        ) else if /i "%~1" == "dry" (
            set "dry=dry"
        ) else exit /b 128
    )

    @for /f %%i in ('dir /b /a-d *.exe *.obj *.out 2^>NUL') do @(
        if "%dry%" == "" (
            del "%%i" 1>NUL && @echo Deleted %%i
        ) else (
            @echo Would delete %%i
        )
    )
    @for /f %%i in ('dir /b /ad ch-* 2^>NUL') do @(
        for /f %%j in ('dir /b /a-d %%i\*.c 2^>NUL') do @(
            fc %TEMPLATE% "%%i\%%j" 1>NUL 2>&1 && (
                if "%dry%" == "" (
                    del "%%i\%%j" 1>NUL && @echo Deleted %%i\%%j
                ) else (
                    @echo Would delete %%i\%%j
                )
            )
        )
        if "%dry%" == "" rd %%i 2>NUL && @echo Removed %%i
    )

    @exit /b 0

:ls
@REM ls [ f[ast] ] [<opening-chapter>]

set "fast="
set /a "oc=0"
:ls_parse_arg
if "%~1" == "" goto ls_parse_arg_end
set "arg=%~1"
set /a "arga=arg"
if /i "%arg%" == "f" (
    set "fast=fast"
) else if /i "%arg%" == "fast" (
    set "fast=fast"
) else if "%arga%" == "%arg%" (
    set /a "oc=arga"
) else (
    >&2 echo cpp-ls: ERROR: Unrecognized argument: %arg%
    exit /b 1
)
if "%~2" NEQ "" (
    shift
    goto ls_parse_arg
)
:ls_parse_arg_end

for /f "tokens=2 delims=-" %%i in ('dir /b /ad ch-* 2^>NUL') do (
    if %oc% LEQ %%i (
        set "chDisp="
        set /a "index=0"
        setlocal
        for /f "tokens=2 delims=-" %%I in ('dir /b /a-d ch-%%i\*.c 2^>NUL') do (
            set "num=00000%%I"
            set "num=!num:~-5!"
            set "cppls$!num!=%%I"
        )
        for /f "tokens=2,* delims==" %%a in ('set cppls$') do (
            if /i "%fast%" == "fast" (
                if not defined chDisp (
                    set "chDisp=1"
                    echo;
                    echo Chapter %%i
                )
                if !index! EQU 0 echo;
                set /p=%%i-%%a		<nul
                set /a "index=(!index!+1)%%5"
            ) else (
                fc "%TEMPLATE%" "ch-%%i\%%i-%%a" 1>NUL 2>&1 || (
                    if not defined chDisp (
                        set "chDisp=1"
                        echo;
                        echo Chapter %%i
                    )
                    if !index! EQU 0 echo;
                    set /p=%%i-%%a		<nul
                    set /a "index=(!index!+1)%%5"
                )
            )
        )
        if defined chDisp echo;
        endlocal
    )
)

exit /b 0
