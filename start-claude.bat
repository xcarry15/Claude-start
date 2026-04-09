@echo off
chcp 65001 >nul
title Claude Project Launcher
setlocal EnableDelayedExpansion

for %%I in ("%~dp0..\..") do set "ROOT_DIR=%%~fI"
set "LAST_FILE=%~dp0last_project.txt"
set "lastProjectPath="

if exist "%LAST_FILE%" (
    set /p lastProjectPath=<"%LAST_FILE%"
)

cd /d "%ROOT_DIR%"

echo.
echo Claude Project Launcher

:select_project
set "count=0"

for /f "delims=" %%I in ('dir /b /ad ^| findstr /R "^[A-Za-z]-"') do (
    set /a count+=1
    set "project[!count!]=%%I"
    echo   [!count!]  %%I
)

echo.
echo   [0]   %ROOT_DIR%
echo   [00]  Exit
if defined lastProjectPath echo   [R]   Last: !lastProjectPath!
echo.

set "choice="
set /p "choice=Choose project (0 / R / 00): "

if not defined choice goto :exit
if "%choice%"=="0" (
    set "finalPath=%ROOT_DIR%"
    goto :start_claude
)
if "%choice%"=="00" goto :exit
if /I "%choice%"=="R" goto :resume_last

echo(%choice%| findstr /R "^[0-9][0-9]*$" >nul
if errorlevel 1 goto :invalid
if %choice% gtr %count% goto :invalid
if %choice% lss 1 goto :invalid

set "projectPath=!ROOT_DIR!\!project[%choice%]!"
set "projectRoot=!projectPath!"
set "currentDir=!projectPath!"
goto :select_dir

:invalid
echo Invalid project number: %choice%
pause
goto :select_project

:select_dir
echo.
echo Current: !currentDir!

set "subCount=0"
for /f "delims=" %%D in ('dir /b /ad "!currentDir!"') do (
    set /a subCount+=1
    set "subdir[!subCount!]=%%D"
)

if !subCount! equ 0 (
    echo No subdirectories. Using current directory.
    set "finalPath=!currentDir!"
    goto :start_claude
)

echo.
echo Subdirectories:
echo   [Enter]  Use current directory
echo   [B]      Back
for /l %%N in (1,1,!subCount!) do echo   [%%N]    !subdir[%%N]!
echo.

set "choice2="
set /p "choice2=Choose subdirectory (0-!subCount!, Enter=0): "
if not defined choice2 set "choice2=0"
if /I "%choice2%"=="B" goto :go_back

if "%choice2%"=="0" (
    set "finalPath=!currentDir!"
    goto :start_claude
)

echo(%choice2%| findstr /R "^[0-9][0-9]*$" >nul
if errorlevel 1 goto :dir_invalid
if %choice2% gtr !subCount! goto :dir_invalid
if %choice2% lss 1 goto :dir_invalid

set "currentDir=!currentDir!\!subdir[%choice2%]!"
goto :select_dir

:go_back
if /I "!currentDir!"=="!projectRoot!" goto :select_project
for %%P in ("!currentDir!\..") do set "currentDir=%%~fP"
goto :select_dir

:dir_invalid
echo Invalid subdirectory number: %choice2%
pause
goto :select_dir

:resume_last
if not defined lastProjectPath (
    echo.
    echo No last directory recorded.
    pause
    goto :select_project
)
if not exist "!lastProjectPath!" (
    echo.
    echo Last directory does not exist:
    echo   !lastProjectPath!
    pause
    goto :select_project
)
set "finalPath=!lastProjectPath!"
goto :start_claude

:start_claude
echo.
echo Launch directory:
echo   !finalPath!

> "%LAST_FILE%" echo !finalPath!
claude --dangerously-skip-permissions "!finalPath!"
goto :end

:exit
echo Exited.

:end
endlocal
