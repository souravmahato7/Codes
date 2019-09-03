##################################################################
#Author: Sourav Mahato
#Created Date:08/26/2019
#Modified Date:09/04/2019
#Purpose: Script for Quality Check for SCOM database movement
#How to run: You just need to provide the information as asked in the forms
##################################################################
###### Function for SQL Query
#######################################################################

function button ($title,$OldSQLServerOpsDB,$SQLServerOpsDB,$OldSQLServerOpsDW,$SQLServerOpsDW,$OpsMgrDB,$OpsMgrDW) {

###################Load Assembly for creating form & button######

[void][System.Reflection.Assembly]::LoadWithPartialName( “System.Windows.Forms”)
[void][System.Reflection.Assembly]::LoadWithPartialName( “Microsoft.VisualBasic”)

#####Define the form size & placement

$form = New-Object “System.Windows.Forms.Form”;
$form.Width = 500;
$form.Height = 400;
$form.Text = $title;
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;

##############Define text label1
$textLabel1 = New-Object “System.Windows.Forms.Label”;
$textLabel1.Left = 25;
$textLabel1.Top = 15;

$textLabel1.Text = $OldSQLServerOpsDB;

##############Define text label2

$textLabel2 = New-Object “System.Windows.Forms.Label”;
$textLabel2.Left = 25;
$textLabel2.Top = 50;

$textLabel2.Text = $SQLServerOpsDB;

##############Define text label3

$textLabel3 = New-Object “System.Windows.Forms.Label”;
$textLabel3.Left = 25;
$textLabel3.Top = 85;

$textLabel3.Text = $OldSQLServerOpsDW;

##############Define text label4
$textLabel4 = New-Object “System.Windows.Forms.Label”;
$textLabel4.Left = 25;
$textLabel4.Top = 130;

$textLabel4.Text = $SQLServerOpsDW;

##############Define text label5

$textLabel5 = New-Object “System.Windows.Forms.Label”;
$textLabel5.Left = 25;
$textLabel5.Top = 165;

$textLabel5.Text = $OpsMgrDB;

##############Define text label6

$textLabel6 = New-Object “System.Windows.Forms.Label”;
$textLabel6.Left = 25;
$textLabel6.Top = 200;

$textLabel6.Text = $OpsMgrDW;

############Define text box1 for input
$textBox1 = New-Object “System.Windows.Forms.TextBox”;
$textBox1.Left = 150;
$textBox1.Top = 10;
$textBox1.width = 200;

############Define text box2 for input

$textBox2 = New-Object “System.Windows.Forms.TextBox”;
$textBox2.Left = 150;
$textBox2.Top = 50;
$textBox2.width = 200;

############Define text box3 for input

$textBox3 = New-Object “System.Windows.Forms.TextBox”;
$textBox3.Left = 150;
$textBox3.Top = 90;
$textBox3.width = 200;

############Define text box4 for input
$textBox4 = New-Object “System.Windows.Forms.TextBox”;
$textBox4.Left = 150;
$textBox4.Top = 130;
$textBox4.width = 200;

############Define text box5 for input

$textBox5 = New-Object “System.Windows.Forms.TextBox”;
$textBox5.Left = 150;
$textBox5.Top = 170;
$textBox5.width = 200;

############Define text box6 for input

$textBox6 = New-Object “System.Windows.Forms.TextBox”;
$textBox6.Left = 150;
$textBox6.Top = 210;
$textBox6.width = 200;

#############Define default values for the input boxes
$defaultValue = “”
$textBox1.Text = $defaultValue;
$textBox2.Text = $defaultValue;
$textBox3.Text = $defaultValue;
$textBox4.Text = $defaultValue;
$textBox5.Text = $defaultValue;
$textBox6.Text = $defaultValue;

#############define OK button
$button = New-Object “System.Windows.Forms.Button”;
$button.Left = 360;
$button.Top = 230;
$button.Width = 50;
$button.Text = “Ok”;

############# This is when you have to close the form after getting values
$eventHandler = [System.EventHandler]{
$textBox1.Text;
$textBox2.Text;
$textBox3.Text;
$textBox4.Text;
$textBox5.Text;
$textBox6.Text;
$form.Close();};

$button.Add_Click($eventHandler) ;

#############Add controls to all the above objects defined
$form.Controls.Add($button);
$form.Controls.Add($textLabel1);
$form.Controls.Add($textLabel2);
$form.Controls.Add($textLabel3);
$form.Controls.Add($textLabel4);
$form.Controls.Add($textLabel5);
$form.Controls.Add($textLabel6);
$form.Controls.Add($textBox1);
$form.Controls.Add($textBox2);
$form.Controls.Add($textBox3);
$form.Controls.Add($textBox4);
$form.Controls.Add($textBox5);
$form.Controls.Add($textBox6);
$ret = $form.ShowDialog();

#################return values

return $textBox1.Text, $textBox2.Text, $textBox3.Text, $textBox4.Text, $textBox5.Text, $textBox6.Text

}

