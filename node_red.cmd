:: Starts Node-Red so that it creates the .node-red directory 
start cmd /C node-red
ECHO.
ECHO.
ECHO. Waiting for Node-Red to complete startup...
TIMEOUT /T 20 /NOBREAK
:: Kill node-red so files can be replaced.
taskkill /f /im "node.exe"
start powershell -file %~dp0\npm_modules.ps1