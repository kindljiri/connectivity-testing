<#  
.SYNOPSIS  
    This script test connectivity to devices.
.DESCRIPTION  
    Script takes IP addresses from file (one IP per line) and test ICMP (ping)
.NOTES  
    File Name      : test_icmp.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2015 - Jiri Kindl
.LINK  
    
.EXAMPLE  
    .\test_icmp.ps1
#>

#pars parametrs with param

param([string]$inputfile = "default")

Function usage {
  "test_icmp.ps1 -inputfile inputfile.txt"
  "inputfile - file with IPs one per line"
  exit
}

try {
  $ips=get-content $inputfile -ErrorAction Stop
  "IP,ICMP"
  Foreach ($ip in $ips) {
    try {
      $ping = New-Object System.Net.Networkinformation.ping
      $pingResult =$ping.Send($ip)
      $pingResultString = $pingResult.Status
    }
    catch {
      $pingResultString = $Error[0]
    }
    "$ip,$pingResultString"
  }
}
catch [System.Management.Automation.ItemNotFoundException] {
  "No such file"
  ""
  usage
}
catch {
  $Error[0]
}
