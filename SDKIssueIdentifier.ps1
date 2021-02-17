############################################################################################
#Author: Sourav Mahato									                                                   #
#Created Date:02/10/2021								                                                   #
#Modified Date:02/11/2021								                                                   #
#Purpose: SDK issue identifier for SCOM Management Servers	                               #
#How to run: Save the Script as .PS1 and run it from a SCOM Management Server.             #
############################################################################################

#######################################################################
### FUNCTION TO check the TLS Keys 
#######################################################################
function GetTLSKeys($MS)  
{
    $branch = "LocalMachine"

    $ProtocolList = @("SSL 2.0","SSL 3.0","TLS 1.0", "TLS 1.1", "TLS 1.2")

	$TLSdataregistry=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($branch,$MS)

    #Write-Host "Collecting Data for Server $MS" -ForegroundColor Green

    "Collecting Data for Server $MS" >> "$Cur\TLSKeys_$MS.txt"

	$Currentpath = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"

    Foreach ($Protocol in $ProtocolList)
    {
	    
        $regPath = "$Currentpath\$Protocol"

        $ProtocolSubKeyList = @("Client", "Server")

        Foreach ($key in $ProtocolSubKeyList)

        {
            $Actualpath = "$regPath\$key"

            $TLSdataRegistrykey = $TLSdataregistry.OpenSubKey($Actualpath)

	        If ($TLSdataRegistrykey -ne $null) 
       
            {		        
                $Keys1 = $TLSdataRegistrykey.GetValue("DisabledByDefault")

                Write-Host "For Management Server $MS, Checking on path $Actualpath for DisabledByDefault Key, It is present with value $Keys1" -ForegroundColor Yellow
                Write-Host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

                "For Management Server $MS, Checking on path $Actualpath for DisabledByDefault Key, It is present with value $Keys1" >> "$Cur\TLSKeys_$MS.txt"
                "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++">> "$Cur\TLSKeys_$MS.txt"

                $Keys2 = $TLSdataRegistrykey.GetValue("Enabled")

                Write-Host "For Management Server $MS, Checking on $Actualpath for Enabled Key, It is present with value $Keys2" -ForegroundColor Yellow
                Write-Host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                "For Management Server $MS, Checking on $Actualpath for Enabled Key, It is present with value $Keys2" >> "$cur\TLSKeys_$MS.txt"
                "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> "$Cur\TLSKeys_$MS.txt"
	        }
	    
            else 
            
            {
		    
                $Keys1 = $null

                Write-Host "For Server $MS, Checking on $Actualpath for DisabledByDefault Key, It is Not present" -ForegroundColor Red
                "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                "For Server $MS, Checking on $Actualpath for DisabledByDefault Key, It is Not present" >>"$Cur\TLSKeys_$MS.txt"
                "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> "$Cur\TLSKeys_$MS.txt"
            
                $Keys2 = $null

                Write-Host "For Server $MS, Checking on $Actualpath for Enabled Key, It is Not present" -ForegroundColor Red
                "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                "For Server $MS, Checking on $Actualpath for Enabled Key, It is Not present" >> "$Cur\TLSKeys_$MS.txt"
                "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++">> "$Cur\TLSKeys_$MS.txt"

	        
            }
        }
	
	
    }
   	
	    return $Keys1
        return $Keys2 	

}

#######################################################################
### FUNCTION TO check the SQL Server Name for OperationsManager database 
#######################################################################

function Get-SQLServerOpsDB ($MS)
{
	#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup\DatabaseagentName
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup"
	$regValue = "DatabaseServerName"
	
	$regprov = [wmiclass]"\\$MS\root\default:stdRegProv"
    #$UpdatedRegvalue = $regprov.GetStringValue($hklm,$regPath,$regValue).svalue
	return ($regprov.GetStringValue($hklm,$regPath,$regValue)).svalue
}

#######################################################################
### FUNCTION TO check the SQL Server Name for OperationsManagerDW database 
#######################################################################

function Get-SQLServerOpsDBRegistry ($MS)
{
	#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup\DatabaseagentName
	$hklm = 2147483650
	$regPath = 'SOFTWARE\Microsoft\System Center\2010\Common\Database'
	$regValue = "DatabaseServerName"
	
	$regprov = [wmiclass]"\\$MS\root\default:stdRegProv"
    #$UpdatedRegvalue = $regprov.GetStringValue($hklm,$regPath,$regValue).svalue
	return ($regprov.GetStringValue($hklm,$regPath,$regValue)).svalue
}


#######################################################################
### FUNCTION TO check the SQL Server Name for OperationsManagerDW database 
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


function Get-SchUseStrongCrypto($ms)
{
	$hklm = 2147483650
	$regPath = "SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
	$regValue = "SchUseStrongCrypto"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}

function Get-SchUseStrongCrypto1($ms)
{
	$hklm = 2147483650
	$regPath = "SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319"
	$regValue = "SchUseStrongCrypto"
	
	$regprov = [wmiclass]"\\$ms\root\default:stdRegProv"
	return ($regprov.GetDWORDValue($hklm,$regPath,$regValue)).uValue
}


#######################################################################
# To validate the Management Server Registry informations
#######################################################################

$cur = Get-Location

   if (Test-path "$cur\log.txt")

    {
    Remove-Item -Path "$cur\log.txt" -Force
    
    }

   if (Test-path "$cur\DiffValuelog.txt")

    {
    Remove-Item -Path "$cur\DiffValuelog.txt" -Force
    
    }

   if (Test-path "$cur\NotFound.txt")

    {
    Remove-Item -Path "$cur\NotFound.txt" -Force
    
    }

