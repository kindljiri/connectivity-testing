<#  
.SYNOPSIS  
    Bind to TCP or UDP port and listen
.DESCRIPTION  
    Bind to TCP or UDP port and listen, if switch -udp not used by default it listen on TCP
.NOTES  
    File Name      : PortListener.ps1
    Version        : 20180830  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
.LINK  
    
.EXAMPLE  
    .\PortListener.ps1 -port NUM
#>

#pars parametrs with param

param([int]$port = 80,[switch]$udp)

function udp-listen($udpport) {
    $endpoint = New-Object System.Net.IPEndPoint ([IPAddress]::Any,$udpport)
    $udpclient = New-Object System.Net.Sockets.UdpClient $udpport
    $content=$udpclient.Receive([ref]$endpoint)
    [Text.Encoding]::ASCII.GetString($content)
} 

function tcp-listen($tcpport) {
  $endpoint = new-object System.Net.IPEndPoint ([system.net.ipaddress]::any, $tcpport)
  $listener = new-object System.Net.Sockets.TcpListener $endpoint
  try {
    $listener.start()
    [byte[]]$bytes = 0..255|%{0}
    $client = $listener.AcceptTcpClient()
    write-host "Waiting for a connection on port $tcpport..."
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
    write-host "Check there isn't other service listening on the port", $tcpport
    write-host "use option -port NUM to specifi custome port"
  }
}

write-host "Opening port listener on", $port
if ($udp) {
  write-host "Opening port listener on UDP", $port
  udp-listen $port
}
else{
  write-host "Opening port listener on TCP", $port
  tcp-listen $port
}
