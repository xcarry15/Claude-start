@echo off
chcp 65001 >nul
title Claude Project Launcher
setlocal DisableDelayedExpansion

for %%I in ("%~dp0..\..") do set "ROOT_DIR=%%~fI"
set "LAST_FILE=%~dp0last_project.txt"
set "lastProjectPath="

if exist "%LAST_FILE%" (
    set /p "lastProjectPath="<"%LAST_FILE%"
)

cd /d "%ROOT_DIR%" || (
    echo Failed to access root directory:
    echo   "%ROOT_DIR%"
    pause
    goto :end
)

echo.
echo Claude Project Launcher

:select_project
set "count=0"

for /f "delims=" %%I in ('dir /b /ad') do (
    set /a count+=1
    call set "project[%%count%%]=%%I"
    call :print_project %%count%%
)

echo.
if %count% equ 0 echo   No project directories found under %ROOT_DIR%
echo   [0]   %ROOT_DIR%
echo   [00]  Exit
if defined lastProjectPath echo   [R]   Last: %lastProjectPath%
echo.

set "choice="
set /p "choice=Choose project (Enter=stay, 0 / R / 00): "

if not defined choice goto :select_project
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

call set "projectPath=%ROOT_DIR%\%%project[%choice%]%%"
set "projectRoot=%projectPath%"
set "currentDir=%projectPath%"
goto :select_dir

:invalid
echo Invalid project number: %choice%
pause
goto :select_project

:select_dir
echo.
echo Current: %currentDir%

set "subCount=0"
for /f "delims=" %%D in ('dir /b /ad "%currentDir%"') do (
    set /a subCount+=1
    call set "subdir[%%subCount%%]=%%D"
)

if %subCount% equ 0 (
    echo No subdirectories. Using current directory.
    set "finalPath=%currentDir%"
    goto :start_claude
)

echo.
echo Subdirectories:
echo   [Enter]  Use current directory
echo   [B]      Back
for /l %%N in (1,1,%subCount%) do call :print_subdir %%N
echo.

set "choice2="
set /p "choice2=Choose subdirectory (0-%subCount%, Enter=0): "
if not defined choice2 set "choice2=0"
if /I "%choice2%"=="B" goto :go_back

if "%choice2%"=="0" (
    set "finalPath=%currentDir%"
    goto :start_claude
)

echo(%choice2%| findstr /R "^[0-9][0-9]*$" >nul
if errorlevel 1 goto :dir_invalid
if %choice2% gtr %subCount% goto :dir_invalid
if %choice2% lss 1 goto :dir_invalid

call set "currentDir=%currentDir%\%%subdir[%choice2%]%%"
goto :select_dir

:go_back
if /I "%currentDir%"=="%projectRoot%" goto :select_project
for %%P in ("%currentDir%\..") do set "currentDir=%%~fP"
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
if not exist "%lastProjectPath%" (
    echo.
    echo Last directory does not exist:
    echo   %lastProjectPath%
    pause
    goto :select_project
)
set "finalPath=%lastProjectPath%"
goto :start_claude

:start_claude
echo.
echo Launch directory:
echo   %finalPath%

where claude >nul 2>nul
if errorlevel 1 (
    echo Claude CLI was not found in PATH.
    pause
    goto :end
)

call :write_last_path "%finalPath%"
if errorlevel 1 (
    echo Failed to save last project path:
    echo   %LAST_FILE%
    pause
    goto :end
)

set "lastProjectPath=%finalPath%"
claude --dangerously-skip-permissions "%finalPath%"
set "claudeExit=%ERRORLEVEL%"
if not "%claudeExit%"=="0" (
    echo Claude exited with code %claudeExit%.
    pause
)
goto :end

:print_project
call echo   [%~1]  %%project[%~1]%%
exit /b 0

:print_subdir
call echo   [%~1]    %%subdir[%~1]%%
exit /b 0

:write_last_path
> "%LAST_FILE%" echo(%~1
if errorlevel 1 exit /b 1
exit /b 0

:exit
echo Exited.

:end
endlocal
