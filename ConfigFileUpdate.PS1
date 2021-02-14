#################################################################################
#Author: Sourav Mahato									                                        #
#Created Date:02/14/2021								                                        #
#Modified Date:NA							                               	                  #
#Purpose: Script to update the Config file for SCOM Management Servers	        #
#How to run: Save the Script as .PS1 and run it from a SCOM Management Server.  #
#################################################################################


function Get-Installationpath ($MS)
{
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup"
	$regValue = "InstallDirectory"	
	$regprov = [wmiclass]"\\$MS\root\default:stdRegProv"
	return ($regprov.GetStringValue($hklm,$regPath,$regValue)).svalue
}


Import-Module OperationsManager

$ManagementServers = Get-SCOMManagementServer | ? {$_.IsGateway -eq $False}

$MSs = $ManagementServers.Displayname

Foreach ($MS in $MSs)

{

    ########################################################################################################
    # Backup of the config file before updating                                                            #
    ########################################################################################################

    $Date = Get-Date

    $Day = $Date.Day

    $Month = $Date.Month

    $Year = $Date.Year

    $FormatDate = "$day-$Month-$Year"

    $FullPath = Get-Installationpath $MS

    $Split = $FullPath.split(':')

    $Drive = $Split[0]

    $Path = $SPlit[1]

    $ConfigFilepath = "\\$MS\$Drive$" + $Path

    $ConfigFile = "$ConfigFilepath\ConfigService.config"

    Write-Host "Config file is getting backed up for the Management Server $MS" -ForegroundColor Yellow

    Copy-Item -Path $ConfigFile -Destination "$ConfigFilepath\configservice_$FormatDate.config"

    ########################################################################################################
    # To Update the DefaultTimeoutSeconds in config file as Recommended for Management Server config file  #
    ########################################################################################################


    Write-Host "Checking DefaultTimeoutSeconds and will update it with 300 seconds from 30" -ForegroundColor Yellow

    $find = 'DefaultTimeoutSeconds="30">'

    $replace = 'DefaultTimeoutSeconds="300">'

    $DefaultTimeoutSeconds = Get-Content $ConfigFile | ? {$_ -match $find}

    Foreach ($DefaultTimeoutSecond in $DefaultTimeoutSeconds)

    {

    Write-host "Enter here to update $DefaultTimeoutSecond" -ForegroundColor Green

    (Get-Content $ConfigFile).replace($find, $replace) | Set-Content $ConfigFile

    }

    ##########################################################################################################
    # To Update the GetEntityChangeDeltaList in config file as Recommended for Management Server config file #
    ##########################################################################################################

    Write-Host "Checking GetEntityChangeDeltaList and will update it with 300 seconds from 180" -ForegroundColor Yellow

    $find = '"GetEntityChangeDeltaList" TimeoutSeconds="180" />'

    $replace = '"GetEntityChangeDeltaList" TimeoutSeconds="300" />'

    $GetEntityChangeDeltaLists = Get-Content $ConfigFile | ? {$_ -match $find}

    Foreach ($GetEntityChangeDeltaList in $GetEntityChangeDeltaLists)

    {

    Write-host "Enter here to update the $GetEntityChangeDeltaList" -ForegroundColor Green

    (Get-Content $ConfigFile).replace($find, $replace) | Set-Content $ConfigFile

    }

    ##########################################################################################################
    # To Update the EndSnapshot in config file as Recommended for Management Server config file              #
    ##########################################################################################################

    Write-Host "Checking EndSnapshot and will update it with 1800 seconds from 900" -ForegroundColor Yellow

    $find = '"EndSnapshot" TimeoutSeconds="900" />'

    $replace = '"EndSnapshot" TimeoutSeconds="1800" />'

    $EndSnapshots = Get-Content $ConfigFile | ? {$_ -match $find}

    Foreach ($EndSnapshot in $EndSnapshots)

    {

    Write-host "Enter here to update the $EndSnapshot" -ForegroundColor Green

    (Get-Content $ConfigFile).replace($find, $replace) | Set-Content $ConfigFile

    }


    ####################################################################################################################
    # To Update the SnapshotSyncManagedEntityBatchSize in config file as Recommended for Management Server config file #
    ####################################################################################################################

    Write-Host "Checking SnapshotSyncManagedEntityBatchSize and will update it with 10000 seconds from 50000" -ForegroundColor Yellow

    $find = '"SnapshotSyncManagedEntityBatchSize" Value="50000" />'

    $replace = '"SnapshotSyncManagedEntityBatchSize" Value="10000" />'

    $SnapshotSyncManagedEntityBatchSizes = Get-Content $ConfigFile | ? {$_ -match $find}

    Foreach ($SnapshotSyncManagedEntityBatchSize in $SnapshotSyncManagedEntityBatchSizes)

    {

    Write-host "Enter here to update the $SnapshotSyncManagedEntityBatchSize" -ForegroundColor Green

    (Get-Content $ConfigFile).replace($find, $replace) | Set-Content $ConfigFile

    }


    ##########################################################################################################
    # To Update the EndSnapshot in config file as Recommended for Management Server config file              #
    ##########################################################################################################

    Write-Host "Checking SnapshotSyncRelationshipBatchSize and will update it with 10000 seconds from 50000" -ForegroundColor Yellow

    $find = '"SnapshotSyncRelationshipBatchSize" Value="50000" />'

    $replace = '"SnapshotSyncRelationshipBatchSize" Value="10000" />'

    $SnapshotSyncRelationshipBatchSizes = Get-Content $ConfigFile | ? {$_ -match $find}

    Foreach ($SnapshotSyncRelationshipBatchSize in $SnapshotSyncRelationshipBatchSizes)

    {

    Write-host "Enter here to update the $SnapshotSyncRelationshipBatchSize" -ForegroundColor Green

    (Get-Content $ConfigFile).replace($find, $replace) | Set-Content $ConfigFile

    }

    #########################################################################################################################
    # To Update the SnapshotSyncTypedManagedEntityBatchSize in config file as Recommended for Management Server config file #
    #########################################################################################################################

    Write-Host "Checking SnapshotSyncTypedManagedEntityBatchSize and will update it with 20000 seconds from 100000" -ForegroundColor Yellow

    $find = '"SnapshotSyncTypedManagedEntityBatchSize" Value="100000" />'

    $replace = '"SnapshotSyncTypedManagedEntityBatchSize" Value="20000" />'

    $SnapshotSyncTypedManagedEntityBatchSizes = Get-Content $ConfigFile | ? {$_ -match $find}

    Foreach ($SnapshotSyncTypedManagedEntityBatchSize in $SnapshotSyncTypedManagedEntityBatchSizes)

    {

    Write-host "Enter here to update the $SnapshotSyncTypedManagedEntityBatchSize" -ForegroundColor Green

    (Get-Content $ConfigFile).replace($find, $replace) | Set-Content $ConfigFile

    }

    #################################################################################################################
    # To Update the WriteConfigurationSnapshotBatch in config file as Recommended for Management Server config file #
    #################################################################################################################

    Write-Host "Checking WriteConfigurationSnapshotBatch and will update it with 900 seconds from 300" -ForegroundColor Yellow

    $find = '"WriteConfigurationSnapshotBatch" TimeoutSeconds="300" />'

    $replace = '"WriteConfigurationSnapshotBatch" TimeoutSeconds="900" />'

    $WriteConfigurationSnapshotBatchs = Get-Content $ConfigFile | ? {$_ -match $find}

    Foreach ($WriteConfigurationSnapshotBatch in $WriteConfigurationSnapshotBatchs)

    {

    Write-host "Enter here to update the $WriteConfigurationSnapshotBatch" -ForegroundColor Green

    (Get-Content $ConfigFile).replace($find, $replace) | Set-Content $ConfigFile

    }

    ##########################################################################################################
    # To Update the SnapshotSynchronization in config file as Recommended for Management Server config file  #
    ##########################################################################################################

    Write-Host "Checking SnapshotSynchronization and will update it with 3600 seconds from 1800" -ForegroundColor Yellow

    $find = '"SnapshotSynchronization" Enabled="true" Shared="true" FrequencySeconds="86400" TimeoutSeconds="1800">'

    $replace = '"SnapshotSynchronization" Enabled="true" Shared="true" FrequencySeconds="86400" TimeoutSeconds="3600">'

    $SnapshotSynchronizations = Get-Content $ConfigFile | ? {$_ -match $find}

    Foreach ($SnapshotSynchronization in $SnapshotSynchronizations)

    {

    Write-host "Enter here to update the $SnapshotSynchronization" -ForegroundColor Green

    (Get-Content $ConfigFile).replace($find, $replace) | Set-Content $ConfigFile

    }

Get-Service -ComputerName $MS -Name cshost | Restart-Service

}
