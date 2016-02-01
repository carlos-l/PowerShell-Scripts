#vSphere Support Log Collector


This is a simple powershell script to help automate the process of (1) collect the vCenter or ESXi support logs and (2) uploading directly to VMWare via FTP. A good use case of this would be for users managing multiple vCenter installations as the tool will dislpay a list of vCenters to connect to from a CSV file. 

### Getting Started

1. Download the PS1 and CSV files from the repo
2. By default the script will check for c:\Scripts\customer-list.csv for the vCenter list. 
3. Note: Do not edit the the first and last line of the CSV
4. Add you vCenters into the CSV file.
5. Right click on the script and select "Run with PowerShell"


### Warning and Disclaimer
* Please note that FTP uploads are *not* encrypted.

### Requirements 

* PowerCLI 6
* This script leverages the PowerShell FTP Client Module. Please make sure to install the module before use. 
https://gallery.technet.microsoft.com/scriptcenter/PowerShell-FTP-Client-db6fe0cb
* Tested on Powershell v4.0, PowerCLI 6.0 R3 with ESXi 5.5 and ESXi 6.x

### Demo
![](demo.gif)
