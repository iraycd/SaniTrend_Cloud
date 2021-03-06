# $task = Get-ScheduledTask "SaniTrend_Cloud"
# $task.Settings.ExecutionTimeLimit = "PT0S"
# $task.Password = "$0PhIe12271205"
# Set-ScheduledTask $task
# $task.Principal


#Create the here-string for the local script
# $myScheduledTaskScript = @"
#     Write-Output "Hello World"
# "@


Add-Type -AssemblyName PresentationCore,PresentationFramework
$msgBody = "In the login box, enter the current username and password.  This will create a scheduled task to run Node-Red under the current user account."
[System.Windows.MessageBox]::Show($msgBody,"Important!", 0,48)


#Create Scheduled Task variables
$remoteCredentials = Get-Credential
$scriptName = "node-red.cmd"
$scriptPath = "$env:HomeDrive\Users\$env:UserName\AppData\Roaming\npm"
$taskName = "SaniTrend Cloud"
$taskPath = "SaniMatic"
$taskDescription = "SaniTrend Cloud Data Collection"
$taskUser = $remoteCredentials.UserName
$securePassword = $remoteCredentials.Password

#Due to the 'Register-ScheduledTask' cmdlet not accepting 'SecureString' as an input for password, we need to create a new credential object and use this to lookup the plaintext password.
#This is still better than having the plaintext password directly in the script, however, this is obviously less than ideal but sadly we have little choice.
$taskCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $taskUser, $securePassword
$taskPassword = $taskCredentials.GetNetworkCredential().Password



#Check the Script Path directory exists, and create it if not
# if (!(Test-Path $scriptPath)) {
#     New-Item -Path $scriptPath -ItemType Directory
# }

# #Create the local PowerShell Script for the Scheduled Task from the here-string created above
# Set-Content -Path "$scriptPath\$scriptName" -Value $patchServerScript

# #If the Operating System version is Windows Server 2012 R2 or higher, then use the native Scheduled Task cmdlets, otherwise, use a COM object
# if ($osVersion -ge 6.3) {
#     #Define the actions of the Scheduled Task
#     $taskActions = New-ScheduledTaskAction -Execute "$scriptPath\$scriptName" 

#     #Define the trigger for the Scheduled Task
#     $taskTrigger = New-ScheduledTaskTrigger -AtStartup

#     #Define the settings of the Scheduled Task
#     $taskSettings = New-ScheduledTaskSettingsSet -Compatibility Win7 -RunOnlyIfNetworkAvailable -ExecutionTimeLimit "PT0S"
    
#     #Check for an existing instance of the Scheduled Task, if found, delete it
#     Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue | Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    
#     #Register the Scheduled Task using the actions and settings defined above
#     #Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Description $taskDescription -Action $taskActions -Trigger $taskTrigger -Settings $taskSettings -User $taskUser -Password $taskPassword -RunLevel Highest
    
#     #Register the Scheduled Task using the action, trigger and settings defined above
#     #Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Action $taskAction -Settings $taskSettings -Trigger $taskTrigger -User $taskUser -Password $taskPassword -RunLevel Highest

#     #Execute the Scheduled Task
#     Start-ScheduledTask -TaskName $taskName -TaskPath $taskPath
    
#     #Check the Scheduled Task state to see when it finishes running
#     $taskState = Get-ScheduledTask -TaskName $taskName
#     while ($($taskState.State) -eq "Running") {
#         Start-Sleep -Seconds 10
#         $taskState = Get-ScheduledTask -TaskName $taskName
#     }
        
#     #Get the Scheduled Task result details
#     $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName -TaskPath $taskPath
#     if ($($taskInfo.LastTaskResult) -ne "0") {
#         Write-Warning "An error occured while attempting to run the Scheduled Task. Last run result code was: '$($taskInfo.LastTaskResult)'"
#     }
#     else {
#         Write-Verbose "Scheduled Task execution completed successfully"
#     }
    
