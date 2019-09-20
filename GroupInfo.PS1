##################################################################

<#Purpose: This script will help you to identify in how many groups the server is part of #>

# You need to copy this GroupInfo.PS1 file to a location on your Management Server.

# How to Run: GroupInfo.PS1 -computername ServerNameWithFQDN

##################################################################

[CmdletBinding()]


param (

[parameter(mandatory=$true,position=1)]

  [string[]]$computername
 
     )

Import-Module Operationsmanager

$array=@{};

# Declare object to find

$stringObject=”$computername”

# Find and save the Scom object

$Class = Get-SCOMClass -name “Microsoft.SystemCenter.Agent”

$objectToFind = Get-SCOMClassInstance -Class $class | ? {$_.Name -like $stringObject}

# If object is null exit

If (!($objectToFind))

{

Write-Host “The Server doesn't have any SCOM agent installed” -ForegroundColor Yellow

exit;
}


# Obtain groups

$groups = (Get-SCOMGroup).DisplayName

# Find the object in each group

foreach ($group in $groups)

{

$Groupinfo = Get-SCOMGroup -DisplayName "$group" -ErrorAction SilentlyContinue

if ($Groupinfo -ne $Null)

{

#Write-Host "Group $group"

$groupMembers = $Groupinfo.GetMonitoringRelationshipObjects()

# If group contain members…

if($groupMembers.Count -ne 0)

{

# Compare each member group with the object to find

foreach ($groupMember in $groupMembers)

{

#Write-Host "Group $group"

if ($groupMember.TargetMonitoringObject -match $objectToFind)

{

# Add group to array

$array.$objectToFind += (“$group, “);

}

}

}

}

}

$array.GetEnumerator() | Sort-Object Name | Out-GridView

