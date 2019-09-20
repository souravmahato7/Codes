##################################################################

# Author: Sourav Mahato

# Created Date:09/21/2019

<#Purpose: This script will first check if the server is in maintenance mode or not. If the server is in maintenance mode, 
it will remove the server from maintenance mode and restore the maintenance mode for the objects which were previously in 
maintenance mode in SCOM. Also, if the maintenance mode is already ended by the maintenance schedule, it will restore the 
maintenance mode for the objects which were previously in maintenance mode in SCOM. #>

# You need to copy this .PS1 file to a location on your Management Server.

# Now create two text file AlreadyMM.txt" and "Servers.txt" on the same directory.

# Now you can put the servers name one after another in Servers.txt file and execute the Script.

# You need to modify the $minutes = "60" section for how long you want to put the server into maintenance mode

##################################################################

Import-Module OperationsManager

$cur = get-location

$Servers = Get-content "$cur\Servers.txt"

$minutes = "518400"

$time = [DateTime]::Now

$alreadyinmmformember = Get-Content "$Cur\AlreadyMM.txt"

$MonitoringObject = Get-SCOMClass -Name "Microsoft.Windows.Computer" | Get-SCOMClassInstance

foreach($member in $Servers)

{
   $Object = $MonitoringObject | where {$_.displayname -like "$member"}
   
   if($Object.InMaintenanceMode -eq $True)        
    
    {
    
      Write-Host "stopping maintenance for $member" -ForegroundColor Green
	  
      $Object.StopMaintenanceMode([DateTime]::Now.ToUniversalTime(),[Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive)
      
      foreach($ID in $alreadyinmmformember)        
      
      {
      
         $Instance = get-scommonitoringobject -ID $ID
      
         Write-Host "restoring maintenance mode for $($Instance.DisplayName) on $($Instance.Path) to $($minutes) Minutes" -ForegroundColor Yellow
         
         Start-SCOMMaintenanceMode -instance $Instance -endtime $time.addMinutes($minutes)  
         
      }


     }
     
    Else
    
     {
    
       foreach($ID in $alreadyinmmformember)            
    
        {
    
          $Instance = get-scommonitoringobject -ID $ID
     
            Write-Host "restoring maintenance mode for $($Instance.DisplayName) on $($Instance.Path) to $($minutes) Minutes" -ForegroundColor Yellow
     
            Start-SCOMMaintenanceMode -instance $Instance -endtime $time.addMinutes($minutes)
     
        }
  
     }

  }
