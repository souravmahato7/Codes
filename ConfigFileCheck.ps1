############################################################################################
#Author: Sourav Mahato									   #
#Created Date:02/10/2021								   #
#Modified Date:02/11/2021								   #
#Purpose: Script for Config file and Registry Check for SCOM Management Servers	           #
#How to run: Save the Script as .PS1 and run it from a SCOM Management Server.             #
############################################################################################

######################################################################################################
### FUNCTIONS FOR TO check the Recommended registry tweaks for SCOM 2016 and 2019 management servers # 
######################################################################################################

function Get-StateQueueItems($ms)
{
	$hklm = 2147483650
	$regPath = "SYSTEM\CurrentControlSet\services\HealthService\Parameters"
	$regValue = "State Queue Items"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}


function Get-PersistenceCheckpointDepthMaximum($ms)
{
	$hklm = 2147483650
	$regPath = "SYSTEM\CurrentControlSet\services\HealthService\Parameters"
	$regValue = "Persistence Checkpoint Depth Maximum"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}


function Get-DALInitiateClearPool($ms)
{
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\System Center\2010\Common\DAL"
	$regValue = "DALInitiateClearPool"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}


function Get-DALInitiateClearPoolSeconds($ms)
{
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\System Center\2010\Common\DAL"
	$regValue = "DALInitiateClearPoolSeconds"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}

function Get-GroupCalcPollingIntervalMilliseconds($ms)
{
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\System Center\2010\Common"
	$regValue = "GroupCalcPollingIntervalMilliseconds"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}


function Get-CommandTimeoutSeconds($ms)
{
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Data Warehouse"
	$regValue = "Command Timeout Seconds"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}

function Get-DeploymentCommandTimeoutSeconds($ms)
{
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Data Warehouse"
	$regValue = "Deployment Command Timeout Seconds"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}


function Get-PoolLeaseRequestPeriodSeconds($ms)
{
	$hklm = 2147483650
	$regPath = "SYSTEM\CurrentControlSet\services\HealthService\Parameters\PoolManager"
	$regValue = "PoolLeaseRequestPeriodSeconds"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}


function Get-PoolNetworkLatencySeconds($ms)
{
	$hklm = 2147483650
	$regPath = "SYSTEM\CurrentControlSet\services\HealthService\Parameters\PoolManager"
	$regValue = "PoolNetworkLatencySeconds"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}

function Get-Installationpath ($MS)
{
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup"
	$regValue = "InstallDirectory"
	
	$regprov = [wmiclass]"\\$MS\root\default:stdRegProv"
	return ($regprov.GetStringValue($hklm,$regPath,$regValue)).svalue
}


#################################################################################################
###Code start from here 									#
#################################################################################################

$cur = Get-location

    if (Test-path $cur\log.txt)

        {
            Remove-Item -Path "$cur\log.txt" -Force
        }
        
     if (Test-path $cur\DiffValuelog.txt)

        {
            Remove-Item -Path "$cur\DiffValuelog.txt" -Force
        }

     if (Test-path $cur\NotFound.txt)

        {
            Remove-Item -Path "$cur\NotFound.txt" -Force
        }

     if (Test-path $cur\RPDetails.txt)

        {
            Remove-Item -Path "$cur\RPDetails.txt" -Force
        }
    
#######################################################################
# To validate Registry keys if they are consistent or not 	      #
#######################################################################

Import-Module OperationsManager

$ManagementServers = Get-SCOMManagementServer | ? {$_.IsGateway -eq $False}

$MSs = $ManagementServers.Displayname

Foreach ($MS in $MSs)

