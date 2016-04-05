

Get-Module -ListAvailable *HP* | Import-Module

Write-host "This tool will upgrade iLO modules in consecutive order. " -ForegroundColor Yellow
$FirstIP = Read-Host "What is the first IP address? (e.g. 10.23.1.2)"
$LastIP = Read-Host "What is he last octect of the last iLO IP? (e.g. 21)"
Write-host "This script will attempt to upgrade iLO interfaces in the following range"
Write-Host "$FirstIP - $LastIP" -ForegroundColor Yellow -BackgroundColor Cyan
$IPRange = "$FirstIP-$LastIP"
PAUSE


$ilocreds = Get-Credential -Message "User and Password for iLO interface" -UserName Administrator
$iloScan = Find-HPiLO $IPrange

$ilo2Upgrades = $iloScan | Where {$_.FWRI -lt 2.29 -AND $_.PN -like "*iLO 2*"}
$ilo3OldUpgrades = $iloScan | Where {$_.FWRI -lt 1.20 -AND $_.PN -like "*iLO 3*"}
$ilo4Upgrades = $iloScan | Where {$_.FWRI -lt 2.40 -AND $_.PN -like "*iLO 4*"}


# ---------------------------------------------------------------------------------
# ILO 2 Upgrades
# ---------------------------------------------------------------------------------
if ($ilo2Upgrades) {
    $iloPath = "C:\ilo\ilo2_229.bin"
    $iloVersion = "2.29"
    write-host ""
    Write-Host "#####################################################################################" -ForegroundColor Yellow
    Write-Host "#                   iLo 2 Servers  Servers marked for upgrade                       #" -ForegroundColor Yellow
    write-host "#####################################################################################" -ForegroundColor Yellow
    write-host " "
    write-host "Found iLO servers running iLO 2"
    write-host " "
    Write-Host "Host List:" -ForegroundColor Cyan
    write-host "______________________________________________________________________" -ForegroundColor Green
    $ilo2Upgrades | Select IP, PN, SPN, FWRI, SerialNumber, Host | Format-Table -AutoSize | Sort-Object IP
    write-host "______________________________________________________________________" -ForegroundColor Green
    write-host " "
    ForEach ( $ilo in $ilo2Upgrades ) {
        $iloip = $ilo.IP
        $iloserial = $ilo.SerialNumber
        Write-Host "Now updating firmware on $iloip - $iloserial to version $iloversion" -ForegroundColor Green
        Update-HPiLOFirmware -Server $ilo -Credential $ilocreds -Location $iloPath -Verbose
        Write-Host "--Done----------------------" -ForegroundColor Red
        }
        write-host "______________________________________________________________________" -ForegroundColor Green

    Clear-Variable -Name $iloPath
    $iloVersion
    $ilo

    }


# ---------------------------------------------------------------------------------
# ILO 3 Pre-Version 1.20 Upgrades
# ---------------------------------------------------------------------------------
if ($ilo3OldUpgrades) {
    $iloPath = "C:\ilo\ilo3_120.bin"
    $iloVersion = "1.20"
    write-host ""
    Write-Host "#####################################################################################" -ForegroundColor Yellow
    Write-Host "#      iLo 3 Servers Running Pre v1.20 Servers marked for upgrade                   #" -ForegroundColor Yellow
    write-host "#####################################################################################" -ForegroundColor Yellow
    write-host " "
    write-host "iLO 3 hosts found running pre 1.20 firmware."
    write-host "These hosts will be upgrade to 1.20 first."
    Write-Host "Host List:" -ForegroundColor Cyan
    write-host "______________________________________________________________________" -ForegroundColor Green
    $ilo3OldUpgrades | Select IP, PN, SPN, FWRI, SerialNumber, Host | Format-Table -AutoSize | Sort-Object IP
    write-host "______________________________________________________________________" -ForegroundColor Green
    write-host " "
    ForEach ( $ilo in $ilo3OldUpgrades ) {
        $iloip = $ilo.IP
        $iloserial = $ilo.SerialNumber
        Write-Host "Now updating firmware on $iloip - $iloserial to version $iloversion" -ForegroundColor Green
        Update-HPiLOFirmware -Server $ilo -Credential $ilocreds -Location $iloPath -Verbose
        Write-Host "--Done----------------------" -ForegroundColor Red
        }
    write-host "______________________________________________________________________" -ForegroundColor Green



    }

$ilo3Upgrades = Find-HPiLO  $IPrange | Where {$_.FWRI -gt 1.20 -and $_.FWRI -lt 1.87 -AND $_.PN -like "*iLO 3*"}

# ---------------------------------------------------------------------------------
# ILO 3 Upgrades
# ---------------------------------------------------------------------------------
if ($ilo3Upgrades) {
    $iloPath = "C:\ilo\ilo3_187.bin"
    $iloVersion = "1.87"
    write-host ""
    Write-Host "#####################################################################################" -ForegroundColor Yellow
    Write-Host "#                   iLo 3 Servers  Servers marked for upgrade                       #" -ForegroundColor Yellow
    write-host "#####################################################################################" -ForegroundColor Yellow
    write-host " "
    write-host "Found iLO servers running iLO 3 with version 1.20 and above"
    write-host " "
    Write-Host "Host List:" -ForegroundColor Cyan
    write-host "______________________________________________________________________" -ForegroundColor Green
    $ilo3Upgrades | Select IP, PN, SPN, FWRI, SerialNumber, Host | Format-Table -AutoSize | Sort-Object IP
    write-host "______________________________________________________________________" -ForegroundColor Green
    write-host " "
    ForEach ( $ilo in $ilo3Upgrades ) {
        $iloip = $ilo.IP
        $iloserial = $ilo.SerialNumber
        Write-Host "Now updating firmware on $iloip - $iloserial to version $iloversion" -ForegroundColor Green
        Update-HPiLOFirmware -Server $ilo -Credential $ilocreds -Location $iloPath -Verbose
        Write-Host "--Done----------------------" -ForegroundColor Red
        }
    write-host "______________________________________________________________________" -ForegroundColor Green



    }




# ---------------------------------------------------------------------------------
# ILO 4 Upgrades
# ---------------------------------------------------------------------------------
if ($ilo4Upgrades) {
    $iloPath = "C:\ilo\ilo4_240.bin"
    $iloVersion = "2.40 1st of April 2016"
    write-host ""
    Write-Host "#####################################################################################" -ForegroundColor Yellow
    Write-Host "#                   iLo 4 Servers  Servers marked for upgrade                       #" -ForegroundColor Yellow
    write-host "#####################################################################################" -ForegroundColor Yellow
    write-host " "
    write-host "Found iLO servers running iLO 4"
    write-host " "
    Write-Host "Host List:" -ForegroundColor Cyan
    write-host "______________________________________________________________________" -ForegroundColor Green
    $ilo4Upgrades | Select IP, PN, SPN, FWRI, SerialNumber, Host | Format-Table -AutoSize | Sort-Object IP
    write-host "______________________________________________________________________" -ForegroundColor Green
    write-host " "
    ForEach ( $ilo in $ilo4Upgrades ) {
        $iloip = $ilo.IP
        $iloserial = $ilo.SerialNumber
        Write-Host "Now updating firmware on $iloip - $iloserial to version $iloversion" -ForegroundColor Green
        Update-HPiLOFirmware -Server $ilo -Credential $ilocreds -Location $iloPath -Verbose
        Write-Host "--Done----------------------" -ForegroundColor Red
        }
    write-host "______________________________________________________________________" -ForegroundColor Green



    }
    PAUSE

   
