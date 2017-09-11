<#  
.SYNOPSIS  
    This script test connectivity to devices.
.DESCRIPTION  
    Script takes IPs/Hosts from file (one IP/Host per line) and test WMI
.NOTES  
    File Name      : test_wmi.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2015 - Jiri Kindl
.LINK  
    
.EXAMPLE  
    .\test_wmi.ps1 -inputfile inputfile.txt -username YourUserName -password YourPassword
#>

#pars parametrs with param

param([string]$inputfile = "default", [string]$username = "test", [string]$password = "ptest")

Function usage {
  "test_wmi.ps1 -inputfile inputfile.txt -username YourUserName -password YourPassword"
  "inputfile - file with IPs one per line"
  exit
}

$user = "$username"

$pass = convertto-securestring -String "$password" -AsPlainText -Force
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$pass


try {
  $ips=get-content $inputfile -ErrorAction Stop
  "IP,WMI"
  Foreach ($ip in $ips) {
    if(-not (Test-Connection -Quiet $ip -Count 1)) {
     $wmiResultString = "Can't connect"
    }
    else {
      try {
        $wmi = Get-WmiObject -computername $ip -Credential $credential Win32_Computersystem | Select-Object -Property Name
        $wmiResultString = $wmi.name
      }
      catch {
        $wmiResultString = $Error[0]
      }
    }
    "$ip,$wmiResultString"
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
