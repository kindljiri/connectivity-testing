<#  
.SYNOPSIS  
    This script test connectivity to devices.        
.DESCRIPTION  
    Script takes IP addresses from file (one IP per line) and test TCP port connection.
.NOTES  
    File Name      : test_tcp.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Version        : 20191107
    Copyright 2015 - Jiri Kindl    
.LINK  
    
.EXAMPLE  
    .\test_tcp.ps1 -inputfile intputfile.txt -port NUMBER
#>

#pars parametrs with param

param([string]$inputfile, [int]$port, [switch]$help)

Function usage {
  "test_tcp.ps1 -inputfile inputfile.txt [-port NUMBER]"
  "inputfile - file with IPs one per line"
  "port NUMBER - number of port to test, default is 5895"
  exit
}

if ((!$inputfile) -or (!$port) -or ($help)) {
  usage
}

try {
  $ips=get-content $inputfile -ErrorAction Stop
  
  "IP,TCP $port"

  Foreach ($ip in $ips) {
    $ip=$ip.trim()
    $t = New-Object Net.Sockets.TcpClient
    try {
      $t.Connect($ip,$port)
      $TCPTestResult = $t.Connected
    }
    catch [System.Net.Sockets.SocketException] {
        $TCPTestResult = $error[0].ToString()
        if ($TCPTestResult -CMatch 'A connection attempt failed because the connected party did not properly respond after a period of time') {
          $TCPTestResult = "Time out"
        }
        elseif ($TCPTestResult -CMatch 'No connection could be made because the target machine actively refused') {
          $TCPTestResult = "Connection refused"
        }
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
  $Error[0]
}
