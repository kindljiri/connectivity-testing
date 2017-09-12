<<<<<<< HEAD
<#  
.SYNOPSIS  
    Bind to TCP and listen
.DESCRIPTION  
    Bind to TCP and listen
.NOTES  
    File Name      : PortListener.ps1
    Version        : 1.1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2015 - Jiri Kindl
.LINK  
    
.EXAMPLE  
    .\PortListener.ps1 -port NUM
#>

#pars parametrs with param

param([int]$port = 80)
write-host "Opening port listener on", $port
#[console]::Title = ("Server: $env:Computername <{0}> on $port" -f [net.dns]::GetHostAddresses($env:Computername))[0].IPAddressToString
$endpoint = new-object System.Net.IPEndPoint ([system.net.ipaddress]::any, $port)
$listener = new-object System.Net.Sockets.TcpListener $endpoint
try {
  $listener.start()
  [byte[]]$bytes = 0..255|%{0}
  $client = $listener.AcceptTcpClient()
  write-host "Waiting for a connection on port $port..."
  write-host "Connected from $($client.Client.RemoteEndPoint)"
  $stream = $client.GetStream()
  while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
    $bytes[0..($i-1)]|%{$_}
    if ($Echo){$stream.Write($bytes,0,$i)}
  }
  $client.Close()
  write-host "Connection closed."
  $listener.Stop()
}
catch {
  write-host $error[0]
  write-host "Check there isn't other service listening on the port", $port
  write-host "use option -port NUM to specifi custome port"
=======
<#  
.SYNOPSIS  
    Bind to TCP and listen
.DESCRIPTION  
    Bind to TCP and listen
.NOTES  
    File Name      : PortListener.ps1
    Version        : 1.1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2015 - Jiri Kindl
.LINK  
    
.EXAMPLE  
    .\PortListener.ps1 -port NUM
#>

#pars parametrs with param

param([int]$port = 80)
write-host "Opening port listener on", $port
#[console]::Title = ("Server: $env:Computername <{0}> on $port" -f [net.dns]::GetHostAddresses($env:Computername))[0].IPAddressToString
$endpoint = new-object System.Net.IPEndPoint ([system.net.ipaddress]::any, $port)
$listener = new-object System.Net.Sockets.TcpListener $endpoint
try {
  $listener.start()
  [byte[]]$bytes = 0..255|%{0}
  $client = $listener.AcceptTcpClient()
  write-host "Waiting for a connection on port $port..."
  write-host "Connected from $($client.Client.RemoteEndPoint)"
  $stream = $client.GetStream()
  while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
    $bytes[0..($i-1)]|%{$_}
    if ($Echo){$stream.Write($bytes,0,$i)}
  }
  $client.Close()
  write-host "Connection closed."
  $listener.Stop()
}
catch {
  write-host $error[0]
  write-host "Check there isn't other service listening on the port", $port
  write-host "use option -port NUM to specifi custome port"
>>>>>>> origin/master
}