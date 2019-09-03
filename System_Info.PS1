###New Code###
##################################################################
#Author: Sourav Mahato
#Created Date:01/05/2015
#Purpose: Script to get the details of the System with a Single PowerShell Script######
##################################################################

$Cur = Get-Location

if (Test-path "$cur\SystemInfo.xlsx")

{
  Remove-Item -Path "$cur\SystemInfo.xlsx" -Force
}

if (Test-path "$cur\hello.htm")

{
  Remove-Item -Path "$cur\hello.htm" -Force
}


$excel = New-Object -comobject Excel.Application
$excel.Visible = $True
$workbook = $excel.Workbooks.Add()
$Worksheets = $workbook.Worksheets.Item(1)

#Adding Row and Column Name in Excel as per Requirement

$Worksheets.Cells.Item(1,1) = "Computer Name"
$Worksheets.Cells.Item(1,2) = "Domain Name"
$Worksheets.Cells.Item(1,3) = "Processor Name"
$Worksheets.Cells.Item(1,4) = "Ram Details(GB)"
$Worksheets.Cells.Item(1,5) = "System Type"
$Worksheets.Cells.Item(1,6) = "ARCHITECTURE"
$Worksheets.Cells.Item(1,7) = "NIC Card Details"
$Worksheets.Cells.Item(1,8) = "IP Address"
$Worksheets.Cells.Item(1,9) = "Free Space C"
$Worksheets.Cells.Item(1,10) = "Free Space D"
$Worksheets.Cells.Item(1,11) = "Avrg.CPU Utilization"
$Worksheets.Cells.Item(1,12) = "Memory Utilization"

#Adding some colorcode As per your choice

$UsedRange = $Worksheets.UsedRange 
$UsedRange.Interior.ColorIndex = 34
$UsedRange.Font.ColorIndex = 11 
$UsedRange.Font.Bold = $True
$UsedRange.Font.Size = 13
$UsedRange.Font.Name = "Cambria"
$UsedRange.Font.ThemeColor = 6
$intRow = 2

$Servers = "MININT-LE7CRIG" #Get-Content $Cur\Servers.txt
$Result = @()
foreach ($Server in $Servers)

