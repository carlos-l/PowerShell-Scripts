
########################################################################
#            --           vSphere Log Collector     --
########################################################################
<# 

The tool is design to help automate the process of collecting logs 
from vCenter or ESXi and uploading directly via FTP to VMWare.

__________________________________________________________________________

Date:          28/1/2016
Author:        Carl Liebich
Source:        https://github.com/carlos-l/PowerShell-Scripts/
__________________________________________________________________________

                              Change Control
Version 1.2 - 2/3/2016
- Generation of MD5 and SHA1 hash to upload with logs
- Corrected bug for uploading logs question. 

Version 1.1 - 2/2/2016
- Replaced FTP with SFTP (Posh-SSH Module) for encrypted uploads
- validation checking of csv file. 

Version 1.0 - 28/1/2016
- Initial Release

__________________________________________________________________________
#>

########################################################################

# Set the Path to the vCenter CSV file here:
$csvlist = "C:\Scripts\vcenter-list.csv"

########################################################################

$csvcheck = test-path -Path "$csvlist"
if ($csvcheck -eq $False ) {
    write-host "ERROR: CSV file doesn't exisit, the script will now exit" -ForegroundColor "Red"
    PAUSE
    exit
}
else{
    $customerlist = import-csv -Path "$csvlist"
    }

########################################################################

$module = "Posh-SSH"
$moduleError = "ERROR: Posh-SSH has not be install on this PC. Please visit https://github.com/darkoperator/Posh-SSH to install the missing module"
Add-Type -AssemblyName System.Windows.Forms
if (Get-Module -ListAvailable -Name $module) {
    Import-Module -Name $module
    }else 
        {
        Write-Host "$moduleError" -ForegroundColor Red
        PAUSE
        EXIT
}

$module = "VMware.VimAutomation.Core"
$moduleError = "ERROR: Cannot find VMware PowerCLI module. Please make sure PowerCLI has been installed and modules are avilable."
if (Get-Module -ListAvailable -Name $module) {
    Import-Module -Name $module
    }else 
        {
        Write-Host "$moduleError" -ForegroundColor Red
        PAUSE
        EXIT
}


$host.ui.RawUI.WindowTitle = "VMWare Support Log Collector"
clear
write-host "----------------------------------------------------------------" -ForegroundColor Yellow
write-host "                vSphere Support Log Collector"
write-host "----------------------------------------------------------------" -ForegroundColor Yellow
write-host " "
write-host " "
write-host " "
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("A list of vCenter servers will be presented. Please select the vCenter server you would like to collect logs from and press OK",0,"Information",0x0) | out-null
$customer = $customerlist | Out-GridView -PassThru -Title "vCenter Server List"
$name=$customer.name
$username=$customer.UserName
$vcenter=$customer.vCenter
write-host "You have selected $name"

#  Manual Entry Check
if ($name -eq "Manually Enter" ){
    write-host " "
    write-host "Manual Host Entry Selected."
    $vcenter=read-host "vCenter FQDN Address"
    $username=read-host "Username for connecting to vCenter (Usually administrator or administrator@vsphere.local)"
    }


write-host $name -ForegroundColor Cyan
write-host $vcenter -ForegroundColor Red
write-host $username -ForegroundColor yellow

#############################################################################################################
##                                       Connect to vCenter
#############################################################################################################

CLEAR
write-host " "
write-host "----------------------------------------------------------------------" -ForegroundColor Yellow
write-host "                     vSphere Support Log Collector"
write-host "----------------------------------------------------------------------" -ForegroundColor Yellow
    
try{
        Write-Host " "
        Write-Host "Now connecting to $vcenter..." -ForegroundColor Green
        $vcenterCred = Get-Credential -Message "Enter the vCenter Password for $vcenter" -UserName "$username"
        write-host " "
        Connect-VIServer -Server $vcenter -Credential $vcenterCred -Force -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
} catch{
       write-host "Failed to connect to vCenter. Error messege below:"  -ForegroundColor Red
       $error[0].Exception
       Write-Host "Please restart the program to try again" -ForegroundColor Red
       Read-Host "Press any key to exit"
       EXIT
             
}

$dc=get-datacenter
write-host " "
write-host "Successfully connected to $dc" -ForegroundColor Green
write-host " "

#############################################################################################################
##                               Configure logging directory
#############################################################################################################