#     #Clean-up the Scheduled Task and the related PowerShell Script File
#     Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
#     Remove-Item -Path "$scriptPath\$scriptName"
# }
# else {
    #Create the local Task Scheduler COM object
    $taskScheduler = New-Object -ComObject Schedule.Service
    $taskScheduler.Connect()

    #Create a new Scheduled Task definition instance
    $taskDefinition = $taskScheduler.NewTask(0)

    #Define the actions of the Scheduled Task
    $taskActions = $taskDefinition.Actions.Create(0)
    $taskActions.Path = "$scriptPath\$scriptName"
    $taskActions.Arguments = ""

    #Define the trigger for the Scheduled Task
    $taskTrigger = $taskDefinition.Triggers.Create(8)
    $taskTrigger.Enabled = $true
    #Start boundary '2018-02-11T12:00:00-08:00' equals "11th February 2018 at midday in UTC/GMT time zone" (See MSDN for full details; https://msdn.microsoft.com/en-us/library/windows/desktop/aa383967(v=vs.85).aspx)
    $taskTrigger.StartBoundary = "2018-02-11T12:00:00+00:00"
    
    
    #Define the settings of the Scheduled Task
    $taskSettings = $taskDefinition.Settings
    #Compatability '3' eqauls "Windows 7, Windows Server 2008 R2" (See MSDN for full details; https://msdn.microsoft.com/en-us/library/windows/desktop/aa383486(v=vs.85).aspx)
    $taskSettings.Compatibility = 3
    #Execution time limit 'PT8H' equals "08:00:00" hours (See MSDN for full details; https://msdn.microsoft.com/en-us/library/windows/desktop/aa383497(v=vs.85).aspx)
    $taskSettings.ExecutionTimeLimit = "PT0S"
    $taskSettings.RunOnlyIfNetworkAvailable = $true
    $taskSettings.RestartInterval = "PT2M"
    $taskSettings.RestartCount = 9999
    
    #Define the registration info of the Scheduled Task
    $taskRegistration = $taskDefinition.RegistrationInfo
    $taskRegistration.Description = $taskDescription

    #Define the run as privileges for the Scheduled Task
    $taskPrincipal = $taskDefinition.Principal
    #Run level '1' equals "Run with highest privileges" (See MSDN for full details; https://msdn.microsoft.com/en-us/library/windows/desktop/aa382076(v=vs.85).aspx)
    $taskPrincipal.RunLevel = 0
        
    #Get or create the Scheduled Task folder
    try {
        $taskFolder = $taskScheduler.GetFolder($taskPath)
    }
    catch {
        $taskRoot = $taskScheduler.GetFolder("\")
        $taskFolder = $taskRoot.CreateFolder($taskPath)
    }

    #Check for an existing instance of the Scheduled Task, if found, delete it
    try {
        $taskFolder.DeleteTask($taskName, 0)
    }
    catch {
        #Scheduled Task doesn't already exist, so we don't need to do anything 
    }
    
    #Register the Scheduled Task using the actions and settings defined above
    $taskFolder.RegisterTaskDefinition($taskName, $taskDefinition, 2, $taskUser, $taskPassword, 1)

    #Execute the Scheduled Task
    $taskRun = $taskFolder.GetTask($taskName)
    $taskRun.Run(0)


    $msgBody = "SaniTrend Cloud installation complete."
    [System.Windows.MessageBox]::Show($msgBody,"Installation Complete", 0,0)
    
    # #Sleep for 10 seconds to ensure the Scheduled Task has time to start running before we check it's status (COM objects seem to take longer to register and execute than when using the native cmdlets)
    # Start-Sleep -Seconds 10

    # #Check the Scheduled Task state to see when it finishes running
    # $taskState = $taskFolder.GetTask($taskName)
    # #Task state '0' equals "Unknown", task state '2' equals "Queued", task state '4' equals "Running" (See MSDN for full details; https://msdn.microsoft.com/en-us/library/windows/desktop/aa446865(v=vs.85).aspx)
    # while (($($taskState.State) -eq 0) -or ($($taskState.State) -eq 2) -or ($($taskState.State) -eq 4)) {
    #     Start-Sleep -Seconds 10
    #     $taskState = $taskFolder.GetTask($taskName)
    # }

    #Get the Scheduled Task result details
    # $taskInfo = $taskFolder.GetTask($taskName)
    # if ($($taskInfo.LastTaskResult) -ne 0) {
    #     Write-Warning "An error occured while attempting to run the Scheduled Task. Last run result code was: '$($taskInfo.LastTaskResult)'"
    # }
    # else {
    #     Write-Verbose "Scheduled Task execution completed successfully"
    # }

    # #Clean-up the Scheduled Task and the related PowerShell Script File
    # $taskFolder.DeleteTask($taskName, 0)
    # Remove-Item -Path "$scriptPath\$scriptName"
# }