{
  
    #######################################################################
    # Validating the Key StateQueueItems 				  #
    #######################################################################

    $StateQueueItems = Get-StateQueueItems $MS

    If($StateQueueItems)
    { 
        If($StateQueueItems -eq '20480')
        {
        Write-Host "On SCOM Management Server $MS, Value for StateQueueItems is updated as recommended with value $StateQueueItems" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for StateQueueItems is updated as recommended with value $StateQueueItems" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, Value for StateQueueItems is updated as $StateQueueItems" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for StateQueueItems is updated as $StateQueueItems" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    Else
    {
        Write-Host "On SCOM Management Server $MS, Key StateQueueItems is not avilable" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key StateQueueItems is not avilable" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }

    #######################################################################
    # Validating the Key PersistenceCheckpointDepthMaximum 		  #
    #######################################################################

    $PersistenceCheckpointDepthMaximum = Get-PersistenceCheckpointDepthMaximum $MS

    If($PersistenceCheckpointDepthMaximum)
    { 
        If($PersistenceCheckpointDepthMaximum -eq '104857600')
        {
        Write-Host "On SCOM Management Server $MS, Value for PersistenceCheckpointDepthMaximum is updated as recommended with value $PersistenceCheckpointDepthMaximum" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for PersistenceCheckpointDepthMaximum is updated as recommended with value $PersistenceCheckpointDepthMaximum" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, Value for PersistenceCheckpointDepthMaximum is updated as $PersistenceCheckpointDepthMaximum" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for PersistenceCheckpointDepthMaximum is updated as $PersistenceCheckpointDepthMaximum" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    Else
    {
        Write-Host "On SCOM Management Server $MS, Key PersistenceCheckpointDepthMaximum is not avilable" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key PersistenceCheckpointDepthMaximum is not avilable" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }

    #######################################################################
    # Validating the Key DALInitiateClearPool 				  #
    #######################################################################

    $DALInitiateClearPool = Get-DALInitiateClearPool $MS

    If($DALInitiateClearPool)
    { 
        If($DALInitiateClearPool -eq '1')
        {
        Write-Host "On SCOM Management Server $MS, Value for DALInitiateClearPool is updated as recommended with value $DALInitiateClearPool" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for DALInitiateClearPool is updated as recommended with value $DALInitiateClearPool" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, Value for DALInitiateClearPool is updated as $DALInitiateClearPool" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for DALInitiateClearPool is updated as $DALInitiateClearPool" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    Else
    {
        Write-Host "On SCOM Management Server $MS, Key DALInitiateClearPool is not avilable" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key DALInitiateClearPool is not avilable" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }


    #######################################################################
    # Validating the Key DALInitiateClearPoolSeconds 			  #
    #######################################################################

    $DALInitiateClearPoolSeconds = Get-DALInitiateClearPoolSeconds $MS

    If($DALInitiateClearPoolSeconds)
    { 
        If($DALInitiateClearPoolSeconds -eq '60')
        {
        Write-Host "On SCOM Management Server $MS, Value for DALInitiateClearPoolSeconds is updated as recommended with value $DALInitiateClearPoolSeconds" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for DALInitiateClearPoolSeconds is updated as recommended with value $DALInitiateClearPoolSeconds" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, Value for DALInitiateClearPoolSeconds is updated as $DALInitiateClearPoolSeconds" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for DALInitiateClearPoolSeconds is updated as $DALInitiateClearPoolSeconds" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    Else
    {
        Write-Host "On SCOM Management Server $MS, Key DALInitiateClearPoolSeconds is not avilable" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key DALInitiateClearPoolSeconds is not avilable" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }

    #######################################################################
    # Validating the Key GroupCalcPollingIntervalMilliseconds 		  #
    #######################################################################

    $GroupCalcPollingIntervalMilliseconds = Get-GroupCalcPollingIntervalMilliseconds $MS

    If($GroupCalcPollingIntervalMilliseconds)
    { 
        If($GroupCalcPollingIntervalMilliseconds -eq '900000')
        {
        Write-Host "On SCOM Management Server $MS, Value for GroupCalcPollingIntervalMilliseconds is updated as recommended with value $GroupCalcPollingIntervalMilliseconds" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for GroupCalcPollingIntervalMilliseconds is updated as recommended with value $GroupCalcPollingIntervalMilliseconds" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, Value for GroupCalcPollingIntervalMilliseconds is updated as $GroupCalcPollingIntervalMilliseconds" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for GroupCalcPollingIntervalMilliseconds is updated as $GroupCalcPollingIntervalMilliseconds" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    Else
    {
        Write-Host "On SCOM Management Server $MS, Key GroupCalcPollingIntervalMilliseconds is not avilable" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key GroupCalcPollingIntervalMilliseconds is not avilable" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }

    #######################################################################
    # Validating the Key CommandTimeoutSeconds 				  #
    #######################################################################

    $CommandTimeoutSeconds = Get-CommandTimeoutSeconds $MS

    If($CommandTimeoutSeconds)
    { 
        If($CommandTimeoutSeconds -eq '1800')
        {
        Write-Host "On SCOM Management Server $MS, Value for CommandTimeoutSeconds is updated as recommended with value $CommandTimeoutSeconds" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for CommandTimeoutSeconds is updated as recommended with value $CommandTimeoutSeconds" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, Value for CommandTimeoutSeconds is updated as $CommandTimeoutSeconds" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for CommandTimeoutSeconds is updated as $CommandTimeoutSeconds" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    Else
    {
        Write-Host "On SCOM Management Server $MS, Key CommandTimeoutSeconds is not avilable" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key CommandTimeoutSeconds is not avilable" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }

    #######################################################################
    # Validating the Key DeploymentCommandTimeoutSeconds		  #
    #######################################################################

    $DeploymentCommandTimeoutSeconds = Get-DeploymentCommandTimeoutSeconds $MS

    If($DeploymentCommandTimeoutSeconds)
    { 
        If($DeploymentCommandTimeoutSeconds -eq '86400')
        {
        Write-Host "On SCOM Management Server $MS, Value for DeploymentCommandTimeoutSeconds is updated as recommended with value $DeploymentCommandTimeoutSeconds" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for DeploymentCommandTimeoutSeconds is updated as recommended with value $DeploymentCommandTimeoutSeconds" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, Value for DeploymentCommandTimeoutSeconds is updated as $DeploymentCommandTimeoutSeconds" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for DeploymentCommandTimeoutSeconds is updated as $DeploymentCommandTimeoutSeconds" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    Else
    {
        Write-Host "On SCOM Management Server $MS, Key DeploymentCommandTimeoutSeconds is not avilable" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key DeploymentCommandTimeoutSeconds is not avilable" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }

    #######################################################################
    # Validating the Key PoolLeaseRequestPeriodSeconds			  #
    #######################################################################

    $PoolLeaseRequestPeriodSeconds = Get-PoolLeaseRequestPeriodSeconds $MS

    If($PoolLeaseRequestPeriodSeconds)
    { 
        If($PoolLeaseRequestPeriodSeconds -eq '600')
        {
        Write-Host "On SCOM Management Server $MS, Value for PoolLeaseRequestPeriodSeconds is updated as recommended with value $PoolLeaseRequestPeriodSeconds" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for PoolLeaseRequestPeriodSeconds is updated as recommended with value $PoolLeaseRequestPeriodSeconds" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, Value for PoolLeaseRequestPeriodSeconds is updated as $PoolLeaseRequestPeriodSeconds" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for PoolLeaseRequestPeriodSeconds is updated as $PoolLeaseRequestPeriodSeconds" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    Else
    {
        Write-Host "On SCOM Management Server $MS, Key PoolLeaseRequestPeriodSeconds is not avilable" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key PoolLeaseRequestPeriodSeconds is not avilable" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }


    #######################################################################
    # Validating the Key PoolNetworkLatencySeconds		          #
    #######################################################################

    $PoolNetworkLatencySeconds = Get-PoolNetworkLatencySeconds $MS

    If($PoolNetworkLatencySeconds)
    { 
        If($PoolNetworkLatencySeconds -eq '120')
        {
        Write-Host "On SCOM Management Server $MS, Value for PoolNetworkLatencySeconds is updated as recommended with value $PoolNetworkLatencySeconds" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for PoolNetworkLatencySeconds is updated as recommended with value $PoolNetworkLatencySeconds" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, Value for PoolNetworkLatencySeconds is updated as $PoolNetworkLatencySeconds" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Value for PoolNetworkLatencySeconds is updated as $PoolNetworkLatencySeconds" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    Else
    {
        Write-Host "On SCOM Management Server $MS, Key PoolNetworkLatencySeconds is not avilable" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key PoolNetworkLatencySeconds is not avilable" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }

        #######################################################################
        # To validate the Management Server config file is consistent or not  #
        #######################################################################



        $FullPath = Get-Installationpath $MS
        $Split = $FullPath.split(':')
        $Drive = $Split[0]
        $Path = $SPlit[1]

        $ConfigFIlepath = "\\$MS\$Drive$" + $Path

        $ConfigFIle = "$ConfigFIlepath\ConfigService.config"

        ########################################################################################################
        # To validate the Management Server config file informations for DefaultTimeoutSeconds in config file  #
        ########################################################################################################

        Write-Host "Checking on SCOM Management Server $MS for DefaultTimeoutSeconds in config file" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
                "Checking on SCOM Management Server $MS for DefaultTimeoutSeconds in config file" >>"$cur\log.txt"
                "*********************************************************************************************************************************************************************" >>"$cur\log.txt"

        $DefaultTimeoutSeconds = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern 'OperationTimeout DefaultTimeoutSeconds='
        foreach ($DefaultTimeoutSecond in $DefaultTimeoutSeconds)
        {
        If ($DefaultTimeoutSecond -match '30')

        {
        Write-host "SCOM Management Server $MS is having the default value $DefaultTimeoutSecond" -ForegroundColor Green
        "SCOM Management Server $MS is having the default value $DefaultTimeoutSecond" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else

        {
        Write-host "SCOM Management Server $MS is having the Modified value as $DefaultTimeoutSecond" -ForegroundColor Red
        "SCOM Management Server $MS is having the Modified value as $DefaultTimeoutSecond" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
        }

        ###########################################################################################################
        # To validate the Management Server config file informations for GetEntityChangeDeltaList in config file  #
        ###########################################################################################################

        Write-Host "Checking on SCOM Management Server $MS for GetEntityChangeDeltaList in config file" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

        $GetEntityChangeDeltaList = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern 'Operation Name="GetEntityChangeDeltaList" TimeoutSeconds='

        If ($GetEntityChangeDeltaList -match '180')

        {
        Write-host "SCOM Management Server $MS is having the default value $GetEntityChangeDeltaList" -ForegroundColor Green
        "SCOM Management Server $MS is having the default value $GetEntityChangeDeltaList" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else

        {
        Write-host "SCOM Management Server $MS is having the Modified value as $GetEntityChangeDeltaList" -ForegroundColor Red
        "SCOM Management Server $MS is having the Modified value as $GetEntityChangeDeltaList" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

        #####################################################################################################################
        # To validate the Management Server config file informations for SnapshotSyncManagedEntityBatchSize in config file  #
        #####################################################################################################################

        Write-Host "Checking on SCOM Management Server $MS for SnapshotSyncManagedEntityBatchSize in config file" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

        $SnapshotSyncManagedEntityBatchSize = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern 'Setting Name="SnapshotSyncManagedEntityBatchSize" Value='

        If ($SnapshotSyncManagedEntityBatchSize -match '50000')

        {
        Write-host "SCOM Management Server $MS is having the default value $SnapshotSyncManagedEntityBatchSize" -ForegroundColor Green
        "SCOM Management Server $MS is having the default value $SnapshotSyncManagedEntityBatchSize" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else

        {
        Write-host "SCOM Management Server $MS is having the Modified value as $SnapshotSyncManagedEntityBatchSize" -ForegroundColor Red
        "SCOM Management Server $MS is having the Modified value as $SnapshotSyncManagedEntityBatchSize" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

        #####################################################################################################################
        # To validate the Management Server config file informations for SnapshotSyncRelationshipBatchSize in config file  #
        #####################################################################################################################

        Write-Host "Checking on SCOM Management Server $MS for SnapshotSyncRelationshipBatchSize in config file" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

        $SnapshotSyncRelationshipBatchSize = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern 'Setting Name="SnapshotSyncRelationshipBatchSize" Value='

        If ($SnapshotSyncRelationshipBatchSize -match '50000')

        {
        Write-host "SCOM Management Server $MS is having the default value $SnapshotSyncRelationshipBatchSize" -ForegroundColor Green
        "SCOM Management Server $MS is having the default value $SnapshotSyncRelationshipBatchSize" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else

        {
        Write-host "SCOM Management Server $MS is having the Modified value as $SnapshotSyncRelationshipBatchSize" -ForegroundColor Red
        "SCOM Management Server $MS is having the Modified value as $SnapshotSyncRelationshipBatchSize" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

        ##########################################################################################################################
        # To validate the Management Server config file informations for SnapshotSyncTypedManagedEntityBatchSize in config file  #
        ##########################################################################################################################

        Write-Host "Checking on SCOM Management Server $MS for SnapshotSyncTypedManagedEntityBatchSize in config file" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

        $SnapshotSyncTypedManagedEntityBatchSize = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern 'Setting Name="SnapshotSyncTypedManagedEntityBatchSize" Value='

        If ($SnapshotSyncTypedManagedEntityBatchSize -match '100000')

        {
        Write-host "SCOM Management Server $MS is having the default value $SnapshotSyncTypedManagedEntityBatchSize" -ForegroundColor Green
        "SCOM Management Server $MS is having the default value $SnapshotSyncTypedManagedEntityBatchSize" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }

        Else

        {
        Write-host "SCOM Management Server $MS is having the Modified value as $SnapshotSyncTypedManagedEntityBatchSize" -ForegroundColor Red
        "SCOM Management Server $MS is having the Modified value as $SnapshotSyncTypedManagedEntityBatchSize" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White


        ##########################################################################################################################
        # To validate the Management Server config file informations for EndSnapshot in config file  				 #
        ##########################################################################################################################

        Write-Host "Checking on SCOM Management Server $MS for EndSnapshot in config file" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

        $EndSnapshot = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern 'Operation Name="EndSnapshot" TimeoutSeconds='

        If ($EndSnapshot -match '900')

        {
        Write-host "SCOM Management Server $MS is having the default value $EndSnapshot" -ForegroundColor Green
        "SCOM Management Server $MS is having the default value $EndSnapshot" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }

        Else

        {
        Write-host "SCOM Management Server $MS is having the Modified value as $EndSnapshot" -ForegroundColor Red
        "SCOM Management Server $MS is having the Modified value as $EndSnapshot" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White


        ##########################################################################################################################
        # To validate the Management Server config file informations for WriteConfigurationSnapshotBatch in config file 	 #
        ##########################################################################################################################

        Write-Host "Checking on SCOM Management Server $MS for WriteConfigurationSnapshotBatch in config file" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

        $WriteConfigurationSnapshotBatch = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern 'Operation Name="WriteConfigurationSnapshotBatch" TimeoutSeconds='

        If ($WriteConfigurationSnapshotBatch -match '300')

        {
        Write-host "SCOM Management Server $MS is having the default value $WriteConfigurationSnapshotBatch" -ForegroundColor Green
        "SCOM Management Server $MS is having the default value $WriteConfigurationSnapshotBatch" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }

        Else

        {
        Write-host "SCOM Management Server $MS is having the Modified value as $WriteConfigurationSnapshotBatch" -ForegroundColor Red
        "SCOM Management Server $MS is having the Modified value as $WriteConfigurationSnapshotBatch" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White


        ##########################################################################################################################
        # To validate the Management Server config file informations for SnapshotSynchronization in config file  		 #
        ##########################################################################################################################

        Write-Host "Checking on SCOM Management Server $MS for SnapshotSynchronization in config file" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

        $SnapshotSynchronization = Get-ChildItem -Path "$ConfigFIlepath" -Include "configservice.config" -Recurse | Select-String -Pattern 'WorkItem Name="SnapshotSynchronization" Enabled="true" Shared="true" FrequencySeconds="86400" TimeoutSeconds='

        If ($SnapshotSynchronization -match '1800')

        {
        Write-host "SCOM Management Server $MS is having the default value $SnapshotSynchronization" -ForegroundColor Green
        "SCOM Management Server $MS is having the default value $SnapshotSynchronization" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }

        Else

        {
        Write-host "SCOM Management Server $MS is having the Modified value as $SnapshotSynchronization" -ForegroundColor Red
        "SCOM Management Server $MS is having the Modified value as $SnapshotSynchronization" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White

}
        ##########################################################################################################################
        # Getting the Resourcepool details  											 #
        ##########################################################################################################################
        Get-SCOMResourcePool | % { $_.DisplayName; "`t$($_.Members)" } >>"$Cur\RPDetails.txt"
