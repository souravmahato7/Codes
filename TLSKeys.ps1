#################################################################################################
#Author: Sourav Mahato
#Created Date:11/14/2020
#Purpose: Script for Get the TLS Settings
#How to run: PS C:\Script> .\TLS.ps1
## Create a text file called Servers.txt in the same location where you have saved this Script (This is optional, if you didn't create, then this Script will only for one server at a time)
#################################################################################################

function GetTLSKeys($Server)  
{
    $branch = "LocalMachine"

    $ProtocolList = @("SSL 2.0","SSL 3.0","TLS 1.0", "TLS 1.1", "TLS 1.2")

	$TLSdataregistry=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($branch,$Server)

    Write-Host "Collecting Data for Server $Server" -ForegroundColor Green

    "Collecting Data for Server $Server" >> "$Cur\TLSKeys_$Server.txt"

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
           
                Write-Host "For Server $Server, Checking on $Actualpath" -ForegroundColor Magenta

                Write-Host ""

                Write-Host "Checking on path $Actualpath for DisabledByDefault Key, It is present with value $Keys1" -ForegroundColor Yellow

                "Checking on Path $Actualpath for DisabledByDefault Key, It is present with value $Keys1" >> "$Cur\TLSKeys_$Server.txt"

                $Keys2 = $TLSdataRegistrykey.GetValue("Enabled")

                Write-Host ""

                Write-Host "For Server $Server, Checking on $Actualpath for Enabled Key, It is present with value $Keys2" -ForegroundColor Yellow
                "Checking on $Actualpath for Enabled Key, It is present with value $Keys2" >> "$cur\TLSKeys_$Server.txt"
                Write-Host ""
                Write-Host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                Write-Host ""
	        }
	    
            else 
            
            {
		    
                $Keys1 = $null

                Write-Host "For Server $Server, Checking on $Actualpath for DisabledByDefault Key, It is Not present" -ForegroundColor Red
                Write-Host ""
                Write-Host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                Write-Host ""
            
                $Keys2 = $null

                Write-Host "For Server $Server, Checking on $Actualpath for Enabled Key, It is Not present" -ForegroundColor Red
                Write-Host ""
                Write-Host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                Write-Host ""
	        
            }
        }
	
	
    }
   	
	    return $Keys1
        return $Keys2 	

}



#################################################################################################
###Code start from here
#################################################################################################


$cur = Get-location

    $Servers = Get-content "$cur\Servers.txt" -ErrorAction SilentlyContinue

        if (!$Servers)

            {
                $srvs_temp = Read-host ("Enter only one server name")
                
                $Servers = $srvs_temp.Split(',')

            }


        foreach ($Server in $Servers)
        
        {

            if (Test-path "$cur\TLSKeys_$Server.txt")

            {
                Remove-Item -Path "$cur\TLSKeys_$Server.txt" -Force
            }


            GetTLSKeys "$Server"

        }
