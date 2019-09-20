##################################################################

# Author: Sourav Mahato

# Created Date:09/21/2019

<#Purpose: This script will first check if any objects already in maintenance mode in SCOM or not for a server. If any object in
maintenance mode, this script will fetch the information from SCOM and kept it in AlreadyMM.txt file And 
then it will put entire server in maintenance mode. #>

# You need to copy this .PS1 file to a location on your Management Server.

# Now create two text file AlreadyMM.txt" and "Servers.txt" on the same directory.

# Now you can put the servers name one after another in Servers.txt file and execute the Script.

# You need to modify the $minutes = "60" section for how long you want to put the server into maintenance mode

##################################################################

Import-Module OperationsManager

$cur = get-location

Clear-Content "$cur\AlreadyMM.txt"

$Servers = Get-content "$cur\Servers.txt"

$minutes = "60"

$MonitoringObject = Get-SCOMClass -Name "Microsoft.Windows.Computer" | Get-SCOMClassInstance

foreach($Server in $Servers)

{
    
    $ObjectInstance = Get-SCOMClassInstance -Name $Server
    
    $Objects =$ObjectInstance.GetMonitoringRelationshipObjects()
    
    $AllObjects = $Objects.TargetObject
    
    $alreadyinmm = $AllObjects | ? {$_.InMaintenanceMode -eq $true}
    
    $alreadyinmm.Id.Guid >>"$cur\AlreadyMM.txt"
    
    $Object = $MonitoringObject | where {$_.displayname -like "$Server"}
    
    $startTime = [System.DateTime]::Now
    
    $endTime = $startTime.AddMinutes($minutes)
    
    if($Object.InMaintenanceMode -eq $false)
    
    {
    
     Write-Host "Putting $Object.Displayname into maintenance mode for $endTime Minutes" -ForegroundColor Yellow
    
     Start-SCOMMaintenanceMode -Instance $Object -EndTime:$EndTime -Reason: "PlannedOther" -Comment: "scheduled Activity - daily Reboot"
    
    }
    
    else 
    
    {
    
     Write-Host "Server $Object.Displayname is already into maintenance mode" -ForegroundColor Green
    
    }

}
