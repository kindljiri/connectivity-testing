<#  
.SYNOPSIS  
    This script test connectivity to devices.        
.DESCRIPTION  
    Script takes IP addresses from file (one IP per line) and test TCP port connection.
.NOTES  
    File Name      : test_tcp.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Version        : 20220714
    Copyright 2015 - Jiri Kindl    
.LINK  
    
.EXAMPLE  
    .\test_tcp.ps1 -inputfile intputfile.txt -port NUMBER
#>

#pars parametrs with param

param([string]$hostfile, [string]$csvfile, [int]$port=5895, [switch]$help)

Function usage {
  "test_tcp.ps1 -hostfile testconnections.txt -csvfile testconnections.csv [-port NUMBER]"
  "  -hostfile - file with IPs one per line"
  "  -csvfile - file with deviceFQDN,port pairs one pair per line, (IPs can be used as well instead of FQDN)"
  "  -port NUMBER - number of port to test, default is 5895"
  exit
}

function test-tcp {
	param(
		[Parameter()]
		[string]$ip, [string]$port
	)
	
	$ip=$ip.trim()
  $t = New-Object Net.Sockets.TcpClient
  try {
    $t.Connect($ip,$port)
    $TCPTestResult = $t.Connected
  }
  catch [System.Net.Sockets.SocketException] {
    $TCPTestResult = $error[0].ToString()
      if ($TCPTestResult -CMatch 'A connection attempt failed because the connected party did not properly respond after a period of time') {
        $TCPTestResult = "Connection failed: Time out"
      }
      elseif ($TCPTestResult -CMatch 'No connection could be made because the target machine actively refused') {
        $TCPTestResult = "Connection failed: Connection refused"
      }
      elseif ($TCPTestResult -CMatch 'No such host is known') {
        $TCPTestResult = "Connection failed: DNS: No such host is known"
      }
  }
  catch {
    $TCPTestResult = "Connection failed" #FALSE
  }
  if ( $TCPTestResult -eq $true ) {
    $TCPTestResult = 'Connection succeeded'
  }
  $TCPTestResult

}

function hosttest {
  param([string]$hostfile)

  try {
    $ips=get-content $hostfile -ErrorAction Stop

    "Source Host,Source Ip,Destination Host,Destination Port(TCP),Result,Last Hop"
  
    Foreach ($ip in $ips) {
      $TCPTestResult = test-tcp $ip $port
      "$source_host,$source_ip,$ip,$port,$TCPTestResult,"
    }
  }
  catch [System.Management.Automation.ItemNotFoundException] {
    "No such file: $hostfile"
    ""
    usage
  }
  catch {
    $Error[0]
  }
}

function csvtest {
  param([string]$csvfile)

  try {
    $connections=get-content $csvfile -ErrorAction Stop
    
    "Source Host,Source Ip,Destination Host,Destination Port(TCP),Result,Last Hop"
  
    Foreach ($connection in $connections) {
      ($ip,$port) = $connection -split ','
      $TCPTestResult = test-tcp $ip $port
      "$source_host,$source_ip,$ip,$port,$TCPTestResult,"
    }
  }
  catch [System.Management.Automation.ItemNotFoundException] {
    "No such file: $csvfile"
    ""
    usage
  }
  catch {
    $Error[0]
  }
}

###############################################################################
#
# MAIN PROGRAM
#
##############################################################################


if (((!$hostfile) -and (!$csvfile)) -or (!$port) -or ($help)) {
  usage
}

$source_host = hostname
$source_ip = ((Get-NetIPAddress -AddressFamily IPV4).IPAddress | Where-Object { $_ -ne '127.0.0.1' }) -join ';'
$inputfile_base = ($inputfile -split '\\')[-1] 
$inputfile_base = ($inputfile_base -split "\.")[0]
$troubleshootfile="troubleshoot_"+ $inputfile_base +".txt"


if ($hostfile) {
  hosttest $hostfile
}
elseif ($csvfile) {
  csvtest $csvfile
}

#VERSION HISTORY:
#Version,Comment
#20220714,ADDED: CSV input for connection testing, and give it same output and CSV Header as its linux version