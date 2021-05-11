# Installer for SaniTrend Cloud Watchdog 
#
# 2021-05-04 - Matt Sienkowski   matt.sienkowski@sanimatic.com 

Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host " ____              _ _____                   _    ____ _                 _ "
Write-Host "/ ___|  __ _ _ __ (_)_   _|___ ___ _ __   __| |  / ___| | ___  _   _  __| |"
Write-Host "\___ \ / _  |  _ \| | | ||  __/ _ \  _ \ / _  | | |   | |/ _ \| | | |/ _  |"
Write-Host " ___) | (_| | | | | | | || | |  __/ | | | (_| | | |___| | (_) | |_| | (_| |"
Write-Host "|____/ \__,_|_| |_|_| |_||_|  \___|_| |_|\__,_|  \____|_|\___/ \__,_|\__,_|"
Write-Host ""
Write-Host ""
Write-Host ""
$wshell = New-Object -ComObject Wscript.Shell
$answer = $wshell.Popup("Do you want to install SaniTrend Cloud?",0,"SaniTrend Cloud Installer",64+4)

if ($answer -eq 6) {

    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "Downloading Node.js"
    Write-Host ""
    Write-Host ""
    # Download Node.JS
    wget https://nodejs.org/dist/v14.16.1/node-v14.16.1-x64.msi -outfile  "node-v14.16.1-x64.msi"   
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "Installing Node.js"
    Write-Host ""
    Write-Host ""
    Write-Host ""
    # Install Node.Js
    Start-Process "$pwd\node-v14.16.1-x64.msi" -wait

    Start-Process $pwd\node_red.cmd


} else {
    
    Exit

}

Exit