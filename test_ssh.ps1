<#  
.SYNOPSIS  
    This script test connectivity to devices.
.DESCRIPTION  
    Script takes IPs/Hosts from file (one IP/Host per line) and test if can login to SSH
.NOTES  
    File Name      : test_ssh.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Version        : 201906295
    Copyright 2019 - Jiri Kindl
.LINK  
    
.EXAMPLE  
    .\test_ssh.ps1 -inputfile inputfile.txt -username YourUserName -password YourPassword
#>

#pars parametrs with param

param([string]$inputfile = "default", [string]$username = "test", [string]$password = "ptest")

Function usage {
  "test_ssh.ps1 -inputfile inputfile.txt -username YourUserName -password YourPassword"
  "inputfile - file with IPs one per line"
  exit
}

$user = "$username"

$pass = convertto-securestring -String "$password" -AsPlainText -Force
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$pass


try {
  $ips=get-content $inputfile -ErrorAction Stop
  "IP,SSH"
  Foreach ($ip in $ips) {
      $ip = $ip.trim()
      $SSHResult = New-SSHSession -computername $ip -Credential $credential -AcceptKey
      if ($SSHResult.Connected) {
        $SSHResultString = $SSHResult.Connected
        Remove-SSHSession -SessionId $SSHResult.SessionId
      }
      else {
        $SSHResultString = $Error[0]
      }      
    "$ip,$SSHResultString"
  }
}
catch [System.Management.Automation.ItemNotFoundException] {
  "No such file"
  ""
  usage
}
catch {
  #$Error[0]
}
