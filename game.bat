@echo off
setlocal enabledelayedexpansion

:: Check for Administrator privileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' (
    echo Administrative privileges confirmed.
) else (
    echo **************************************
    echo * Please run as Administrator!       *
    echo **************************************
    pause
    exit /b 1
)

:: Color and UI settings
set ESC=[
set RESET=[0m
set RED=[91m
set GREEN=[92m
set YELLOW=[93m
set CYAN=[96m
set BOLD=[1m

title Ultimate TCP Optimizer v2.2
mode con: cols=75 lines=25

:main
cls
echo %ESC%104m%ESC%30m
echo ===================================================
echo                ULTIMATE NetWork OPTIMIZER               
echo ===================================================
echo %RESET%%CYAN%[1] Disable Auto-Tuning (Gaming Mode)
echo [2] Enable Normal Auto-Tuning - fast browsing 
echo [3] Set Gaming UDP Optimization
echo [4] Restore Default Settings
echo [5] Show Current Configuration
echo [6] Exit
echo.
echo %YELLOW%Select an option [1-6]:%RESET%
set /p choice=

:: Input validation with corrected labels
if "%choice%"=="1" goto option1
if "%choice%"=="2" goto option2
if "%choice%"=="3" goto option3
if "%choice%"=="4" goto option4
if "%choice%"=="5" goto option5
if "%choice%"=="6" goto option6
echo %RED%Invalid choice! Please enter 1-6%RESET%
timeout /t 2 >nul
goto main

:option1
call :action "Disabling Network Auto-Tuning..." "Netsh int tcp set global autotuning=disabled"
goto main

:option2 
call :action "Enabling Normal Auto-Tuning..." "Netsh int tcp set global autotuning=normal"
goto main

:option3
call :reg_action "Setting UDP Gaming Optimization..." "add" "FastSendDatagramThreshold" 0x64000
goto main

:option4
call :action "Restoring Default Settings..." "Netsh int tcp set global autotuning=normal"
call :reg_action "" "delete" "FastSendDatagramThreshold"
goto main

:option5
cls
echo %CYAN%=== Current TCP Configuration ===%RESET%
netsh int tcp show global
echo.
echo %CYAN%=== Registry Values ===%RESET%
reg query "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "FastSendDatagramThreshold" 2>nul
pause
goto main

:option6
exit

:action
echo %GREEN%%~1%RESET%
%~2
echo %CYAN%New settings:%RESET%
netsh int tcp show global
call :log "Action: %~1"
pause
exit /b

:reg_action
if "%~2"=="add" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "%~3" /t REG_DWORD /d %~4 /f >nul 2>&1
    echo %GREEN%Registry value %~3 set to %~4%RESET%
) else (
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "%~3" /f >nul 2>&1
    echo %YELLOW%Registry value %~3 removed%RESET%
)
call :log "Registry Action: %~3 %~4"
pause
exit /b

:log
echo %date% %time% - %~1 >> "%temp%\tcp_optimizer.log"
exit /b