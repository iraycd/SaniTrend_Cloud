:: Starts Node-Red so that it creates the .node-red directory 
start cmd /C node-red
ECHO.
ECHO.
ECHO. Waiting for Node-Red to complete startup...
TIMEOUT /T 20 /NOBREAK
:: Kill node-red so files can be replaced.
taskkill /f /im "node.exe"
CD /d %HOMEDRIVE%\Users\%USERNAME%\.node-red
ECHO.
ECHO.
ECHO Installing PLC communications...
ECHO.
ECHO.
call npm install  --no-audit --no-update-notifier --no-fund --save node-red-contrib-cip-ethernet-ip
ECHO. 
ECHO.
ECHO PLC communications installation complete.
ECHO.
ECHO.
ECHO Installing SQLite database support...
ECHO. 
ECHO.
call npm install  --no-audit --no-update-notifier --no-fund --save node-red-node-sqlite
ECHO. 
ECHO.
ECHO SQLite database support installation complete.
ECHO.
ECHO.
ECHO Installing CPU diagnostics...
ECHO. 
ECHO.
call npm install  --no-audit --no-update-notifier --no-fund --save node-red-contrib-cpu
ECHO. 
ECHO.
ECHO CPU diagnostics installation complete.
ECHO.
ECHO.
ECHO Installing Operating System diagnostics...
ECHO. 
ECHO.
call npm install  --no-audit --no-update-notifier --no-fund --save node-red-contrib-os
ECHO. 
ECHO.
ECHO Operating System diagnostics installation complete.
ECHO.
ECHO.
ECHO. 
ECHO. 
ECHO ******************************************************
ECHO. 
ECHO SaniTrend Cloud dependencies installation complete.
ECHO. 
ECHO ******************************************************
ECHO.  
ECHO.
ECHO Copying configuration files...
ECHO.
ECHO.
COPY  %~dp0\flows.json %HOMEDRIVE%\Users\%USERNAME%\.node-red\flows.json /Y
COPY  %~dp0\settings.js %HOMEDRIVE%\Users\%USERNAME%\.node-red\settings.js /Y
ECHO.
ECHO.
ECHO.
ECHO Creating scheduled task to automatically start Node-Red...
ECHO.
ECHO. 
PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0\Scheduled_Task.ps1""' -Verb RunAs}"