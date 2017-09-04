Import-Module -Name WebAdministration

#region Checks
Function Invoke-CheckSites {
$Server = $env:COMPUTERNAME 
$Samples = 2
$Interval = 2

$SiteName = Get-ChildItem -Path IIS:\Sites | select -expand name 

Foreach ($Site in $SiteName)
{
#remove sapace and replace with underscore for each site
$siteNospace = $Site.replace(" ","_")

#Connection counters per site
#$Counter_Attempts = Get-Counter "\\$server\Web Service($site)\Connection Attempts/sec"| select -expandproperty CounterSamples | select -expand CookedValue
$Counter_Current = Get-WmiObject Win32_PerfFormattedData_W3SVC_WebService -Filter "name='$site'" | select -exp currentconnections
$Counter_MaxCon = Get-WmiObject Win32_PerfFormattedData_W3SVC_WebService -Filter "name='$site'" | select -exp MaximumConnections
  


$state = Get-ChildItem -Path IIS:\Sites | Where-Object {$_.name -eq "$site"} | Select-Object -Property State -ExpandProperty State
if ($state -EQ "Stopped"){
$statuscode = 2
$desc = "Site Stopped"
}
ElseIf ($state -EQ "Started"){
$statuscode = 0
$desc = "running - current connections = $Counter_Current"
}
Else {
$statuscode = 3
$desc = "Something has gone wrong with this local check"
}
$status = "$statuscode IIS_Site_$siteNospace CurrentConnections=$Counter_Current|MaxConnections=$Counter_MAxCon $desc "
$status 
}
}
Function Invoke-CheckAppPools {
$AppoolName = Get-ChildItem -Path IIS:\AppPools | select -expand name 


Foreach ($pool in $AppoolName)
{
$poolNospace = $pool.replace(" ","_")
$state = Get-ChildItem -Path IIS:\AppPools | Where-Object {$_.name -eq "$pool"} | Select-Object -Property State -ExpandProperty State
if ($state -EQ "Stopped"){
$statuscode = 2
$desc = "Application Pool is Stopped"
}
ElseIf ($state -EQ "Started"){
$statuscode = 0
$desc = "Application Pool is Running"
}
Else {
$statuscode = 3
$desc = "Somthing has gone wrong with this local check"
}
$status = "$statuscode AppPool_$poolNospace - $desc "
$status 
}
}

#endregion checks

#region Main
Invoke-CheckAppPools
Invoke-CheckSites

#endregion Main