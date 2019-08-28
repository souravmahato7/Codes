##################################################################
#Author: Sourav Mahato
#Created Date:08/26/2019
#Purpose: Script for Quality Check for SCOM database movement
#How to run: PS C:\Script> .\QCForSCOMDatabaseMovement.ps1 -OldSQLServerOpsDB SCSMSQL2016 -SQLServerOpsDB SQL2016 -OldSQLServerOpsDW SCSMSQL2016 -SQLServerOpsDW SQL2016 -OpsMgrDB OperationsManager -OpsMgrDW OperationsManagerDW
##################################################################
###### Function for SQL Query
#######################################################################

param([String] $OldSQLServerOpsDB,$SQLServerOpsDB, $OldSQLServerOpsDW, $SQLServerOpsDW, $OpsMgrDB, $OpsMgrDW )

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

#######################################################################
### FUNCTION FOR TO check the SQL Server Name for OperationsManager database 
#######################################################################

function Get-SQLServerOpsDB ($MS)
{
	#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup\DatabaseagentName
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup"
	$regValue = "DatabaseServerName"
	
	$regprov = [wmiclass]"\\$MS\root\default:stdRegProv"
    $UpdatedRegvalue = $regprov.GetStringValue($hklm,$regPath,$regValue).svalue
	return ($regprov.GetStringValue($hklm,$regPath,$regValue)).svalue
}

#######################################################################
### FUNCTION FOR TO check the SQL Server Name for OperationsManagerDW database 
#######################################################################

function Get-SQLServerOpsDBRegistry ($MS)
{
	#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup\DatabaseagentName
	$hklm = 2147483650
	$regPath = 'SOFTWARE\Microsoft\System Center\2010\Common\Database'
	$regValue = "DatabaseServerName"
	
	$regprov = [wmiclass]"\\$MS\root\default:stdRegProv"
    $UpdatedRegvalue = $regprov.GetStringValue($hklm,$regPath,$regValue).svalue
	return ($regprov.GetStringValue($hklm,$regPath,$regValue)).svalue
}


#######################################################################
### FUNCTION FOR TO check the SQL Server Name for OperationsManagerDW database 
#######################################################################

function Get-SQLServerOpsDW ($ms)
{
	#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup\DatabaseagentName
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup"
	$regValue = "DataWarehouseDBServerName"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetStringValue($hklm,$regPath,$regValue)).svalue
}


#######################################################################
### FUNCTION FOR TO GET OperationsManager Installationpath
#######################################################################

function Get-Installationpath ($MS)
{
	#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup\DatabaseagentName
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup"
	$regValue = "InstallDirectory"
	
	$regprov = [wmiclass]"\\$MS\root\default:stdRegProv"
	return ($regprov.GetStringValue($hklm,$regPath,$regValue)).svalue
}


#######################################################################
# To validate the OperationsManager database Tables as needed
#######################################################################


$ManagementGroup = 'dbo.MT_Microsoft$SystemCenter$ManagementGroup'

$AppMonitoring = 'dbo.MT_Microsoft$SystemCenter$OpsMgrDB$AppMonitoring'

$DataWarehouse = 'dbo.MT_Microsoft$SystemCenter$DataWarehouse'

$DataWarehouse_Log = 'dbo.MT_Microsoft$SystemCenter$DataWarehouse_Log'

$AppMonitoringDW = 'dbo.MT_Microsoft$SystemCenter$DataWarehouse$AppMonitoring'

$AppMonitoringDW_Log = 'dbo.MT_Microsoft$SystemCenter$DataWarehouse$AppMonitoring_Log'

$OpsMgrDWWatcher = 'dbo.MT_Microsoft$SystemCenter$OpsMgrDWWatcher'

$cmd1 = "Select SQLServerName_43FB076F_7970_4C86_6DCA_8BD541F45E3A from $ManagementGroup"
$cmd2 = "Select MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A from $AppMonitoring"
$cmd3 = "Select MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F from $DataWarehouse"
$cmd4 = "Select Post_MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F from $DataWarehouse_Log"
$cmd5 = "Select MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A from $AppMonitoringDW"
$cmd6 = "Select Post_MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A from $AppMonitoringDW_Log"
$cmd7 = "Select DatabaseServerName_69FBB0E2_A6E8_0483_7993_B7AB180A7889 from $OpsMgrDWWatcher"


#######################################################################

Write-Host "Validating the Table $ManagementGroup if the SQL server is updated correctly or not" -ForegroundColor Yellow

Write-Host "
"

$Result1 = Get-SqlTable $SQLServerOpsDB $OpsMgrDB $cmd1

$DBServerName1 = $Result1.SQLServerName_43FB076F_7970_4C86_6DCA_8BD541F45E3A

If ($DBServerName1 -eq $SQLServerOpsDB)

