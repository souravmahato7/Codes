##################################################################
#Author: Sourav Mahato
#Created Date:08/25/2019
#Purpose: Script for SCOM database movement
#How to run: PS C:\Script> .\QCForSCOMDatabaseMovement.ps1 -OldSQLServerOpsDB SCSMSQL2016 -SQLServerOpsDB SQL2016 -OldSQLServerOpsDW SCSMSQL2016 -SQLServerOpsDW SQL2016 -OpsMgrDB OperationsManager -OpsMgrDW OperationsManagerDW
#Precaution: Beofre running this Script, please make sure that following pre-requsites are in place

#1. Full Backup of SCOM DBs
#2. Restore the databases on new SQL instances
#3. SQL login account should have been created for SDK, Reader, Writer, DAS accunts in New database instance
#4. Local admin rights on Management servers and SA rights on SQL DBs (OperationsManager and OperationsManagerDW)
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
### FUNCTION FOR TO Update the SQL Server Name for OperationsManager Database
#######################################################################

function Update-SQLServerOpsDB ($MS, $SQLServerOpsDB)

{
	#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup\DatabaseagentName
	$hklm = 2147483650
	$regPath1 = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup"
    $regPath2 = 'SOFTWARE\Microsoft\System Center\2010\Common\Database'
	$regValue = "DatabaseServerName"
	
	$regprov = [wmiclass]"\\$MS\root\default:stdRegProv"
	$regprov.GetStringValue($hklm,$regPath1,$regValue).svalue
    $regprov.SetStringValue($hklm,$regPath1,$regValue, $SQLServerOpsDB)
    $regprov.GetStringValue($hklm,$regPath2,$regValue).svalue
    $regprov.SetStringValue($hklm,$regPath2,$regValue, $SQLServerOpsDB)

}


#######################################################################
### FUNCTION FOR TO GET OperationsManager database SQL Server Name
#######################################################################

function Get-SQLServerOpsDB ($MS)
{
	#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup\DatabaseagentName
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup"
	$regValue = "DatabaseServerName"
	
	$regprov = [wmiclass]"\\$MS\root\default:stdRegProv"
	return ($regprov.GetStringValue($hklm,$regPath,$regValue)).svalue
}


#######################################################################
### FUNCTION FOR TO Update the SQL Server Name for OperationsManagerDW Database
#######################################################################

function Update-SQLServerOpsDW ($MS, $SQLServerOpsDW)

{
	#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup\DatabaseagentName
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup"
	$regValue = "DataWarehouseDBServerName"
	
	$regprov = [wmiclass]"\\$MS\root\default:stdRegProv"
	$regprov.GetStringValue($hklm,$regPath,$regValue).svalue
    $regprov.SetStringValue($hklm,$regPath,$regValue, $SQLServerOpsDW)

}


#######################################################################
### FUNCTION FOR TO GET OperationsManager database SQL Server Name
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
# To Update the OperationsManager database Tables as needed
#######################################################################


$Table1 = 'dbo.MT_Microsoft$SystemCenter$ManagementGroup'

$Table2 = 'dbo.MT_Microsoft$SystemCenter$OpsMgrDB$AppMonitoring'

$Table3 = 'dbo.MT_Microsoft$SystemCenter$DataWarehouse'

$Table4 = 'dbo.MT_Microsoft$SystemCenter$DataWarehouse_Log'

$Table5 = 'dbo.MT_Microsoft$SystemCenter$DataWarehouse$AppMonitoring'

$Table6 = 'dbo.MT_Microsoft$SystemCenter$DataWarehouse$AppMonitoring_Log'

$Table7 = 'dbo.MT_Microsoft$SystemCenter$OpsMgrDWWatcher'

$cmd = "Update $Table1 set SQLServerName_43FB076F_7970_4C86_6DCA_8BD541F45E3A = '$SQLServerOpsDB'
where SQLServerName_43FB076F_7970_4C86_6DCA_8BD541F45E3A = '$OldSQLServerOpsDB'

Update $Table2
set MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A = '$SQLServerOpsDB'
where MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A = '$OldSQLServerOpsDB'

Update $Table3
set MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F = '$SQLServerOpsDW'
where MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F = '$OldSQLServerOpsDW'

Update $Table4
set Post_MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F = '$SQLServerOpsDW'
where Post_MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F = '$OldSQLServerOpsDW'

Update $Table5
set MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A = '$SQLServerOpsDW'
where MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A = '$OldSQLServerOpsDW'

Update $Table6
set Post_MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A = '$SQLServerOpsDW'
where Post_MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A = '$OldSQLServerOpsDW'

Update $Table7
set DatabaseServerName_69FBB0E2_A6E8_0483_7993_B7AB180A7889 = '$SQLServerOpsDW'
where DatabaseServerName_69FBB0E2_A6E8_0483_7993_B7AB180A7889 = '$OldSQLServerOpsDW'"


Get-SqlTable $SQLServerOpsDB $OpsMgrDB $cmd


#######################################################################
# To Update the OperationsManagerDW database Tables as needed
#######################################################################


$cmd1 = "Update dbo.MemberDatabase
set ServerName = '$SQLServerOpsDW'
where ServerName = '$OldSQLServerOpsDW'"


Get-SqlTable $SQLServerOpsDW $OpsMgrDW $cmd1


#######################################################################
# To Update the Management Server Registry informations
#######################################################################

Import-Module OperationsManager

$ManagementServers = Get-SCOMManagementServer | ? {$_.IsGateway -eq $False}
$MSs = $ManagementServers.Displayname

Foreach ($MS in $MSs)

{
    Update-SQLServerOpsDB $MS $SQLServerOpsDB

    Update-SQLServerOpsDW $MS $SQLServerOpsDW

    $CurrentSQLServerOpsDB = Get-SQLServerOpsDB $MS
    $CurrentSQLServerOpsDW = Get-SQLServerOpsDW $MS

    If ($CurrentSQLServerOpsDB -eq $SQLServerOpsDB -and $CurrentSQLServerOpsDW -eq $SQLServerOpsDW)

    {
        Write-Host "Registry updated successfullly" -ForegroundColor Green



$FullPath = Get-Installationpath $MS
$Split = $FullPath.split(':')
$Drive = $Split[0]
$Path = $SPlit[1]

$ConfigFIlepath = "\\$MS\$Drive$" + $Path

$ConfigFIle = "$ConfigFIlepath\ConfigService.config"
Copy-Item -Path $ConfigFIle -Destination "$ConfigFIlepath\configservice_Backup.config"

(Get-Content "$ConfigFIlepath\configservice.config") | ForEach-Object {$_ -Replace "$OldSQLServerOpsDB", "$SQLServerOpsDB"} | Set-Content -Path "$ConfigFIlepath\configservice.config" -Force

Get-Service -ComputerName $MS -Name cshost | Restart-Service

    }

    Else

    {

     Write-Host "Registry update is failed" -ForegroundColor Red

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
# To Update the SQL Broker Service
#######################################################################

$BrokerUpdate = "ALTER DATABASE OperationsManager SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE OperationsManager SET ENABLE_BROKER
ALTER DATABASE OperationsManager SET MULTI_USER"

Get-SqlTable $SQLServerOpsDB $OpsMgrDB $BrokerUpdate