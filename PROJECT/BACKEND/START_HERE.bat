@echo off
title BookBuddy - Start Here
color 0A
echo.
echo ==========================================
echo    📚 BOOKBUDDY - START HERE
echo ==========================================
echo.
echo Welcome to BookBuddy Backend Setup!
echo.
echo This is for complete beginners.
echo I'll guide you through everything step by step.
echo.
echo What would you like to do?
echo.
echo 1. 📖 Read the complete beginner guide
echo 2. 🚀 Quick setup (I know what I'm doing)
echo 3. 🔧 Fix problems
echo 4. ❓ Get help
echo 5. 🚪 Exit
echo.
set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto guide
if "%choice%"=="2" goto quick
if "%choice%"=="3" goto fix
if "%choice%"=="4" goto help
if "%choice%"=="5" goto exit
goto invalid

:guide
echo.
echo ==========================================
echo           📖 BEGINNER GUIDE
echo ==========================================
echo.
echo I'll show you the complete guide right here!
echo.
echo WHAT ARE WE BUILDING?
echo BookBuddy is a hotel management system that helps hotels manage:
echo - Customer bookings
echo - Room reservations  
echo - Food orders
echo - Staff management
echo - Payments
echo.
echo You're building the "backend" - the engine that makes everything work!
echo.
echo STEP 1: INSTALL REQUIRED SOFTWARE
echo.
echo You need to install two things:
echo 1. Node.js - This runs your website code
echo 2. PostgreSQL - This stores all your data
echo.
echo INSTALLING NODE.JS:
echo 1. Go to: https://nodejs.org/
echo 2. Click the big green "Download" button
echo 3. Run the downloaded file
echo 4. Follow the installation wizard (just click "Next")
echo 5. Restart your computer when done
echo.
echo INSTALLING POSTGRESQL:
echo 1. Go to: https://www.postgresql.org/download/windows/
echo 2. Click "Download the installer"
echo 3. Run the downloaded file
echo 4. IMPORTANT: When it asks for a password, write it down!
echo 5. Follow the installation wizard (just click "Next")
echo 6. Restart your computer when done
echo.
echo HOW TO CHECK IF IT WORKED:
echo 1. Press Windows + R
echo 2. Type cmd and press Enter
echo 3. Type node --version and press Enter
echo 4. You should see something like v18.17.0
echo 5. Type psql --version and press Enter
echo 6. You should see something like psql (PostgreSQL) 15.3
echo.
echo STEP 2: SET UP YOUR PROJECT
echo.
echo 1. Double-click QUICK_START.bat
echo 2. Type 1 and press Enter (First time setup)
echo 3. Wait for it to finish (2-3 minutes)
echo 4. You'll see a success message when done
echo.
echo STEP 3: START YOUR SERVER
echo.
echo 1. Double-click QUICK_START.bat again
echo 2. Type 2 and press Enter (Start the server)
echo 3. Wait for "Server running on port 5000"
echo 4. Keep the black window open!
echo.
echo STEP 4: TEST YOUR WEBSITE
echo.
echo 1. Open your web browser
echo 2. Go to: http://localhost:5000/health
echo 3. You should see information about your server
echo 4. If you see this, congratulations! It's working!
echo.
echo LOGIN CREDENTIALS:
echo.
echo Admin Account:
echo - Email: admin@bookbuddy.com
echo - Password: admin123
echo.
echo Manager Account:
echo - Email: rajesh@bookbuddy.com
echo - Password: manager123
echo.
echo Customer Account:
echo - Email: amit@example.com
echo - Password: customer123
echo.
echo IF SOMETHING GOES WRONG:
echo.
echo Problem: "Node.js not found"
echo Solution: Go back to Step 1, install Node.js correctly, restart computer
echo.
echo Problem: "PostgreSQL not found"
echo Solution: Go back to Step 1, install PostgreSQL correctly, remember password
echo.
echo Problem: "Database connection failed"
echo Solution: Choose option 3 (Fix problems) in this menu
echo.
echo Problem: "Port 5000 is in use"
echo Solution: Close other programs, restart computer
echo.
echo WHAT YOU'VE BUILT:
echo.
echo ✅ A working website that handles hotel bookings
echo ✅ A database that stores all information
echo ✅ User accounts for different types of users
echo ✅ API endpoints that other websites can use
echo ✅ Sample data to test everything
echo.
echo REMEMBER:
echo - Take your time, don't rush
echo - Read the messages, they tell you what's happening
echo - Don't panic, if something goes wrong, just try again
echo - Ask for help if you need it!
echo.
echo Press any key to go back to the main menu...
pause >nul
goto start

:quick
echo.
echo ==========================================
echo           🚀 QUICK SETUP
echo ==========================================
echo.
echo Running quick setup...
echo.
call QUICK_START.bat
goto end

:fix
echo.
echo ==========================================
echo           🔧 FIX PROBLEMS
echo ==========================================
echo.
echo Let me help you fix any problems...
echo.
call scripts\fix-issues.bat
goto end

:help
echo.
echo ==========================================
echo           ❓ GET HELP
echo ==========================================
echo.
echo Here's what you need to know:
echo.
echo 1. WHAT IS THIS?
echo    - BookBuddy is a hotel management system
echo    - You're building the "backend" (the engine that makes it work)
echo    - It handles bookings, payments, staff, etc.
echo.
echo 2. WHAT DO YOU NEED?
echo    - Node.js (download from nodejs.org)
echo    - PostgreSQL (download from postgresql.org)
echo    - Remember the PostgreSQL password!
echo.
echo 3. HOW TO SETUP?
echo    - Install Node.js and PostgreSQL
echo    - Run this script and choose option 2
echo    - Wait for it to finish
echo    - Start the server
echo.
echo 4. WHAT IF IT BREAKS?
echo    - Choose option 3 (Fix problems)
echo    - Read the error messages carefully
echo    - Try again
echo.
echo 5. NEED MORE HELP?
echo    - Ask someone who knows about computers
echo    - Don't panic - we can fix it!
echo.
echo Press any key to go back to the main menu...
pause >nul
goto start

:invalid
echo.
echo Invalid choice! Please enter 1-5.
pause
goto start

:exit
echo.
echo Goodbye! 👋
echo.
echo Remember: Every expert was once a beginner!
echo You've got this! 💪
exit /b 0

:start
cls
goto :eof

:end
echo.
echo Press any key to return to main menu...
pause >nul
goto start