New-Item "$env:PUBLIC\Documents\VMware Support Logs" -ItemType directory -ErrorAction Ignore | Out-Null
$logpath="$env:PUBLIC\Documents\VMware Support Logs"

# Configure the log directory
$dc = $dc -replace '\s',''
$user=[Environment]::UserName
$logDirectory = New-Item -ItemType Directory -Path "$logpath\$((Get-Date).ToString('yyyyMMddss'))-$dc-$user" | select $_.Name
write-host "Log directory created:" -ForegroundColor Green
write-host "----------------------------------------------------------------------" -ForegroundColor Yellow
write-host $logdirectory  
write-host "----------------------------------------------------------------------" -ForegroundColor Yellow
CD $logdirectory
write-host " "
write-host " " 

#############################################################################################################
##                                      Log Collection Menu Preference
#############################################################################################################

write-host " "
write-host " Please select your logging options for the menu below:"
write-host "----------------------------------------------------------------------" -ForegroundColor Yellow
write-host "  [" -ForegroundColor Green -NoNewline ;write-host "v" -ForegroundColor Magenta -NoNewline; write-host "]Center         " -ForegroundColor Green -NoNewline; Write-Host "- Collect logs from vCenter"
write-host "  [" -ForegroundColor Green -NoNewline ;write-host "E" -ForegroundColor Magenta -NoNewline; write-host "]verything      " -ForegroundColor Green -NoNewline; Write-Host "- Collect logs from both vCenter and all Esxi hosts"
write-host "  [" -ForegroundColor Green -NoNewline ;write-host "S" -ForegroundColor Magenta -NoNewline; write-host "]ingle          " -ForegroundColor Green -NoNewline; Write-Host "- Collect logs from a single ESXi host"
write-host "  [" -ForegroundColor Green -NoNewline ;write-host "A" -ForegroundColor Magenta -NoNewline; write-host "]ll Hosts       " -ForegroundColor Green -NoNewline; Write-Host "- Collect logs from all ESXi hosts"
write-host "----------------------------------------------------------------------"  -ForegroundColor Yellow
write-host " "
write-host "If you are unsure please select [E]verything " -ForegroundColor green
write-host " "
$answer2=read-host "1. Type the letter for preference of log collection (v,e,s,a)" 
$ftpupload=read-host "2. If you have a open case with VMWare do you want to upload the logs?(y/n)" 
if ( $ftpupload -eq "y" -or $ftpupload -eq "Y") {
       $getcred = Get-Credential -UserName inbound -Message "                  Password for VMWare's SFTP website 
                                        >>> The password is 'inbound' <<<"
       Do { 
            $regex="^[0-9]{11}$"
            $ticketnumber = read-host "3. Please enter the VMWare SR number of the case (11 digit SR number only!)"
            $check = $ticketnumber -match $regex
            } while ($check -eq $False)
           }
CLEAR
write-host " "
write-host " "
write-host " "
write-host " "
write-host " "
write-host " "
write-host " "
write-host "----------------------------------------------------------------" -ForegroundColor Yellow
write-host "                vSphere Support Log Collector"
write-host "----------------------------------------------------------------" -ForegroundColor Yellow
write-host " "
write-host "---                                                                  ----" -ForegroundColor Black -BackgroundColor Yellow
write-host "---      Please note that log collecting will take along time....    ----" -ForegroundColor Black -BackgroundColor Yellow
write-host "---                                                                  ----" -ForegroundColor Black -BackgroundColor Yellow
write-host " "

#############################################################################################################
##                                              vCenter Only
#############################################################################################################

if ( $answer2 -eq "v" -or $answer2 -eq "V" -or $answer2 -eq "E" -or $answer2 -eq "e" ) 
    {
    write-host " "
    write-host "Collecting vCenter logs from $vcenter please wait...."
    Get-Log -Bundle -DestinationPath $logdirectory | Out-Null 
    write-host "vCenter collection process completed!" -ForegroundColor Green
    }

#############################################################################################################
##                                             Single ESXi Host
#############################################################################################################

