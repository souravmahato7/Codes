##################################################################
#Author: Sourav Mahato
#Created Date:09/25/2019
#Purpose: Script for grooming the data for Orchestrator database

# Please save the Script in the following location: C:\Software

# Also please donwload the module SCOrchestratorManagement.psm1 and kept it in the following location: C:\Software

# https://gallery.technet.microsoft.com/scriptcenter/SCOrchestratorManagementpsm-5c16093f

#How to run: .\Runbooks.PS1 -MS SCORCHRB.Domain.COM -SQLServer SQLServername -SQLDB SQLDAtabaseName
##################################################################
###### Function for SQL Query
#######################################################################

param([String] $MS,$SQLServer, $SQLDB)

Function Get-SQLTable($strSQLServer, $strSQLDatabase, $strSQLCommand, $intSQLTimeout = 3000)
{	
	trap [System.Exception]
	{
		Write-Host "Exception trapped, $($_.Exception.Message)"
		Write-Host "SQL Command Failed.  Sql Server [$strSQLServer], Sql Database [$strSQLDatabase], Sql Command [$strSQLCommand]."
		continue;
	}
	
	#build SQL Server connect string
	$strSQLConnect = "Server=$strSQLServer;Database=$strSQLDatabase;Integrated Security=True;Connection Timeout=$intSQLTimeout" 
	
	#connect to server and recieve dataset
	$objSQLConnection = New-Object System.Data.SQLClient.SQLConnection
	$objSQLConnection.ConnectionString =  $strSQLConnect
	$objSQLCmd = New-Object System.Data.SQLClient.SQLCommand
	$objSQLCmd.CommandTimeout = $intSQLTimeout
	$objSQLCmd.CommandText = $strSQLCommand
	$objSQLCmd.Connection = $objSQLConnection
	$objSQLAdapter = New-Object System.Data.SQLClient.SQLDataAdapter
	$objSQLAdapter.SelectCommand = $objSQLCmd
	$objDataSet = New-Object System.Data.DataSet
	$strRowCount = $objSQLAdapter.Fill($objDataSet)
	
	If ($?)
	{
		#pull out table
		$objTable = $objDataSet.tables[0]
	}
	
	#close the SQL connection
	$objSQLConnection.Close()
	
	#return array of values to caller	
	return $objTable
}




####################################################################################################
#
# Saving the Information about the Runbooks which are in running state in Orchestrator
#
####################################################################################################

Write-Host "Saving the Information about the Runbooks which are in running state in Orchestrator" -ForegroundColor Yellow

$RunbooksInfo = "Select RB.Name, RT.RunbookId, RB.Path, RT.Id, RT.RunbookServerId, A.Computer , RT.Status, RT.Parameters, RT.LastModifiedTime, RT.LastModifiedBy from 

[Microsoft.SystemCenter.Orchestrator.Runtime].[Jobs] as RT

inner join [Orchestrator].[Microsoft.SystemCenter.Orchestrator].[Runbooks] RB on RB.Id= RT.RunbookId 

inner join ACTIONSERVERS A on A.UniqueID = RT.RunbookServerId

where Status = 'Running'

order by RT.CreationTime desc"

$RBResult = Get-SqlTable $SQLServer $SQLDB $RunbooksInfo

$RBResult.RunbookID.guid


####################################################################################################
#
# Get the Information about the RunbookServer and Stop the Runbook service
#
####################################################################################################

Write-Host "We will now stop the Runbook service on Runbook servers" -ForegroundColor Yellow

$RunbookServers = "Select * from ACTIONSERVERS"

$RBSResult = Get-SqlTable $SQLServer $SQLDB $RunbookServers

$RBSResult.Computer

Foreach ($RS in $RBSResult.Computer)

