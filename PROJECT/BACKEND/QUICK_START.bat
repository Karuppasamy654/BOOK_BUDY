@echo off
title BookBuddy - Quick Start
color 0F
echo.
echo ==========================================
echo    🚀 BOOKBUDDY - QUICK START
echo ==========================================
echo.
echo Choose what you want to do:
echo.
echo 1. First time setup (install everything)
echo 2. Start the server
echo 3. Fix problems
echo 4. Check status
echo 5. Exit
echo.
set /p choice="Enter your choice (1-5): "


if "%choice%"=="1" goto setup
if "%choice%"=="2" goto start
if "%choice%"=="3" goto fix
if "%choice%"=="4" goto status
if "%choice%"=="5" goto exit
goto invalid

:setup
echo.
echo Running first time setup...
call scripts\easy-setup.bat
goto end

:start
echo.
echo Starting the server...
call scripts\start-server.bat
goto end

:fix
echo.
echo Fixing issues...
call scripts\fix-issues.bat
goto end

:status
echo.
echo Checking system status...
call scripts\check-status.bat
goto end

:invalid
echo.
echo Invalid choice! Please enter 1-5.
pause
goto start

:exit
echo.
echo Goodbye! 👋
exit /b 0

:end
echo.
echo Press any key to return to main menu...
pause >nul
goto start