if ( $answer2 -eq "s" -or $answer -eq "S" ) 
    {
    $hostlist = Get-VMHost
    $menu = @{}
    Write-Host "Which host do you need to collect logs from?:" -ForegroundColor Yellow

    # Dynamic Menu for Hosts
    for ($i=1;$i -le $hostlist.count; $i++) {
        Write-Host "$i. $($hostlist[$i-1].name)"
        $menu.Add($i,($hostlist[$i-1].name))
        }
 
    # Do the following block until a valid choice is selected
    do {
        [int]$ans = Read-Host 'Enter selection'
    $selection = $menu.Item($ans)
    if ($selection -eq $null) {
        Write-host "[$ans] was not a valid option. Please try again..." -ForegroundColor Red}else {
            write-host " " 
            Write-host "Collecting logs from: $selection..." -ForegroundColor Green 
            write-host " "
        }
    } until ($selection -ne $null)
    try{
        Test-Connection -ComputerName $selection -Count 3 -ErrorAction Stop -Quiet | Out-Null
        }
    catch
        {
        $error[0].Exception
        write-host "The connection to the host $selection failed. Please confirm DNS on the client side." -ForegroundColor Red
        exit
        }
    get-vmhost $selection | Get-Log -Bundle -DestinationPath $logdirectory | Format-Table -AutoSize -Wrap
    write-host "Host log collection process completed!" -ForegroundColor Green
    }


#############################################################################################################
##                                             All ESXi Hosts
#############################################################################################################

if ( $answer2 -eq "e" -or $answer2 -eq "E"-or $answer2 -eq "a" -or $answer2 -eq "A" ) 
    {
    $allhost = Get-VMHost
    ForEach ($allHost in $allHost) 
        {
            try{
                Test-Connection -ComputerName $allhost -Count 3 -ErrorAction Stop -Quiet | Out-Null
            }
            catch{
                $error[0].Exception
                write-host "The connection to the host $allhost failed. Please confirm DNS on the client side." -ForegroundColor Red
                exit
            }
            write-host " "
            write-host "Collecting logs for $allhost..."
            get-vmhost $allhost | Get-Log -Bundle -DestinationPath $logdirectory | Format-Table -AutoSize -Wrap | Out-Null
            write-host "Host log collection completed." -ForegroundColor Green
        }
    }

#############################################################################################################
##                                  Generate checksums in MD5 and SHA1
#############################################################################################################

$files = Get-ChildItem "$logdirectory" -File
$hashes = foreach ($file in $Files){
    Write-Output (New-Object -TypeName PSCustomObject -Property @{
        FileName = $file.Name
        MD5 = Get-FileHash $file.Name -Algorithm MD5 | Select-Object -ExpandProperty Hash
        SHA1 = Get-FileHash $file.Name -Algorithm SHA1 | Select-Object -ExpandProperty Hash
        })
}
$hashes | select FileName,MD5,SHA1 | Export-Csv -NoTypeInformation -Path "$logDirectory\checksum.csv"

invoke-item $logDirectory

#############################################################################################################
##                                         Upload via SFTP
#############################################################################################################

if ( $ftpupload -eq "y" -or $ftpupload -eq "Y") {
        write-host " "
        write-host "Now connecting to VMWare's FTP Site to upload the logs..." -ForegroundColor Green
        get-sftpsession | Remove-SFTPSession | Out-Null
        New-SFTPSession -ComputerName sftpsite.vmware.com -Credential $getcred -AcceptKey -InformationAction SilentlyContinue -WarningAction SilentlyContinue -OperationTimeout 9999999
        $sessionID = Get-SFTPSession
        write-host "Creating directory $ticketnumber..."
        New-SFTPItem -SFTPSession $sessionID -ItemType Directory -Path "/$ticketnumber" -ErrorAction SilentlyContinue  
        $files = get-childitem $logDirectory | Sort-Object Length

        foreach ($file in $files) {
            write-host "Now transfering $file..."
            Set-SFTPFile  -SFTPSession $sessionID -LocalFile $logDirectory\$file -RemotePath /$ticketnumber -Overwrite -Verbose -InformationAction SilentlyContinue -WarningAction SilentlyContinue
        }

        write-host " "
        get-sftpsession | Remove-SFTPSession | Out-Null
        write-host "Log upload is complete. Please review the output to verify upload was successful. "
}

Disconnect-VIServer * -Confirm:$False


$prompt = [System.Windows.Forms.MessageBox]::Show('Log collection has been completed. Press OK to exit.' , 'Complete')
if ($prompt -eq "OK"){
    EXIT
    }

#############################################################################################################