{

            $status = "Running"

            $ServicetoStart= Get-Wmiobject -Class win32_service -computer $RS -filter "name = 'orunbook'"
               
            if ($ServicetoStart.state -eq $status)

            {
                Write-Host "Runbook Service is in Running State on Runbook Server $RS, Stopped the Service" -ForegroundColor Yellow

                (Get-Wmiobject -Class win32_service -computer $RS -filter "name = 'orunbook'").InvokeMethod("StopService",$null)

                Start-Sleep -Seconds 30

                Write-Host "Stopped the Runbook service on $RS" -ForegroundColor Green    
            }

}


####################################################################################################
#
# Execute below SQL queries to clean tables (Policyinstances, Objectinstances, Objectinstancedata, Events, Policy_publish_queue)
#
####################################################################################################

Write-Host "Now we will clean tables (Policyinstances, Objectinstances, Objectinstancedata, Events, Policy_publish_queue)" -ForegroundColor Yellow

$DeleteEvent = "DELETE FROM POLICY_PUBLISH_QUEUE
TRUNCATE TABLE EVENTS
TRUNCATE TABLE OBJECTINSTANCEDATA
TRUNCATE TABLE OBJECTINSTANCES
DELETE FROM POLICYINSTANCES"

Get-SqlTable $SQLServer $SQLDB $DeleteEvent


####################################################################################################
#
# to take a note of all the policies for which logging is enabled
#
####################################################################################################

Write-Host "Get the Information about the RunbookServer and Stop the Runbook service" -ForegroundColor Yellow

$LogCommonDatas = "Select * from POLICIES where LogCommonData = 1"

$LogCommonData = Get-SqlTable $SQLServer $SQLDB $LogCommonDatas

$LogCommonData.UniqueID

$LogSpecificDatas = "Select * from POLICIES where LogSpecificData = 1"

$LogSpecificData = Get-SqlTable $SQLServer $SQLDB $LogSpecificDatas

$LogSpecificData.UniqueID

####################################################################################################
#
#  Query to disable the logging
#
####################################################################################################

Write-Host "Now disabling Logging for all Runbooks" -ForegroundColor Yellow

$cmd1 = "update POLICIES set LogCommonData = 0 where LogCommonData = 1"

Get-SqlTable $SQLServer $SQLDB $cmd1

$cmd2 = "update POLICIES set LogSpecificData = 0 where LogSpecificData = 1"

Get-SqlTable $SQLServer $SQLDB $cmd2


####################################################################################################
#
# Now stopping all running runbooks
#
####################################################################################################

Write-Host "Now stopping all running runbooks" -ForegroundColor Yellow

$cmd3 = "DECLARE @JobId UNIQUEIDENTIFIER

DECLARE job_cursor CURSOR FOR

SELECT Id FROM [Microsoft.SystemCenter.Orchestrator.Runtime.Internal].Jobs

WHERE StatusId < 2

OPEN job_cursor

FETCH NEXT FROM job_cursor INTO @JobId 

WHILE @@FETCH_STATUS = 0

BEGIN

EXEC [Microsoft.SystemCenter.Orchestrator.Runtime].CancelJob @JobId, 'S-1-5-500'

FETCH NEXT FROM job_cursor INTO @JobId

END

CLOSE job_cursor

DEALLOCATE job_cursor"


Get-SqlTable $SQLServer $SQLDB $cmd3


####################################################################################################
#
# Now clearing all the orphaned runbook instances
#
####################################################################################################

Write-Host "Now clearing all the orphaned runbook instances" -ForegroundColor Yellow

Get-SqlTable $SQLServer $SQLDB "exec [Microsoft.SystemCenter.Orchestrator.Runtime.Internal].[ClearOrphanedRunbookInstances]"


####################################################################################################
#
# Now we will do log purging
#
####################################################################################################

Write-Host "Now we will do log purging" -ForegroundColor Yellow

$cmd4 = "DECLARE @Completed bit

SET @Completed = 0

WHILE @Completed = 0 EXEC sp_CustomLogCleanup @Completed OUTPUT, @FilterType=1,@XEntries=0"

