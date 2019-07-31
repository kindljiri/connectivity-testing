<#  
.SYNOPSIS  
    This script test connectivity to devices.        
.DESCRIPTION  
    Script takes IP addresses from file (one IP per line) and test TCP port connection.
.NOTES  
    File Name      : connectivity_test.ps1 
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Version        : 20190328
    Copyright 2015 - Jiri Kindl    
.LINK  
    
.EXAMPLE  
    .\connectivity_test.ps1 -inputfile intputfile.txt -troubleshoot
#>

#pars parametrs with param

param([string]$inputfile = "default",
[switch]$troubleshoot
)

Function usage {
  "connectivity_test.ps1 -inputfile inputfile.txt [-troubleshoot]"
  "inputfile - file with deviceFQDN,port pairs one pair per line, (IPs can be used as well instead of FQDN)"
  exit
}

Function troubleshoot
{
  Param($dest,$port)
  echo '============================================================'
  echo " Source:            $source"	
  echo " Destination:       $dest"
  echo " Destination Port:  $port"
  echo ""
  #echo "ICMP Tracerute results:"  
  tnc -TraceRoute $dest 
}

try {
  $connections=get-content $inputfile -ErrorAction Stop

  $source = hostname
  $inputfile_base = ($inputfile -split '\\')[-1] 
  $inputfile_base = ($inputfile_base -split "\.")[0]
  $troubleshootfile="troubleshoot_"+ $inputfile_base +".txt"
  
  if ($troubleshoot){
    echo "SOURCE INFO:" > $troubleshootfile
    echo "------------" >> $troubleshootfile
    echo -n "Source name: ">> $troubleshootfile
    hostname >> $TFILE
    echo "Routing Table:">>$troubleshootfile
    echo "--------">> $troubleshootfile
    netstat -rn >> $troubleshootfile

  }

    "Source,Destination,Port,Result"
    Foreach ($connection in $connections) {
      ($ip,$port)= $connection -split ","
      $t = New-Object Net.Sockets.TcpClient
      try {
        $t.Connect($ip,$port)
        $TCPTestResult = $t.Connected
        $t.Close()
      }
      catch [System.Net.Sockets.SocketException] {
        $TCPTestResult = $error[0].ToString()
        if ($TCPTestResult -CMatch 'A connection attempt failed because the connected party did not properly respond after a period of time') {
          $TCPTestResult = "Time out"
          if ($troubleshoot) {
            troubleshoot $ip $port 2>&1 >> $troubleshootfile
          }
        }
        elseif ($TCPTestResult -CMatch 'No connection could be made because the target machine actively refused') {
          $TCPTestResult = "Connection refused"
          if ($troubleshoot) {
            troubleshoot $ip $port 2>&1 >> $troubleshootfile
          }
        }
        elseif ($TCPTestResult -CMatch 'No such host is known') {
          $TCPTestResult = "DNS Issue: No such host is known"
        }
      }
      catch {
        $TCPTestResult = "no connectivity" #FALSE
        if ($troubleshoot) {
          troubleshoot $ip $port 2>&1 >> $troubleshootfile 
        }
      }

      "$source,$ip,$port,$TCPTestResult"
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
