# [C Prime Plus Exercises](https://github.com/lxvs/cpp)

This repo is intended for self use, but welcome you to have a try if it helps.

It (`cpp.bat`) has 4 operation (`init`, `cl`, `edit`, `clean`), which can:

- [initialize every exercise of a chapter from TEMPLATE](#slotmachine-initialize-every-exercise-of-a-chapter-from-template)
- [compile, run and clean with a single command](#guitar-compile-run-and-clean-with-a-single-command)
- [edit or create (from TEMPLATE) a C file with your favorite editor](#writinghand-edit-or-create-from-template-a-c-file-with-your-favorite-editor)
- [clean C files that unmodified (i.e. still same with TEMPLATE)](#bathtub-clean-c-files-that-unmodified-ie-still-same-with-template)

But first of all, **reading chapter [Before You Start](#trumpet-before-you-start) and [Environment Variables](#symbols-environment-variables)** is highly recommended.



## :trumpet: Before You Start

1. **If you have Microsoft Visual Studio 2019 (or other versions) installed, open `VsDevCmd.bat` with your favorite editor (as administrator).** You can find it in either of following methods:

   - If you have [Everything](https://en.wikipedia.org/wiki/Everything_(software)) installed, open Everything and search for `VsDevCmd.bat`
   - Or, you can try your luck to find `VsDevCmd.bat` in some directory such as `C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\`

2. **Navigate to the end of `VsDevCmd.bat`, add `pushd %userprofile%\repo\cpp` before `exit /B 0`**, as shown in below image. Remember to **replace the path with the one to the `cpp` repo on your PC**. `%userprofile%` is your user directory (e.g. `C:\Users\your-name`) in Windows OS.

   ![image-before-you-start-vsdevcmd-bat](\README.assets\image-before-you-start-vsdevcmd-bat.png)

3. **Better create a shortcut for `VsDevCmd.bat`**, and then:

   - right-click on the shortcut created, select `Properties`

   - navigate to `Shortcut` tab, click `Advanced...` button, as shown in below image

     ![image-vsdevcmd-properties](\README.assets\image-vsdevcmd-properties.png)

   - Opt in `Run as administrator`, as shown in below screenshot

     ![image-vsdevcmd-properties-admin](\README.assets\image-vsdevcmd-properties-admin.png)

   - Click `OK`, as well as`OK` in properties window

   - You can pin this shortcut to Start, or put it at your favored places.



## :symbols: Environment Variables

`cpp.bat` can be tweaked with some environment variables, as shown in the below table.

| Variable       | Description                                                  | Default value |
| -------------- | ------------------------------------------------------------ | ------------- |
| MIN_CH         | **Minimum** valid **chapter** number. Chapter numbers less that `MIN_CH` will be regarded as invalid | 1             |
| MAX_CH         | **Maximum** valid **chapter** number. Chapter numbers greater that `MAX_CH` will be regarded as invalid | 17            |
| MIN_EX         | **Minimum** valid **exercise** number                        | 1             |
| MAX_CH         | **Maximum** valid **exercise** number                        | 99            |
| TEMPLATE       | **The template used to initialize new exercises.** In fact, the initialization of exercises is copying the template to the corresponding location | `template.c`  |
| DEFAULT_EDITOR | The default editor used in `edit` operation                  | `vim`         |

You can modify the variable values in either of following methods:

* Set the variables in CMD
* Change their default values in `cpp.bat`



## :slot_machine: Initialize Every Exercise of a Chapter From TEMPLATE

#### Synopsis

```
cpp init <chapter> <number-of-exercises>
```

#### Description

Initialize a new chapter (e.g. ch.6, having 18 exercises) by:

- creating the folder `ch-6`
- copying `TEMPLATE` to `ch-6\6-1.c`, `ch-6\6-2.c`, ..., `ch-6\6-18.c`

`TEMPLATE` is a environment variable, default `template.c`

#### ERRORLEVEL value

| ERRORLEVEL | Description                          |
| ---------- | ------------------------------------ |
| 0          | exit expectedly                      |
| 101        | chapter is not provided              |
| 102        | number of exercises is not provided  |
| 103/104    | chapter number is too low/ too high  |
| 105/106    | exercise number is too low/ too high |
| 107        | file `TEMPLATE` does not exist       |



## :guitar: Compile, Run and Clean With a Single Command

#### Synopsis

```
cpp cl <chapter> <exercise> [ r[un] [ c[lean] ] ]
```

#### Description

Build `ch-<chapter>\<chapter>-<exercise>.c`.

If `run` is specified, run it if built successfully. If `clean` is specified, delete generated `.exe` and `.obj` files. You can use `rc` to specify run and clean

#### ERRORLEVEL value

| ERRORLEVEL | Description                          |
| ---------- | ------------------------------------ |
| 0          | exit expectedly                      |
| 201        | chapter is not provided              |
| 202        | number of exercises is not provided  |
| 203/204    | chapter number is too low/ too high  |
| 205/206    | exercise number is too low/ too high |
| 207        | the specified C file does not exist  |



## :writing_hand: Edit or Create (From TEMPLATE) a C File With Your Favorite Editor

#### Synopsis

```
cpp edit <chapter> [ <exercise> | n[ext] ] [<editor>]
```

#### Description

Use `<editor>` to edit `ch-<chapter>\<chapter>-<exercise>.c`.

If `next` is specified, will open the first C file different from `TEMPLATE`. If all C files are different from `TEMPLATE`, will create a new C file of next exercise from `TEMPLATE` and open it with `<editor>`.

If `<exercise>` and `next` are both omitted, `next` is implied.

If `<editor>` is omitted, will use `DEFAULT_EDITOR`, whose default is [`Vim`](https://en.wikipedia.org/wiki/Vim_(text_editor)).

#### ERRORLEVEL value

| ERRORLEVEL | Description                                         |
| ---------- | --------------------------------------------------- |
| 0          | exit expectedly                                     |
| 301        | chapter is not provided                             |
| 302        | exercise provided is invalid                        |
| 303/304    | chapter number is too low/ too high                 |
| 305/306    | exercise number is too low/ too high                |
| 307        | file `TEMPLATE` does not exist                      |
| 308        | the number of existed exercises is already `MAX_EX` |
| 310        | editor provided or DEFAULT_EDITOR is invalid        |



## :bathtub: Clean C Files That Unmodified (I.e. Still Same With TEMPLATE)

#### Synopsis

```
cpp clean [ n | dry ]
```

#### Description

clean C files that are same with `TEMPLATE`.

If `dry` or `n` is specified, won't actually delete anything, just show what would be done.

#### ERRORLEVEL value

| ERRORLEVEL | Description                  |
| ---------- | ---------------------------- |
| 0          | exit expectedly              |
| 401        | argument provided is invalid |

