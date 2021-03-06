#vSphere Support Log Collector


This is a simple powershell script to help automate the process of (1) collect the vCenter or ESXi support logs and (2) uploading directly to VMWare via SFTP. A good use case of this would be for users managing multiple vCenter installations as the tool will display a list of vCenters to connect to from a CSV file. 

### Requirements 

* PowerCLI 6 (Previous version should work)
* This script requires the use of Posh-SSH (https://github.com/darkoperator/Posh-SSH)
* Tested on Powershell v4.0, PowerCLI 6.0 R3 with ESXi 5.5 and ESXi 6.x

### Getting Started

1. Download the PS1 and CSV files from the repo
2. By default the script will check for c:\Scripts\customer-list.csv for the vCenter list. 
3. Note: Do not edit the the first and last line of the CSV
4. Add you vCenters into the CSV file.
5. Right click on the script and select "Run with PowerShell"

### Make a shortcut
* A shortcut can be created using the following target path.
```
%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -command ""[Path to script]\log-collect.ps1""
```

### Warning and Disclaimer
* By using this script you accept and risks to your environment. As always test before using in production.
* Uploads to VMWare are encrypted over FTPS


### Demo
![](demo.gif)

### Change Control

| Version | Date | Description
| ------- | -------- | ------------------ |
| 1.2 | 2/3/2016 | Added better MD5 and SHA1 generation and will be uploaded with the support bundles for Vmware to verify. 
| 1.1 | 2/2/2016 | Switched from FTP to SFTP to support encryption
| 1.0 | 1/2/2016 | Initial Release

### Upcoming Features

- CSV file validation - Done v1.1
- Use SFTP instead of FTP to support encryption (KB2069559) - Done v1.1
- Generate MD5 and SHA1 for Vmware to verify file integrity - Done v1.2

### Credits

Thanks goes out to the reddit.com/r/powershell community who have always been a fantastic help and resource. 

