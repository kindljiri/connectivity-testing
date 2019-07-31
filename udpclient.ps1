<#  
.SYNOPSIS  
    UDP client        
.DESCRIPTION  
    UDP client which only send one message
.NOTES  
    File Name      : udpclient.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Version        : 20190730
    Copyright 2019 - Jiri Kindl    
.LINK  
    
.EXAMPLE  
    .\udpclient.ps1 -device example.com -port 162 -message "Hello world"
#>

#pars parametrs with param
Param ([string] $device, 
[int] $port, 
[string] $message = "hello")

Function usage {
  "udpclient.ps1 -device FQDNorIP -port NUMBER -message sometext"
  "device - file with IPs one per line"
  "port NUMBER - number of port to test"
  "message to send - by default hello"
  exit
}

if ((!$device) -or (!$port)) {
  usage
}

if ($device -match '(\d{1,3}\.){3}\d{1,3}') {
  echo $device
  $Address = [System.Net.IPAddress]$device.trim()
} else {
  $IP = [System.Net.Dns]::GetHostAddresses($device) 
  $Address = [System.Net.IPAddress]::Parse($IP)
}
#$IP = [System.Net.Dns]::GetHostAddresses($device) 
#$Address = [System.Net.IPAddress]::Parse($IP)
$EndPoints = New-Object System.Net.IPEndPoint($Address, $port) 
$Socket = New-Object System.Net.Sockets.UDPClient 
$EncodedText = [Text.Encoding]::ASCII.GetBytes($message) 
$SendMessage = $Socket.Send($EncodedText, $EncodedText.Length, $EndPoints)
$Socket.Close()