Get-SqlTable $SQLServer $SQLDB $cmd4


####################################################################################################
#
# Now executing maintenance operations
#
####################################################################################################

Write-Host "Now executing maintenance operations" -ForegroundColor Yellow

Get-SqlTable $SQLServer $SQLDB "ALTER QUEUE [Microsoft.SystemCenter.Orchestrator.Maintenance].MaintenanceServiceQueue WITH STATUS = ON"

Get-SqlTable $SQLServer $SQLDB "TRUNCATE TABLE [Microsoft.SystemCenter.Orchestrator.Internal].AuthorizationCache"

Get-SqlTable $SQLServer $SQLDB "EXEC [Microsoft.SystemCenter.Orchestrator.Maintenance].[EnqueueRecurrentTask] @taskName = 'Statistics'"

Get-SqlTable $SQLServer $SQLDB "EXEC [Microsoft.SystemCenter.Orchestrator.Maintenance].[EnqueueRecurrentTask] @taskName = 'Authorization'"

Get-SqlTable $SQLServer $SQLDB "EXEC [Microsoft.SystemCenter.Orchestrator.Maintenance].[EnqueueRecurrentTask] @taskName = 'ClearAuthorizationCache'"


$cmd5 = "SELECT 

[m].[Name], 

[m].[IsEnabled], 

[m].[IntervalInSeconds], 

[m].[LastExecutionTime] 

FROM [Orchestrator].[Microsoft.SystemCenter.Orchestrator.Maintenance].[MaintenanceTasks] [m]"


$Output = Get-SqlTable $SQLServer $SQLDB $cmd5

$Output.LastExecutionTime

####################################################################################################
#
# Now Enable the logging which were disabled earlier
#
####################################################################################################

Write-Host "Now Enable the logging which were disabled earlier" -ForegroundColor Green

foreach ($LCD in $LogCommonData.UniqueID)

{

Write-Host "Working on $LCD" -ForegroundColor Yellow

    Get-SqlTable $SQLServer $SQLDB "update POLICIES set LogCommonData = 1 where UniqueID = '$LCD'"

}


foreach ($LSD in $LogSpecificData.UniqueID)

{

Write-Host "Working on $LSD" -ForegroundColor Yellow

    Get-SqlTable $SQLServer $SQLDB "update POLICIES set LogSpecificData = 1 where UniqueID = '$LSD'"

}


####################################################################################################
#
# Now starting the RUnbook service for the Runbook servers
#
####################################################################################################


Write-Host "Now starting the RUnbook service for the Runbook servers" -ForegroundColor Yellow


Foreach ($RS in $RBSResult.Computer)

{
            $status = "stopped"

            $ServicetoStart= Get-Wmiobject -Class win32_service -computer $RS -filter "name = 'orunbook'"
               
            if ($ServicetoStart.state -eq $status)

            {
                Write-Host "Runbook Service is in stopped State on Runbook Server $RS, so we will start the service" -ForegroundColor Yellow

                (Get-Wmiobject -Class win32_service -computer $RS -filter "name = 'orunbook'").InvokeMethod("StartService",$null)

                Start-Sleep -Seconds 30

                Write-Host "started the Runbook service on $RS" -ForegroundColor Green    
            }

}


####################################################################################################
#
# Now starting all the runbooks which were stopped earlier
#
####################################################################################################


Write-Host "Now starting all the runbooks which were stopped earlier" -ForegroundColor Yellow

Import-Module "C:\Software\SCOrchestratorManagement.psm1"

foreach ($RunbookID in $RBResult.RunbookID.guid)

{

    Write-Host "Working on $RunbookID" -ForegroundColor Yellow

    $Runbook = Get-scoRunbook -ManagementServer $MS | ? {$_.ID -match "$RunbookID"}

    If ($Runbook)

    {
      
      Start-scoRunbook -Runbook $Runbook

      Write-Host "Started Runbook $RunbookID successfully" -ForegroundColor Green

    }

}
