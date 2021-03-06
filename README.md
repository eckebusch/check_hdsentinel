# General
PowerShell script for [Checkmk](https://checkmk.com/) to use [Hard Disk Sentinels](https://www.hdsentinel.com/) Hard Disk/Solid State Disk information for monitoring.  
*This script is for Windows Operating Systems only - sorry ;)*

This script parses the HDSentinel.xml file, which is created and updated periodically by the <ins>registered</ins> PRO version of **Hard Disk Sentinel**.  
It searches for the XML in the default (installation) folder of HDSentinel: `C:\Program Files (x86)\Hard Disk Sentinel\HDSentinel.xml`  
It iterates through the XML file, searches for all disks with usable information and produces Checkmk compatible output - one line per disk.  

```PowerShell
PS C:\Tools\HDsentinel> C:\ProgramData\checkmk\agent\local\checkmk_hdsentinel.ps1
P "000 WDC WD40EFRX-68WT0N0" weak_sect=0;1;10|comm_errors=0;10;100|temp=35;45;60 The hard disk status is PERFECT.\nMember of X: [Data-X] 
P "001 Samsung SSD 850 EVO 500GB" weak_sect=0;1;10|comm_errors=0;10;100|temp=34;60;70 The status of the solid state disk is PERFECT.\nMember of C: [System] 
P "002 WDC WD40EFRX-68WT0N0" weak_sect=3;1;10|comm_errors=0;10;100|temp=37;45;60 There are 3 weak sectors found on the disk surface.\nMember of X: [Data-X] 
P "003 WDC WD40EFRX-68WT0N0" weak_sect=13;1;10|comm_errors=0;10;100|temp=35;45;60 There are 13 weak sectors found on the disk surface.\nMember of X: [Data-X] 
P "004 WDC WD30EFRX-68EUZN0" weak_sect=0;1;10|comm_errors=0;10;100|temp=32;45;60 The hard disk status is PERFECT.\nMember of Y: [Data-Y] 
P "005 WDC WD30EFRX-68EUZN0" weak_sect=0;1;10|comm_errors=0;10;100|temp=32;45;60 The hard disk status is PERFECT.\nMember of Y: [Data-Y]
```
# [Checkmk](https://checkmk.com/)
Checkmk provides powerful monitoring of networks, servers, clouds, containers and applications. Fast. Effective.

# [Hard Disk Sentinel](https://www.hdsentinel.com/)
Hard Disk Sentinel (HDSentinel) is a multi-OS SSD and HDD monitoring and analysis software. Its goal is to find, test, diagnose and repair hard disk drive problems, report and display SSD and HDD health, performance degradations and failures. Hard Disk Sentinel gives complete textual description, tips and displays/reports the most comprehensive information about the hard disks and solid state disks inside the computer and in external enclosures (USB hard disks / e-SATA hard disks). Many different alerts and report options are available to ensure maximum safety of your valuable data.

No need to use separate tools to verify internal hard disks, external hard disks, SSDs, hybrid disk drives (SSHD), disks in RAID arrays and Network Attached Storage (NAS) drives as these are all included in a single software. In addition Hard Disk Sentinel Pro detects and displays status and S.M.A.R.T. information about LTO tape drives and appropriate industrial (micro) SD cards and eMMC devices too. See the How to: monitor Network Attached Storage (NAS) status for information about hard disk monitoring in Network Attached Storage (NAS) devices.

## Deploying the script
Just put the script in the agents "local" directory of the monitored host:
`%ProgramData%\checkmk\agent\local`  
Please see [Local checks](https://docs.checkmk.com/latest/en/localchecks.html) to learn about more advanced methods of distributing (via the Agent Bakery).
> **_NOTE:_**  You should ideally already have a working Checkmk instance with agents up and running :D

## Adding services to the monitoring
After placing the script inside of the above mentioned folder, it will automatically executed by the agent every time the agent collects data.  
Start a new service discovery of the host and add the new found services to the monitoring. Apply the changes and you are good to go!  
![sample services](images/services.PNG "sample services as seen by checkmk")

You will get one service per disk with multiple informations like **current temperature**, **bad sector count**, **communication errors** (between disk and controller), **disk model** and so on.  

Sample WARN/CRIT states:
![warn/crit](images/warn-crit.PNG "sample WARN/CRIT states")

If you click on one of the disks, you can see some beautiful graphs and historical data:
![details page](images/details_page.png "details page")

## Notes
- it's not final!
- WARN/CRIT states are calculated on the host dynamically depending on the tresholds provided by the script
- tresholds can be adjusted if needed
- compatible with checkmk 2.0+ (you can switch to v1.6+ mode by uncommenting the output line and uncommenting the secod output line below - but the resulting service name will consist of the disk number only because whitespaces are not allowed in v1.6)
