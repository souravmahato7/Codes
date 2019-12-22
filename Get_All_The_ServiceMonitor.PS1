##################################################################

#Author: Sourav Mahato

#Created Date:08/26/2019

#Modified Date:12/22/2019

#Purpose: Script for get all the service Monitor in SCOM

#How to run: You just need to run it from SCOM Management Server

##################################################################

Import-Module OperationsManager

$Monitors = Get-SCOMMonitor | ? {$_.XmlTag -like 'UnitMonitor'}

$Classes = Get-SCOMClass

foreach ($Monitor in $Monitors)

{

$Configurations = $Monitor.configuration

$Configuration = $Configurations | Select -First 1

$MonitorTargetID = $Monitor.Target.Id

$Monitorname = $Monitor.DisplayName

$Class = $Classes | ? {$_.ID -like $MonitorTargetID}

$TargetName = $Class.DisplayName

$ServiceNameword = $Configuration | ? {$_ -like '*ServiceName*'}

If ($ServiceNameword)

{
 
 $CheckStartupType = $Configuration | ? {$_ -like '*CheckStartupType*'}

 If ($CheckStartupType)
 {

    $Config = $Configuration.split("<")
    $count = $Config.Count
    $config1 = $Config[$count-4]
    $ServiceName = $Config1.split(">")

    $ServiceName2 = $ServiceName[1]

    if ($ServiceName2)

    {

    Write-Host "Monitor '"$Monitor.displayname"' is having the service value as '$ServiceName2'" -ForegroundColor Green

    "$Monitorname, $Configuration, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output.csv"

    }

    Else

        {
  
        $CheckStartupType1 = $Configuration | ? {$_ -like '*</ServiceName><CheckStartupType/>*'}

        If ($CheckStartupType1)
        {

        $Config = $Configuration.split("<")
        $count = $Config.Count
        $config1 = $Config[$count-3]
        $ServiceName = $Config1.split(">")

        $ServiceName2 = $ServiceName[1]

        if ($ServiceName2)

            {

            Write-Host "Monitor '"$Monitor.displayname"' is having the service value as '$ServiceName2'" -ForegroundColor Green

            "$Monitorname, $Configuration, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output.csv"

            }

        Else
            {


            Write-Host "Monitor '"$monitor.displayname"' doesn't have any service Monitor configured" -ForegroundColor Yellow
            "$Monitorname, $Configuration, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output_not.csv"

            }
        }


        Else

        { 


            $Config = $Configuration.split("<")
            $count = $Config.Count
            $config1 = $Config[$count-2]
            $ServiceName = $Config1.split(">")

            $ServiceName2 = $ServiceName[1]

            if ($ServiceName2)

                {

                Write-Host "Monitor '"$Monitor.displayname"' is having the service value as '$ServiceName2'" -ForegroundColor Green

                "$Monitorname, $Configuration, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output.csv"


                }

            Else

            { 

            Write-Host "Monitor '"$monitor.displayname"' doesn't have any service Monitor configured line 97" -ForegroundColor Yellow
            "$Monitorname, $Configuration, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output_not.csv"

            }


        }
    }

 }

Else

 {

 If ($Configuration -like '*KHI*')
 
  { 

    $Config = $Configuration.split("<")
    $count = $Config.Count
    $config1 = $Config[$count-2]
    $ServiceName =$Config1.split(">") 
    $ServiceName2 = $ServiceName[1] 
    if ($ServiceName2) 

    { 
    Write-Host "Monitor '"$Monitor.displayname"' is having the service value as '$ServiceName2'" -ForegroundColor Green

    "$Monitorname, $Configuration, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output.csv"
    } 

    Else 

    { 

    Write-Host "Monitor '"$monitor.displayname"' is not a service Monitor" -ForegroundColor Yellow
    "$Monitorname, $Configuration, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output_not.csv"
    }

  }

  else
  {
    $Config = $Configuration.split("<") 
    $ServiceName =$Config[3].split(">") 
    $ServiceName2 = $ServiceName[1] 
    if ($ServiceName2) 

    { 
    Write-Host "Monitor '"$Monitor.displayname"' is having the service value as '$ServiceName2'" -ForegroundColor Green

    "$Monitorname, $Configuration, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output.csv"
    } 

    Else 

    { 

    Write-Host "Monitor '"$monitor.displayname"' is not a service Monitor" -ForegroundColor Yellow
    "$Monitorname, $Configuration, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output_not.csv"
    }

  }
 }
}

Else

{ 

Write-Host "Monitor '"$monitor.displayname"' is not a service Monitor" -ForegroundColor Yellow
"$Monitorname, $Configuration, $TargetName, $ServiceName2, $ServiceNameword" >>"C:\Temp\Output_not.csv"

}
}
