# reading xml file
[xml]$xmlAttr = Get-Content -Path 'C:\Program Files (x86)\Hard Disk Sentinel\HDSentinel.xml'

#desired Output Sample:
#P "Disk1" health=100;99;90 temp=35;40;45 + Infos

[int]$disk=0
$diskNr=("Physical_Disk_Information_Disk_" + $disk)

do {
    $xmlHD_Model = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Hard_Disk_Model_ID
    $xmlHealth = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Health
    if ($xmlHD_Model -ne "`?" -And $xmlHD_Model -notmatch "WIBU"){ #ignore WIBU Dongle and unknown devices (not needed if interface check is active)
        $xmlInterface = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Interface
        if ($xmlInterface -notmatch "USB"){ #ignore USB Devices 
            $xmlHD_Nr = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Hard_Disk_Number
            
            # format Disk Nr with leading zeros
            $diskOutNr = "{0:d3}" -f $disk

            $xmlHealth = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Health
            $xmlTemp = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Current_Temperature
            $xmlTip = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Tip
            $xmlDescription = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Description
            $xmlMember = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Logical_Drive_s
            $xmlCapacity = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Disk_Information.Capacity
            $xmlTotal_Size = 0
            $xmlTotal_Size = $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Total_Size
    
            $pos = $xmlDescription.IndexOf(".")
            if ($pos -ge 1){
            $description = $xmlDescription.Substring(0, $pos+1)}
            else {
            $description = $xmlDescription
            }

            if ($xmlCapacity -ne $null){
                $pos_c = $xmlCapacity.IndexOf("(")
                #Write-Host $xmlCapacity
                    if ($pos_c -ge 1){
                        $capacity = $xmlCapacity.Substring(0, $pos_c - 1)}
                    else {
                        $capacity = $xmlCapacity
                    }
            }
            
            $pos = $xmlTotal_Size.IndexOf("MB")
            #Write-Host $xmlTotal_Size
            if ($pos -ge 1){
            $totalsize = $xmlTotal_Size.Substring(0, $pos - 1)
            $totalsize = [bigint]$totalsize / 1000 / 1000 }
            #Write-Host $totalsize }
            else {
            $totalsize = $xmlTotal_Size
            }


            #get communication errors
            [int]$comm_errors = 0
            [int]$weakSectors = 0
            
            if( $description -like "*roblem*") {
              [int]$comm_errors = $description -replace '[^0-9]',''}
                 else {
                   #get weak sectors
                   [int]$weakSectors = $description -replace '[^0-9]',''
                   [int]$comm_errors = 0

                    if( $xmlHealth -ne $null){
                    $pos = $xmlHealth.IndexOf(" ")
                    [int]$health = $xmlHealth.Substring(0, $pos)}
                        else {
                        $health=111}

                    if( $xmlTemp -ne '?'){
                    $pos = $xmlTemp.IndexOf(" ")
                    $temp = $xmlTemp.Substring(0, $pos)}
                    else {
                        $temp="-1"}
                    }
            #set temp limits SSD 60:70 HDD: 45:55
            if( $xmldescription -like "*Solid State Disk*") {
              $templimits = ";60;70"}
            else {
              $templimits = ";45;60"}

            #CheckMK output
            #'P ' + '"#' + $diskOutNr + ' ' + $xmlHD_Model + '" weak_sect=' + $weakSectors + ';1;10|comm_errors=' + $comm_errors + ';10;100|temp=' + $temp + $templimits + $description + '\nMember of ' + $xmlMember
            #'P ' + '"Disk' + $diskOutNr + '" weak_sect=' + $weakSectors + ';1;10|comm_errors=' + $comm_errors + ';10;100|temp=' + $temp + $templimits + $description + '\n' + $xmlHD_Model + '\nMember of ' + $xmlMember
            'P ' + '"Disk' + $diskOutNr + '" weak_sect=' + $weakSectors + ';1;10|comm_errors=' + $comm_errors + ';10000;1000000|temp=' + $temp + $templimits + '|health=' + $health + ';75,50 ' + $capacity + ' - ' + $health + '% - ' + $description + ' ' + $xmlTip + '\n' + $xmlHD_Model + '\nMember of ' + $xmlMember
            }
        }
    $disk++
    $diskNr=("Physical_Disk_Information_Disk_" + $disk)
    #Write-Host $xmlHD_Nr
    #Write-Host $xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Hard_Disk_Number
    
   } until ($xmlAttr.Hard_Disk_Sentinel.$diskNr.Hard_Disk_Summary.Hard_Disk_Number -eq $null)
