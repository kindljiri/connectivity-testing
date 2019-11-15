<#  
.SYNOPSIS  
    This script test connectivity to devices.
.DESCRIPTION  
    Script takes IPs/Hosts from file (one IP/Host per line) and test WMI
.NOTES  
    File Name      : test_wmi.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Version        : 20191107
    Copyright 2015 - Jiri Kindl
.LINK  
    
.EXAMPLE  
    .\test_wmi.ps1 -inputfile inputfile.txt -username YourUserName -password YourPassword
#>

#pars parametrs with param

param([string]$inputfile, [string]$username, [string]$password, [string]$namespace="root\cimv2", [string]$class="Win32_Computersystem", [string]$select="name", [switch]$help )

Function usage {
  "test_wmi.ps1 -inputfile inputfile.txt [-username YourUserName] [-password YourPassword]"
  "inputfile - file with Hosts,FQDN or IPs one per line"
  "username - username, if it's domain user use 'domain\username', if not provided you'll be asked interactively"
  "password - password, if not provided you'll be asked interactively"
  exit
}

if (!($inputfile) -or ($help)) {
  usage
}

if (($username) -and ($password)) {
  $user = "$username"

  $pass = convertto-securestring -String "$password" -AsPlainText -Force
  $credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$pass
}
else {
  $credential = Get-Credential -Message "WMI credentials" -UserName $Username
}

try {
  $ips=get-content $inputfile -ErrorAction Stop
  "IP,WMI"
  Foreach ($ip in $ips) {
    $ip = $ip.trim()
    try {
      $wmi = Get-WmiObject -computername $ip -Credential $credential -Namespace $namespace -Class $class  -ErrorAction Stop| Select-Object -Property Name
      $wmiResultString = $wmi.$select
    }
    catch [System.Runtime.InteropServices.COMException] {
      $wmiResultString = $Error[0]
    }
    catch {
      $wmiResultString = $Error[0]
    }
    "$ip,$wmiResultString"
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