$return= button “SCOM Database Movement QC Script” “Enter Old SQL Server for Ops DB” “Enter New SQL Server for Ops DB” “Enter Old SQL Server for Ops DW” "Enter New SQL Server for Ops DW" "Enter Ops DB Name" "Enter DW DB Name"

Write-Host "The Old SQL Server Name for OperationsManager DB is "$return[0] -ForegroundColor Magenta

Write-Host "The New SQL Server Name for OperationsManager DB is "$return[1] -ForegroundColor Magenta

Write-Host "The Old SQL Server Name for OperationsManagerDW DB is "$return[2] -ForegroundColor Magenta

Write-Host "The New SQL Server Name for OperationsManagerDW DB is "$return[3] -ForegroundColor Magenta

Write-Host "The Database name for OperationsManager DB is "$return[4] -ForegroundColor Magenta

Write-Host "The Database Name for OperationsManagerDW DB is "$return[5] -ForegroundColor Magenta


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

$Result1 = Get-SqlTable $return[1] $return[4] $cmd1

$DBServerName1 = $Result1.SQLServerName_43FB076F_7970_4C86_6DCA_8BD541F45E3A

If ($DBServerName1 -eq $return[1])

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

$Result2 = Get-SqlTable $return[1] $return[4] $cmd2

$DBServerName2 = $Result2.MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A

If ($DBServerName2 -eq $return[1])

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

$Result3 = Get-SqlTable $return[1] $return[4] $cmd3

$DBServerName3 = $Result3.MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F

If ($DBServerName3 -eq $return[1])

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

$Result4 = Get-SqlTable $return[1] $return[4] $cmd4

$DBServerName4 = $Result4.Post_MainDatabaseServerName_2C77AA48_DB0A_5D69_F8FF_20E48F3AED0F

If ($DBServerName4 -eq $return[1])

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

$Result5 = Get-SqlTable $return[1] $return[4] $cmd5

$DBServerName5 = $Result5.MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A

If ($DBServerName5 -eq $return[1])

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

$Result6 = Get-SqlTable $return[1] $return[4] $cmd6

$DBServerName6 = $Result6.Post_MainDatabaseServerName_5C00C79B_6B71_6EEE_4ADE_80C11F84527A

If ($DBServerName6 -eq $return[1])

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

$Result7 = Get-SqlTable $return[1] $return[4] $cmd7

$DBServerName7 = $Result7.DatabaseServerName_69FBB0E2_A6E8_0483_7993_B7AB180A7889

If ($DBServerName7 -eq $return[1])

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

$Result8 = Get-SqlTable $return[3] $return[5] $cmd8

$DBServerName8 = $Result8.ServerName

If ($DBServerName8 -eq $return[3])

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

    If ($CurrentSQLServerOpsDB -eq $return[1])

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

    If ($CurrentSQLServerOpsDW -eq $return[3])

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


    If ($CurrentOpsDBRegistry -eq $return[1])

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

#$return[1] = 'sql2016'
$B ='"'+$return[1]+'"'
$C = $B
$CurrentSQLServerOpsDB = "Value=$C"


#$ConfigInfo = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern "$return[1]"

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
Get-SqlTable $return[1] $return[4] $CLRUpdate#>


#######################################################################
# To Validate the SQL Broker Service
#######################################################################

Write-Host "Validating if SQL broker service is enable or not" -ForegroundColor Yellow
Write-Host "
"

$OperationsManagerDB =''+$return[4]+''

$cmd9 = "SELECT is_broker_enabled FROM sys.databases WHERE name = '$OperationsManagerDB'"

#Write-Host $cmd9

$Result9 = Get-SqlTable $return[1] $return[4] $cmd9

Write-Host $Result9

$Result9.is_broker_enabled

If ($Result9.is_broker_enabled -eq '1')

{ Write-Host "SQL broker service is enabled" -ForegroundColor Green
Write-Host "
"}

Else

{Write-Host "SQL broker service is not enabled" -ForegroundColor Red
Write-Host "
"}
