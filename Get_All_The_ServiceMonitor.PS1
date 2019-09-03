##################################################################

#Author: Sourav Mahato

#Created Date:08/26/2019

#Modified Date:None

#Purpose: Script for get all the service Monitor in SCOM

#How to run: You just need to run it from SCOM Management Server

##################################################################

Import-Module OperationsManager

$Monitors = Get-SCOMMonitor  | ? {$_.XmlTag -like 'UnitMonitor'}

$Classes = Get-SCOMClass

foreach ($Monitor in $Monitors)

{

    $Configuration = $Monitor.configuration

    $MonitorTargetID = $Monitor.Target.Id

    $Monitorname = $Monitor.DisplayName

    $Class = $Classes | ? {$_.ID -like $MonitorTargetID}

    $TargetName = $Class.DisplayName

    $ServiceNameword = $Configuration | ? {$_ -like '*ServiceName*'}

    If ($ServiceNameword)

    {
        $Config = $Configuration.split("<")
        
        $ServiceName =$Config[3].split(">")
        
        $ServiceName2 = $ServiceName[1]

        if ($ServiceName2)

        {

               Write-Host "Monitor '"$Monitor.displayname"' is having the service value as '$ServiceName2'" -ForegroundColor Green

               "$Monitorname, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output.csv"

        }

        Else

        { 
    
               Write-Host "Monitor '"$monitor.displayname"' doesn't have any service Monitor configured" -ForegroundColor Yellow

        }
  
    }

    Else

    { 
    
        Write-Host "Monitor '"$monitor.displayname"'  is not a service Monitor" -ForegroundColor Yellow
        
    }

}
