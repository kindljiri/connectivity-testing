<#  
.SYNOPSIS  
    This script test connectivity to devices.        
.DESCRIPTION  
    Script takes IP addresses from file (one IP per line) and test TCP port connection.
.NOTES  
    File Name      : autotrblsht.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2015 - Jiri Kindl    
.LINK  
    
.EXAMPLE  
    .\test_tcp.ps1
#>

#pars parametrs with param

param([string]$inputfile = "default",
[int]$port = 5895
)

Function usage {
  "test_tcp.ps1 -inputfile inputfile.txt [-port NUMBER]"
  "inputfile - file with IPs one per line"
  "port NUMBER - number of port to test, default is 5895"
  exit
}

try {
  $ips=get-content $inputfile -ErrorAction Stop
  
  "Host/IP,Port $port"

  Foreach ($ip in $ips) {
    $t = New-Object Net.Sockets.TcpClient
    try {
      $t.Connect($ip,$port)
      $TCPTestResult = $t.Connected
    }
    catch {
      $TCPTestResult = "no connectivity" #FALSE
    }

    "$ip,$TCPTestResult"
}
}
catch [System.Management.Automation.ItemNotFoundException] {
  "No such file"
  ""
  usage
}
catch {
  $Error
}