Import-Module OperationsManager

$ManagementServers = Get-SCOMManagementServer | ? {$_.IsGateway -eq $False}

$MSs = $ManagementServers.Displayname

Foreach ($MS in $MSs)

{

Write-Host "Collecting the Registry value for DatabaseServerName and DataWarehouseDBServerName for the Management Server $MS" -ForegroundColor Yellow
Write-Host "****************************************************************************************************************************************************"

"Collecting the Registry value for DatabaseServerName and DataWarehouseDBServerName for the Management Server $MS" >>"$cur\log.txt"
"*********************************************************************************************************************************************************************" >>"$cur\log.txt"

    $SQLServerOpsDB = Get-SQLServerOpsDB $MS

    Write-Host "On SCOM MS $MS DatabaseServerName is updated as $SQLServerOpsDB in Registry path ['SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup']"
Write-Host "****************************************************************************************************************************************************"   
    "On SCOM MS $MS DatabaseServerName is updated as $SQLServerOpsDB in Registry path ['SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup']" >>"$cur\log.txt"
"*********************************************************************************************************************************************************************" >>"$cur\log.txt"

    $SQLServerOpsDBRegistry = Get-SQLServerOpsDBRegistry $MS
    
    Write-Host "On SCOM MS $MS DatabaseServerName is updated as $SQLServerOpsDBRegistry in Registry path ['SOFTWARE\Microsoft\System Center\2010\Common\Database']"
Write-Host "****************************************************************************************************************************************************"   
    "On SCOM MS $MS DatabaseServerName is updated as $SQLServerOpsDBRegistry in Registry path ['SOFTWARE\Microsoft\System Center\2010\Common\Database']" >>"$cur\log.txt"
"*********************************************************************************************************************************************************************" >>"$cur\log.txt"
   
    $SQLServerOpsDW = Get-SQLServerOpsDW $MS

    Write-Host "On SCOM MS $MS DataWarehouseDBServerName is updated as $SQLServerOpsDW in Registry path ['SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup']"
Write-Host "****************************************************************************************************************************************************"
    "On SCOM MS $MS DataWarehouseDBServerName is updated as $SQLServerOpsDW in Registry path ['SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Setup']" >>"$cur\log.txt"
"*********************************************************************************************************************************************************************" >>"$cur\log.txt"
    
    Write-Host "Exporting TLS keys for Server $MS" -ForegroundColor Green
Write-Host "***********************************************"
   
   if (Test-path "$cur\TLSKeys_$MS.txt")

    {
    Remove-Item -Path "$cur\TLSKeys_$MS.txt" -Force
    
    }
    
    GetTLSKeys $MS

    $SchUseStrongCrypto = Get-SchUseStrongCrypto $MS

    If($SchUseStrongCrypto)
    { 
        If($SchUseStrongCrypto -eq '1')
        {
        Write-Host "On SCOM Management Server $MS, SchUseStrongCrypto is Enabled with value $SchUseStrongCrypto here ['SOFTWARE\Microsoft\.NETFramework\v4.0.30319']" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, SchUseStrongCrypto is Enabled with value $SchUseStrongCrypto here ['SOFTWARE\Microsoft\.NETFramework\v4.0.30319']" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, SchUseStrongCrypto is Disabled with the value $SchUseStrongCrypto here ['SOFTWARE\Microsoft\.NETFramework\v4.0.30319']" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, SchUseStrongCrypto is Disabled with the value $SchUseStrongCrypto here ['SOFTWARE\Microsoft\.NETFramework\v4.0.30319']" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    Else
    {
        Write-Host "On SCOM Management Server $MS, Key SchUseStrongCrypto is not avilable here ['SOFTWARE\Microsoft\.NETFramework\v4.0.30319']" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key SchUseStrongCrypto is not avilable here ['SOFTWARE\Microsoft\.NETFramework\v4.0.30319']" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }

    $SchUseStrongCrypto1 = Get-SchUseStrongCrypto1 $MS

    If($SchUseStrongCrypto1)
    { 
        If($SchUseStrongCrypto1 -eq '1')
        {
        Write-Host "On SCOM Management Server $MS, SchUseStrongCrypto is Enabled with value $SchUseStrongCrypto1 here ['SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319']" -ForegroundColor Green
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, SchUseStrongCrypto is Enabled with value $SchUseStrongCrypto1 here ['SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319']" >>"$cur\log.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\log.txt"
        }
        Else
        {
        Write-Host "On SCOM Management Server $MS, SchUseStrongCrypto is Disabled with the value $SchUseStrongCrypto1 here ['SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319']" -ForegroundColor Yellow
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, SchUseStrongCrypto is Disabled with the value $SchUseStrongCrypto1 here ['SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319']" >>"$cur\DiffValuelog.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\DiffValuelog.txt"
        }
    }
    
    Else
    
    {
        Write-Host "On SCOM Management Server $MS, Key SchUseStrongCrypto is not avilable here ['SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319']" -ForegroundColor Red
        Write-Host "*********************************************************************************************************************************************************************" -ForegroundColor White
        "On SCOM Management Server $MS, Key SchUseStrongCrypto is not avilable here ['SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319']" >>"$cur\NotFound.txt"
        "*********************************************************************************************************************************************************************" >>"$cur\NotFound.txt"
    }

 }   
