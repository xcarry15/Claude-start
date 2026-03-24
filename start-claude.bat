@echo off
chcp 65001 >nul
title Claude Project Launcher
setlocal enabledelayedexpansion

rem ===== 基础配置 =====
set "ROOT_DIR=D:\0_系统文件夹\桌面\web"
set "SCRIPT_DIR=%~dp0"
set "LAST_FILE=%SCRIPT_DIR%last_project.txt"
set "STATS_FILE=%SCRIPT_DIR%project_stats.txt"

cd /d "%ROOT_DIR%"

rem ===== 读取统计数据 =====
call :load_stats

rem ===== 显示欢迎标题 =====
echo.
echo ========================================
echo   Claude Project Launcher
echo ========================================
echo.

rem ===== 显示最近使用（最近3个）=====
call :show_recent

rem ===== 读取上次项目 =====
set "lastProjectPath="
if exist "%LAST_FILE%" set /p lastProjectPath=<"%LAST_FILE%"

:select_project
echo.
echo ----------------------------------------
echo   [Enter] 启动上次项目  [R] 恢复会话  [00] 退出
echo ----------------------------------------

rem ===== 扫描项目列表 =====
set count=0
for /f "delims=" %%i in ('dir /b /ad') do (
    echo %%i | findstr /R "^[A-Za-z]-" >nul
    if not errorlevel 1 (
        set /a count+=1
        set project[!count!]=%%i
        echo   [!count!]  %%i
    )
)

if %count%==0 goto :no_projects

echo.
set "choice="
set /p choice=选择项目编号或输入关键字搜索:

rem ===== 处理输入 =====
if "%choice%"=="" (
    if "!lastProjectPath!"=="" goto :select_project
    set "finalPath=!lastProjectPath!"
    goto :validate_last
)

if "%choice%"=="00" goto :exit
if /I "%choice%"=="R" goto :resume_last

