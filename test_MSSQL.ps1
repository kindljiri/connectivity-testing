<#  
.SYNOPSIS  
    This script test connectivity to devices.
.DESCRIPTION  
    Script takes IPs/Hosts from file (one IP/Host per line) and test WMI
.NOTES  
    File Name      : test_MSSQL.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Version        : 20190811
    Copyright 2015 - Jiri Kindl
.LINK  
    
.EXAMPLE  
    .\test_wmi.ps1 -inputfile inputfile.csv -username YourUserName -password YourPassword
#>

#pars parametrs with param
param([string]$inputfile, [string]$username, [string]$password)

Function usage {
  "test_wmi.ps1 -inputfile inputfile.csv [-username YourUserName] [-password YourPassword]"
  "inputfile - csv file which contains pairs 'Hostname,Database Name' one per line" 
  "username - username, if it's domain user use 'domain\username', if not provided you'll be asked interactively"
  "password - password, if not provided you'll be asked interactively"
  exit
}

if (!($inputfile)) {
  usage
}
if (($username) -and ($password)) {
  $Username = "$username"
  $Password = "$password"
}
else {
  $credential = Get-Credential -Message "MSSQL credentials" -UserName $username
  $Username = $Credential.UserName
  $Password = $Credential.GetNetworkCredential().Password
}

try {
  $DBs=get-content $inputfile -ErrorAction Stop
  "HostName,DBName,Connection Status"
  Foreach ($DB in $DBs) {
    ($ServerName,$DatabaseName) = $DB -split ","
    $ServerName = $ServerName.trim()
    $DatabaseName = $DatabaseName.trim()
    try {
        $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$Username,$Password
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $sqlConnection.Open()
        ## This will run if the Open() method does not throw an exception
        "$ServerName,$DatabaseName,$true"
     } 
     catch {
        "$ServerName,$DatabaseName,$false"
     }
     finally {
        ## Close the connection when we're done
        $sqlConnection.Close()
     }
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