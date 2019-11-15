<#  
.SYNOPSIS  
    This script test connectivity to devices.
.DESCRIPTION  
    Script takes IP addresses from file (one IP per line) and test ICMP (ping)
.NOTES  
    File Name      : test_dns.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Version        : 20191107
    Copyright 2015 - Jiri Kindl
.LINK  
    
.EXAMPLE  
    .\test_dns.ps1 -inputfile devices2test.txt
#>

#pars parametrs with param

param([string]$inputfile, [switch]$reverse, [switch]$help)

Function usage {
  "test_dns.ps1 -inputfile inputfile.txt"
  "inputfile - file with IPs one per line"
  "reverse - do reverse resolution"
  exit
}

if ((!$inputfile) -or ($help)) {
  usage
}

try {
  $hosts=get-content $inputfile -ErrorAction Stop
  "Name,IP"
  Foreach ($hostname in $hosts) {
    try {
      $hostname=$hostname.trim()
      if ($reverse){
        $dnsResultString = [System.Net.Dns]::GetHostEntry($hostname).HostName
      }
      else {
        $dnsResult = [System.Net.Dns]::GetHostAddresses($hostname)
        $dnsResultString = $dnsResult.IPAddressToString
      }
    }
    catch {
      $dnsResultString = $Error[0]
    }
    "$hostname,$dnsResultString"
  }
}
catch [System.Management.Automation.ItemNotFoundException] {
  "Error: No such file: $inputfile"
  ""
  usage
}
catch {
  $Error
}