rem ===== 数字输入 =====
echo(%choice%| findstr /R "^[0-9][0-9]*$" >nul
if not errorlevel 1 (
    if %choice% gtr %count% goto :invalid_choice
    if %choice% lss 1 goto :invalid_choice
    set projectPath=!project[%choice%]!
    goto :select_dir
)

rem ===== 关键字搜索 =====
set "searchKeyword=%choice%"
set "matchCount=0"

echo.
echo 搜索 "!searchKeyword!" 的结果:
echo   [0]  取消
echo.

for /l %%n in (1,1,%count%) do (
    echo !project[%%n]! | findstr /I /C:"!searchKeyword!" >nul
    if not errorlevel 1 (
        set /a matchCount+=1
        set match[!matchCount!]=%%n
        echo   [!matchCount!]  !project[%%n]!
    )
)

if %matchCount%==0 (
    echo   无匹配结果
    pause
    goto :select_project
)

echo.
set "matchChoice="
set /p matchChoice=选择编号(Enter=0):

if "%matchChoice%"=="" set "matchChoice=0"

rem 校验输入为纯数字
echo(%matchChoice%| findstr /R "^[0-9][0-9]*$" >nul
if errorlevel 1 goto :invalid_choice

if "%matchChoice%"=="0" goto :select_project
if %matchChoice% gtr %matchCount% goto :invalid_choice

set projectPath=!project[!match[%matchChoice%]!]!
goto :select_dir

:invalid_choice
echo 无效输入: %choice%
pause
goto :select_project

rem ===== 多级目录选择 =====
:select_dir
echo.
set "projectRoot=%projectPath%"
set "currentDir=%projectPath%"

:dir_loop
echo.
echo 当前: %currentDir%

set "hasSubDir=0"
set "subCount=0"

for /f "delims=" %%d in ('dir /b /ad "%currentDir%"') do (
    set /a subCount+=1
    set "subdir[!subCount!]=%%d"
    set "hasSubDir=1"
)

if "%hasSubDir%"=="0" (
    echo 无子目录，使用此目录。
    set "finalPath=%currentDir%"
    goto :start_claude
)

echo.
echo 子目录:
echo   [0]  使用当前目录
echo   [B]  返回上级

for /l %%n in (1,1,%subCount%) do (
    echo   [%%n]  !subdir[%%n]!
)

echo.
set "choice2="
set /p choice2=选择编号(Enter=0):

if "%choice2%"=="" set "choice2=0"
if /I "%choice2%"=="B" goto :go_back

rem 校验输入为纯数字
echo(%choice2%| findstr /R "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo 无效编号: %choice2%
    pause
    goto :dir_loop
)

if "%choice2%"=="0" (
    set "finalPath=%currentDir%"
    goto :start_claude
)

if %choice2% gtr %subCount% (
    echo 无效编号: %choice2%
    pause
    goto :dir_loop
)
if %choice2% lss 1 (
    echo 无效编号: %choice2%
    pause
    goto :dir_loop
)

set "currentDir=%currentDir%\!subdir[%choice2%]!"
goto :dir_loop

:go_back
for %%p in ("%currentDir%\..") do set "currentDir=%%~fp"
if /I "%currentDir%"=="%projectRoot%" goto :select_project
goto :dir_loop

rem ===== 启动 Claude =====
:start_claude
echo.
echo 启动目录:
echo   %finalPath%

rem 记录使用统计
call :record_usage

rem 保存为上次项目
> "%LAST_FILE%" echo %finalPath%

claude --dangerously-skip-permissions "%finalPath%"
goto :exit

rem ===== 验证上次目录是否有效 =====
:validate_last
if not exist "!lastProjectPath!" (
    echo.
    echo 上次目录不存在:
    echo   !lastProjectPath!
    set "lastProjectPath="
    pause
    goto :select_project
)
set "finalPath=%lastProjectPath%"
goto :start_claude

:resume_last
if "%lastProjectPath%"=="" (
    echo.
    echo 无上次目录记录。
    pause
    goto :select_project
)
if not exist "%lastProjectPath%" (
    echo.
    echo 上次目录不存在:
    echo   %lastProjectPath%
    set "lastProjectPath="
    pause
    goto :select_project
)
set "finalPath=%lastProjectPath%"
goto :start_claude

:no_projects
echo.
echo 无符合命名规则的项目（英文- 开头）。
echo 根目录: %ROOT_DIR%
pause
goto :exit

:exit
endlocal
exit /b

rem ===== 加载统计数据 =====
:load_stats
set "stat_count=0"
if exist "%STATS_FILE%" (
    for /f "tokens=1,2,3 delims=|" %%a in ('type "%STATS_FILE%"') do (
        set /a stat_count+=1
        set stat_path[!stat_count!]=%%a
        set stat_count[!stat_count!]=%%b
        set stat_time[!stat_count!]=%%c
    )
)
goto :eof

rem ===== 显示最近使用 =====
:show_recent
if %stat_count%==0 exit /b

rem 按时间排序，取最近3个
echo 最近使用:
echo.

set "recentShown=0"
for /l %%i in (1,1,%stat_count!) do (
    if !recentShown! lss 3 (
        set "p=!stat_path[%%i]!"
        if not "!p!"=="" (
            for %%t in (!stat_time[%%i]!) do set "t_text=%%t"
            echo   [!recentShown!]  !p!
            set /a recentShown+=1
        )
    )
)
if %recentShown% gtr 0 echo.
goto :eof

rem ===== 记录使用统计 =====
:record_usage
set "found=0"
set "newStats="

rem 检查是否已记录
for /l %%i in (1,1,%stat_count!) do (
    if "!stat_path[%%i]!"=="%finalPath%" (
        set /a newCount=!stat_count[%%i]! + 1
        set "newStats=!newStats!!stat_path[%%i]!|!newCount!|%date% %time%"
        set "found=1"
    ) else (
        set "newStats=!newStats!!stat_path[%%i]!|!stat_count[%%i]!|!stat_time[%%i]!"
    )
)

if %found%==0 (
    set "newStats=!newStats!%finalPath%|1|%date% %time%"
)

echo !newStats! > "%STATS_FILE%"
goto :eof