{
    $CompSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Server
    $domain = $CompSystem.Domain
    $Ram = $CompSystem.TotalPhysicalMemory/1GB
    $Ram = "{0:N2}" -f $Ram
    $SysType = $CompSystem.SystemType
    $Systemtypes = $SysType.split("-")
    $Systemtype = $Systemtypes[0]

    $Processor = (Get-WmiObject Win32_Processor -ComputerName $server).name
    $ProSplit = $Processor.split(" ")
    $Proc1 = $ProSplit[0]
    $Proc2 = $ProSplit[2]
    $ProcessorName = $Proc1 + $Proc2

    $PROCESSOR_ARCHITECTURE = (Get-WmiObject win32_environment -computername $SERVER | where { $_.name -eq 'PROCESSOR_ARCHITECTURE'}).VariableValue

    $AVGProc = Get-WmiObject -computername $SERVER win32_processor
    $CpuUage = $AVGProc.LoadPercentage
    $OS = gwmi -Class win32_operatingsystem -computername $SERVER
    $TotalVisibleMemorySize = $OS.TotalVisibleMemorySize
    $FreePhysicalMemory = $OS.FreePhysicalMemory
    $MemoryUsage = (($TotalVisibleMemorySize - $FreePhysicalMemory) / $TotalVisibleMemorySize) * 100
    $MemoryUsage = "{0:N2}" -f $MemoryUsage

    $Nic = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $Server | Where {$_.DHCPEnabled -match 'true'}
    $NICCard = $Nic.Description
    $IPaddress = $Nic.IPAddress
    $IPs = $IPaddress.Split( " ")
    $IP = $IPs[0]

    $CDiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='C:'"
    $DDiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='D:'"
    $C_DriveFreeSpace = $CDiskInfo.FreeSpace/1GB
    $C_DriveFreeSpace = "{0:N2}" -f $C_DriveFreeSpace
    $ActualSizeOfC = $CDiskInfo.Size / 1GB
    $D_DriveFreeSpace = $DDiskInfo.FreeSpace/1GB
    $D_DriveFreeSpace = "{0:N2}" -f $D_DriveFreeSpace
    $ActualSizeOfD = $DDiskInfo.Size / 1GB
    $C_PercentageFreeSpace = $C_DriveFreeSpace/$ActualSizeOfC * 100
    $C_PercentageFreeSpace = "{0:N2}" -f $C_PercentageFreeSpace
    $D_PercentageFreeSpace = $D_DriveFreeSpace/$ActualSizeOfD * 100
    $D_PercentageFreeSpace = "{0:N2}" -f $D_PercentageFreeSpace

    $Worksheets.Cells.Item($intRow,1) = "$Server"
    $Worksheets.Cells.Item($intRow,2) = "$domain"
    $Worksheets.Cells.Item($intRow,3) = "$ProcessorName"
    $Worksheets.Cells.Item($intRow,4) = "$Ram GB"
    $Worksheets.Cells.Item($intRow,5) = "$SystemType Bit"
    $Worksheets.Cells.Item($intRow,6) = "$PROCESSOR_ARCHITECTURE"
    $Worksheets.Cells.Item($intRow,7) = "$NICCard"
    $Worksheets.Cells.Item($intRow,8) = "$IP"
    $Worksheets.Cells.Item($intRow,9) = "$C_PercentageFreeSpace %, $C_DriveFreeSpace GB"
    $Worksheets.Cells.Item($intRow,10) ="$D_PercentageFreeSpace %, $D_DriveFreeSpace GB"
    $Worksheets.Cells.Item($intRow,11) ="$CpuUage %"
    $Worksheets.Cells.Item($intRow,12) ="$MemoryUsage %"

    $intRow++

    $result += [PSCustomObject] @{  
        ServerName = "$Server" 
        domain = "$domain" 
        ProcessorName = "$ProcessorName" 
        Ram = "$($Ram) GB" 
        SystemType = "$($SystemType) Bit" 
        PROCESSOR_ARCHITECTURE = "$PROCESSOR_ARCHITECTURE" 
        NICCard = "$($NICCard)"
        IP = "$IP" 
        C_PercentageFreeSpace = "$($C_PercentageFreeSpace) %" 
        D_PercentageFreeSpace = "$($D_PercentageFreeSpace) %" 
        CpuUage = "$($CpuUage) %" 
        MemoryUsage = "$($MemoryUsage) %" 
    } 
 
    $Outputreport = "<HTML><TITLE> Server Health Report </TITLE> 
                     <BODY background-color:peachpuff> 
                     <font color =""#99000"" face=""Microsoft Tai le""> 
                     <H2> Server Health Report </H2></font> 
                     <Table border=1 cellpadding=0 cellspacing=0> 
                     <TR bgcolor=gray align=center> 
                       <TD><B>Server Name</B></TD> 
                       <TD><B>domain</B></TD> 
                       <TD><B>ProcessorName</B></TD> 
                       <TD><B>Ram Details</B></TD>
                       <TD><B>SystemType</B></TD> 
                       <TD><B>ARCHITECTURE</B></TD> 
                       <TD><B>NIC Card Details</B></TD> 
                       <TD><B>IP Address</B></TD>                     
                       <TD><B>C Drive FreeSpace</B></TD> 
                       <TD><B>D Drive FreeSpace</B></TD> 
                       <TD><B>Avrg.CPU Utilization</B></TD> 
                       <TD><B>Memory Utilization</B></TD></TR>" 
                                    
    Foreach($Entry in $Result)  
     
        {  
          if($Entry.CpuUage -ge 80 -or $Entry.MemoryUsage -ge "80" -or $Entry.C_PercentageFreeSpace -le "20" -or $Entry.D_PercentageFreeSpace -le "20"  )  
          {  
            $Outputreport += "<TR bgcolor=Red>"  
          }  
          else 
           { 
            $Outputreport += "<TR bgcolor=Green>"  
          } 
          $Outputreport += "<TD>$($Entry.Servername)</TD><TD align=center>$($Entry.domain)</TD><TD align=center>$($Entry.ProcessorName)</TD><TD align=center>$($Entry.Ram)</TD><TD align=center>$($Entry.SystemType)</TD><TD align=center>$($Entry.PROCESSOR_ARCHITECTURE)</TD><TD align=center>$($Entry.NICCard)</TD><TD align=center>$($Entry.IP)</TD><TD align=center>$($Entry.C_PercentageFreeSpace)</TD><TD align=center>$($Entry.D_PercentageFreeSpace)</TD><TD align=center>$($Entry.CpuUage)</TD><TD align=center>$($Entry.MemoryUsage)</TD></TR>"  
        } 
     $Outputreport += "</Table></BODY></HTML>"  
        }  
  
$Outputreport | out-file $cur\hello.htm  
Invoke-Expression $cur\hello.htm


#Auto fit everything so it looks better

$usedRange = $Worksheets.UsedRange	
$usedRange.EntireColumn.AutoFit()

$workbook.SaveAs("$cur\SystemInfo.xlsx")
$excel.Quit()
