##################################################################
# Author: Sourav Mahato
# Created Date:08/25/2019
# Modified Date: 09/07/2019
# Purpose: Script for SCOM database movement
# How to run: You just need to provide the information as asked in the forms

#Precaution: Beofre running this Script, please make sure that following pre-requsites are in place

#1. Full Backup of SCOM DBs
#2. Restore the databases on new SQL instances
#3. SQL login account should have been created for SDK, Reader, Writer, DAS accunts in New database instance
#4. Local admin rights on Management servers and SA rights on SQL DBs (OperationsManager and OperationsManagerDW)
#5. Please provide fqdn of the sql server name if it is standalone server and you are using default instance.


##################################################################

function button ($title,$CurrentSQLServerOpsDB,$FutureSQLServerOpsDB,$CurrentSQLServerOpsDW,$FutureSQLServerOpsDW,$OpsMgrDBName,$OpsMgrDWName) {

  ###################Load Assembly for creating form & button######
  
  [void][System.Reflection.Assembly]::LoadWithPartialName( "System.Windows.Forms")
  [void][System.Reflection.Assembly]::LoadWithPartialName( "Microsoft.VisualBasic")
  
  #####Define the form size & placement
  
  $form = New-Object "System.Windows.Forms.Form";
  $form.Width = 500;
  $form.Height = 400;
  $form.Text = $title;
  $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;
  
  ##############Define text label1
  $textLabel1 = New-Object "System.Windows.Forms.Label";
  $textLabel1.Left = 25;
  $textLabel1.Top = 15;
  
  $textLabel1.Text = $CurrentSQLServerOpsDB;
  
  ##############Define text label2
  
  $textLabel2 = New-Object "System.Windows.Forms.Label";
  $textLabel2.Left = 25;
  $textLabel2.Top = 50;
  
  $textLabel2.Text = $FutureSQLServerOpsDB;
  
  ##############Define text label3
  
  $textLabel3 = New-Object "System.Windows.Forms.Label";
  $textLabel3.Left = 25;
  $textLabel3.Top = 85;
  
  $textLabel3.Text = $CurrentSQLServerOpsDW;
  
  ##############Define text label4
  $textLabel4 = New-Object "System.Windows.Forms.Label";
  $textLabel4.Left = 25;
  $textLabel4.Top = 130;
  
  $textLabel4.Text = $FutureSQLServerOpsDW;
  
  ##############Define text label5
  
  $textLabel5 = New-Object "System.Windows.Forms.Label";
  $textLabel5.Left = 25;
  $textLabel5.Top = 165;
  
  $textLabel5.Text = $OpsMgrDBName;
  
  ##############Define text label6
  
  $textLabel6 = New-Object "System.Windows.Forms.Label";
  $textLabel6.Left = 25;
  $textLabel6.Top = 200;
  
  $textLabel6.Text = $OpsMgrDWName;
  
  ############Define text box1 for input
  $textBox1 = New-Object "System.Windows.Forms.TextBox";
  $textBox1.Left = 150;
  $textBox1.Top = 10;
  $textBox1.width = 200;
  
  ############Define text box2 for input
  
  $textBox2 = New-Object "System.Windows.Forms.TextBox";
  $textBox2.Left = 150;
  $textBox2.Top = 50;
  $textBox2.width = 200;
  
  ############Define text box3 for input
  
  $textBox3 = New-Object "System.Windows.Forms.TextBox";
  $textBox3.Left = 150;
  $textBox3.Top = 90;
  $textBox3.width = 200;
  
  ############Define text box4 for input
  $textBox4 = New-Object "System.Windows.Forms.TextBox";
  $textBox4.Left = 150;
  $textBox4.Top = 130;
  $textBox4.width = 200;
  
  ############Define text box5 for input
  
  $textBox5 = New-Object "System.Windows.Forms.TextBox";
  $textBox5.Left = 150;
  $textBox5.Top = 170;
  $textBox5.width = 200;
  
  ############Define text box6 for input
  
  $textBox6 = New-Object "System.Windows.Forms.TextBox";
  $textBox6.Left = 150;
  $textBox6.Top = 210;
  $textBox6.width = 200;
  
  #############Define default values for the input boxes
  $defaultValue = ""
  $textBox1.Text = $defaultValue;
  $textBox2.Text = $defaultValue;
  $textBox3.Text = $defaultValue;
  $textBox4.Text = $defaultValue;
  $textBox5.Text = $defaultValue;
  $textBox6.Text = $defaultValue;
  
  #############define OK button
  $button = New-Object "System.Windows.Forms.Button";
  $button.Left = 360;
  $button.Top = 230;
  $button.Width = 50;
  $button.Text = "Ok";
  
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
  
  $return= button "SCOM Database Movement QC Script" "Enter Old SQL Server for Ops DB" "Enter New SQL Server for Ops DB" "Enter Old SQL Server for Ops DW" "Enter New SQL Server for Ops DW" "Enter Ops DB Name" "Enter DW DB Name"
  
  Write-Host "The Old SQL Server Name for OperationsManager DB is "$return[0] -ForegroundColor Magenta
  
  Write-Host "The New SQL Server Name for OperationsManager DB is "$return[1] -ForegroundColor Magenta
  
  Write-Host "The Old SQL Server Name for OperationsManagerDW DB is "$return[2] -ForegroundColor Magenta
  
  Write-Host "The New SQL Server Name for OperationsManagerDW DB is "$return[3] -ForegroundColor Magenta
  
  Write-Host "The Database name for OperationsManager DB is "$return[4] -ForegroundColor Magenta
  
  Write-Host "The Database Name for OperationsManagerDW DB is "$return[5] -ForegroundColor Magenta
  
  $OldSQLServerOpsDB = $return[0]
  $SQLServerOpsDB = $return[1]
  $OldSQLServerOpsDW = $return[2]
  $SQLServerOpsDW = $return[3]
  $OpsMgrDB = $return[4]
  $OpsMgrDW = $return[5]
  
  
  ##################################################################
  ###### Function for SQL Query
  #######################################################################
  
  
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
  
  Write-Host "Updating the Tables at Database $SQLServerOpsDB" -ForegroundColor Yellow
  
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
  
  Write-Host "Updating the Table 'dbo.MemberDatabase' at Database $SQLServerOpsDW" -ForegroundColor Yellow
  
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
  
  Write-Host "Updating the Registry on Management Server $MS for $SQLServerOpsDB" -ForegroundColor Yellow
  
      Update-SQLServerOpsDB $MS $SQLServerOpsDB
  
  Write-Host "Updating the Registry on Management Server $MS for $SQLServerOpsDW" -ForegroundColor Yellow
  
      Update-SQLServerOpsDW $MS $SQLServerOpsDW
  
      $CurrentSQLServerOpsDB = Get-SQLServerOpsDB $MS
  
      $CurrentSQLServerOpsDW = Get-SQLServerOpsDW $MS
  
      If ($CurrentSQLServerOpsDB -eq $SQLServerOpsDB -and $CurrentSQLServerOpsDW -eq $SQLServerOpsDW)
  
      {
          Write-Host "Registry updated successfullly" -ForegroundColor Green
  
  
  $Date = Get-Date
  $Day = $Date.Day
  $Month = $Date.Month
  $Year = $Date.Year
  
  #$B ='"'+$return[1]+'"'
  
  $FormatDate = "$day-$Month-$Year"
  
  $FullPath = Get-Installationpath $MS
  
  $Split = $FullPath.split(':')
  
  $Drive = $Split[0]
  
  $Path = $SPlit[1]
  
  $ConfigFIlepath = "\\$MS\$Drive$" + $Path
  
  $ConfigFIle = "$ConfigFIlepath\ConfigService.config"
  
  Write-Host "Config file is getting backed up for the Management Server $MS" -ForegroundColor Yellow
  
  Copy-Item -Path $ConfigFIle -Destination "$ConfigFIlepath\configservice_$FormatDate.config"
  
  Write-Host "Config file is getting updated with new Database Server Name as $SQLServerOpsDB in the Management Server $MS" -ForegroundColor Yellow
  
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
  
  Write-Host "Broker Service will be updated now in the new Database Server $SQLServerOpsDB for database $OpsMgrDB" -ForegroundColor Yellow
  
  $BrokerUpdate = "ALTER DATABASE $OpsMgrDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
  ALTER DATABASE $OpsMgrDB SET ENABLE_BROKER
  ALTER DATABASE $OpsMgrDB SET MULTI_USER"
  
  Get-SqlTable $SQLServerOpsDB $OpsMgrDB $BrokerUpdate
  
