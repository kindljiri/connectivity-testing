<#  
.SYNOPSIS  
    This script test connectivity to devices.
.DESCRIPTION  
    Script takes IPs/Hosts from file (one IP/Host per line) and test if can login to SSH
.NOTES  
    File Name      : test_ssh.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Version        : 20191122
    Copyright 2019 - Jiri Kindl
.LINK  
    
.EXAMPLE  
    .\test_ssh.ps1 -inputfile inputfile.txt -username YourUserName -password YourPassword -commad uname
#>

#pars parametrs with param

param([string]$inputfile = "default", [string]$username = "test", [string]$password = "ptest", [string]$command, [switch]$help)

Function usage {
  "test_ssh.ps1 -inputfile inputfile.txt [-username YourUserName] [-password YourPassword] [-command] [-help]"
  "inputfile - file with IPs one per line"
  "username - provide username if not provided, you'll be asked"
  "password - provide password if not provided, you'll be asked, it's safer to not provide if poweshell keeps history"
  "command - command to be executed remotely, if not provided it test just ability to login"
  "help - print this help" 
  exit
}

if (!($inputfile) -or ($help)) {
  usage
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
        if ($command) {
          $SSHCommandResult = Invoke-SSHCommand -SessionId $SSHResult.SessionId -Command $command
        }
        Remove-SSHSession -SessionId $SSHResult.SessionId
      }
      else {
        $SSHResultString = $Error[0]
      }      
    "$ip,$SSHResultString"
    if ($command -and ($SSHResultString -eq "True")) {
      $SSHCommandResult
    }
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