{ Write-Host "Table $ManagementGroup is updated as $DBServerName1" -ForegroundColor Green
Write-Host "
"}

Else

{Write-Host "Table $ManagementGroup is not updated successfully and contains the old SQL server $DBServerName1" -ForegroundColor Red
Write-Host "
"}

#######################################################################

Write-Host "Validating the Table $AppMonitoring if the SQL server is updated correctly or not" -ForegroundColor Yellow
Write-Host "
"

$Result2 = Get-SqlTable $SQLServerOpsDB $OpsMgrDB $cmd2

$DBServerName2 = $Result2.MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A

If ($DBServerName2 -eq $SQLServerOpsDB)

{ Write-Host "Table $AppMonitoring is updated as $DBServerName2" -ForegroundColor Green
Write-Host "
"}

Else

{Write-Host "Table $AppMonitoring is not updated successfully and contains the old SQL server $DBServerName2" -ForegroundColor Red
Write-Host "
"}

#######################################################################

Write-Host "Validating the Table $DataWarehouse if the SQL server is updated correctly or not" -ForegroundColor Yellow
Write-Host "
"

$Result3 = Get-SqlTable $SQLServerOpsDB $OpsMgrDB $cmd3

$DBServerName3 = $Result3.MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F

If ($DBServerName3 -eq $SQLServerOpsDB)

{ Write-Host "Table $DataWarehouse is updated as $DBServerName3" -ForegroundColor Green
Write-Host "
"}

Else

{Write-Host "Table $DataWarehouse is not updated successfully and contains the old SQL server $DBServerName3" -ForegroundColor Red
Write-Host "
"}

#######################################################################

Write-Host "Validating the Table $DataWarehouse_Log if the SQL server is updated correctly or not" -ForegroundColor Yellow
Write-Host "
"

$Result4 = Get-SqlTable $SQLServerOpsDB $OpsMgrDB $cmd4

$DBServerName4 = $Result4.Post_MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F

If ($DBServerName4 -eq $SQLServerOpsDB)

{ Write-Host "Table $DataWarehouse_Log is updated as $DBServerName4" -ForegroundColor Green
Write-Host "
"}

Else

{Write-Host "Table $DataWarehouse_Log is not updated successfully and contains the old SQL server $DBServerName4" -ForegroundColor Red
Write-Host "
"}

#######################################################################

Write-Host "Validating the Table $AppMonitoringDW if the SQL server is updated correctly or not" -ForegroundColor Yellow
Write-Host "
"

$Result5 = Get-SqlTable $SQLServerOpsDB $OpsMgrDB $cmd5

$DBServerName5 = $Result5.MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A

If ($DBServerName5 -eq $SQLServerOpsDB)

{ Write-Host "Table $AppMonitoringDW is updated as $DBServerName5" -ForegroundColor Green
Write-Host "
"}

Else

{Write-Host "Table $AppMonitoringDW is not updated successfully and contains the old SQL server $DBServerName5" -ForegroundColor Red
Write-Host "
"}

#######################################################################

Write-Host "Validating the Table $AppMonitoringDW_Log if the SQL server is updated correctly or not" -ForegroundColor Yellow
Write-Host "
"

$Result6 = Get-SqlTable $SQLServerOpsDB $OpsMgrDB $cmd6

$DBServerName6 = $Result6.Post_MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A

If ($DBServerName6 -eq $SQLServerOpsDB)

{ Write-Host "Table $AppMonitoringDW_Log is updated as $DBServerName6" -ForegroundColor Green
Write-Host "
"}

Else

{Write-Host "Table $AppMonitoringDW_Log is not updated successfully and contains the old SQL server $DBServerName6" -ForegroundColor Red
Write-Host "
"}

#######################################################################

Write-Host "Validating the Table $OpsMgrDWWatcher if the SQL server is updated correctly or not" -ForegroundColor Yellow
Write-Host "
"

$Result7 = Get-SqlTable $SQLServerOpsDB $OpsMgrDB $cmd7

$DBServerName7 = $Result7.DatabaseServerName_69FBB0E2_A6E8_0483_7993_B7AB180A7889

If ($DBServerName7 -eq $SQLServerOpsDB)

{ Write-Host "Table $OpsMgrDWWatcher is updated as $DBServerName7" -ForegroundColor Green
Write-Host "
"}

Else

{Write-Host "Table $OpsMgrDWWatcher is not updated successfully and contains the old SQL server $DBServerName7" -ForegroundColor Red
Write-Host "
"}


#######################################################################
# To validate the OperationsManagerDW database Tables as needed
#######################################################################


Write-Host "Validating the Table dbo.MemberDatabase if the SQL server is updated correctly or not" -ForegroundColor Yellow
Write-Host "
"

$cmd8 = "Select ServerName from dbo.MemberDatabase"

$Result8 = Get-SqlTable $SQLServerOpsDW $OpsMgrDW $cmd8

$DBServerName8 = $Result8.ServerName

If ($DBServerName8 -eq $SQLServerOpsDW)

{ Write-Host "Table dbo.MemberDatabase is updated as $DBServerName8" -ForegroundColor Green
Write-Host "
"}

Else

{Write-Host "Table dbo.MemberDatabase is not updated successfully and contains the old SQL server $DBServerName8" -ForegroundColor Red
Write-Host "
"}

#######################################################################
# To validate the Management Server Registry informations
#######################################################################

Import-Module OperationsManager

$ManagementServers = Get-SCOMManagementServer | ? {$_.IsGateway -eq $False}

$MSs = $ManagementServers.Displayname

Foreach ($MS in $MSs)

{

Write-Host "Validating for Management Server $MS if the Registry value for DatabaseServerName and DataWarehouseDBServerName are updated correctly or not" -ForegroundColor Yellow
Write-Host "
"

    $CurrentSQLServerOpsDB = Get-SQLServerOpsDB $MS

    $CurrentSQLServerOpsDW = Get-SQLServerOpsDW $MS

    $CurrentOpsDBRegistry = Get-SQLServerOpsDBRegistry $MS

    If ($CurrentSQLServerOpsDB -eq $SQLServerOpsDB)

    {
        Write-Host "For Management Server $MS, Registry value for DatabaseServerName is updated correctly with the value as $CurrentSQLServerOpsDB in the path [SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup]" -ForegroundColor Green
        Write-Host "
"

    }

    Else

    {
    
        Write-Host "For Management Server $MS, Registry value for DatabaseServerName is not updated correctly with the value as $CurrentSQLServerOpsDB in the path [SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup]" -ForegroundColor Red
        Write-Host "
"

    }

    If ($CurrentSQLServerOpsDW -eq $SQLServerOpsDW)

    {
        Write-Host "For Management Server $MS, Registry value for DataWarehouseDBServerName is updated correctly with the value as $CurrentSQLServerOpsDW in the path [SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup]" -ForegroundColor Green
        Write-Host "
"

    }

    Else

    {
    
        Write-Host "For Management Server $MS, Registry value for DataWarehouseDBServerName is updated correctly with the value as $CurrentSQLServerOpsDW in the path [SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup]" -ForegroundColor Red
        Write-Host "
"
    }


    If ($CurrentOpsDBRegistry -eq $SQLServerOpsDB)

    {
        Write-Host "For Management Server $MS, Registry value for DatabaseServerName is updated correctly with the value as $CurrentOpsDBRegistry in the path [SOFTWARE\Microsoft\System Center\2010\Common\Database]" -ForegroundColor Green
        Write-Host "
"
    }

    Else

    {    
        Write-Host "For Management Server $MS, Registry value for DatabaseServerName is not updated correctly with the value as $CurrentOpsDBRegistry in the path [SOFTWARE\Microsoft\System Center\2010\Common\Database]" -ForegroundColor Red
        Write-Host "
"
    }

#######################################################################
# To validate the Management Server config file informations
#######################################################################

Write-Host "Validating if Config file is updated or not for Management Server $MS" -ForegroundColor Yellow
Write-Host "
"

$FullPath = Get-Installationpath $MS
$Split = $FullPath.split(':')
$Drive = $Split[0]
$Path = $SPlit[1]

$ConfigFIlepath = "\\$MS\$Drive$" + $Path

$ConfigFIle = "$ConfigFIlepath\ConfigService.config"

#$SQLServerOpsDB = 'sql2016'
$B ='"'+"$SQLServerOpsDB"+'"'
$C = $B
$CurrentSQLServerOpsDB = "Value=$C"


#$ConfigInfo = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern "$SQLServerOpsDB"

$ConfigInfo = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern 'Setting Name="ServerName" Value='


if ($ConfigInfo -match "$CurrentSQLServerOpsDB")

    {

        Write-Host "Config file is updated as $ConfigInfo for Management Server $MS" -ForegroundColor Green
        Write-Host "
"
        
    }

else
        
    {
    
        Write-Host "Config file is not updated as $ConfigInfo for Management Server $MS" -ForegroundColor Red
        Write-Host "
"
    
    }

}


<#######################################################################
# To Update the CLR Update
#######################################################################

$CLRUpdate = "sp_configure 'show advanced options', 1;
 GO
 RECONFIGURE;
 GO
 sp_configure 'clr enabled', 1;
 GO
 RECONFIGURE;
 GO"
Get-SqlTable $SQLServerOpsDB $OpsMgrDB $CLRUpdate#>


#######################################################################
# To Validate the SQL Broker Service
#######################################################################

Write-Host "Validating if SQL broker service is enable or not" -ForegroundColor Yellow
Write-Host "
"

$cmd9 = "SELECT is_broker_enabled FROM sys.databases WHERE name='$OpsMgrDB'"

$Result9 = Get-SqlTable $SQLServerOpsDB $OpsMgrDB $cmd9

$Result9.is_broker_enabled

If ($Result9.is_broker_enabled -eq '1')

{ Write-Host "SQL broker service is enabled" -ForegroundColor Green
Write-Host "
"}

Else

{Write-Host "SQL broker service is not enabled" -ForegroundColor Red
Write-Host "
"}