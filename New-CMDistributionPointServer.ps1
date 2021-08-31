
#Add the primary/CAS server and/or SMSProvider to connect to and the site's site code
$ProviderMachineName = "$PrimarySiteServer_or_SMSProvider"
$SiteCode = "$SiteCode"

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\"



#Add NO_SMS_ON_DRIVE.SMS On C:
#Change drive location(s) based on your needs for the NOSMSONDRIVE file
$File = "NO_SMS_ON_DRIVE.SMS"

IF (!(Test-Path "C:\$File"))
    {
        New-Item -Path  "C:\$File" -ItemType File -Force
    }
ELSE
    {
        Write-Output "File Exists"
    }


#Change the connection context
Set-Location "$($SiteCode.Name):\"

#New DP Information
$DistributionPointName = [System.Net.Dns]::GetHostByName($env:computerName).HostName 
$DistriubtionPointGroup = '$DPGroup'
$SiteCodePost = '$SiteCode'
$PXEPassword = ConvertTo-SecureString '$PXEPasswordHere' -AsPlainText -Force

# Test the connection to server - if ran outside of OSD validate it's online
#    Test-Connection -ComputerName $DistributionPointName

# Install Windows Server Roles and Features
    Install-WindowsFeature -Name Web-ISAPI-Ext,Web-Windows-Auth,Web-Metabase,Web-WMI,RDC -ComputerName $DistributionPointName

# OPTIONAL - Restart the Server
    #Restart-Computer -ComputerName $DistributionPoint -Wait -For PowerShell -Force

# Add new Site System Server
    New-CMSiteSystemServer -ServerName $DistributionPointName -SiteCode $SiteCodePost

# Add a Distribution Point with the following settings
    Start-Sleep -Seconds 10
    Add-CMDistributionPoint `
        -SiteSystemServerName $DistributionPointName `
        -SiteCode $SiteCodePost `
        -ClientConnectionType Intranet `
        -MinimumFreeSpaceMB 50 `
        -PrimaryContentLibraryLocation Automatic `
        -SecondaryContentLibraryLocation Automatic `
        -PrimaryPackageShareLocation Automatic `
        -EnablePxeSupport `
        -PxePassword $PXEPassword `
        -AllowPxeResponse `
        -EnableUnknownComputerSupport `
        -PxeServerResponseDelaySec 3 `
        -SecondaryPackageShareLocation Automatic `
        -EnableBranchCache `
        -EnableContentValidation `
        -CertificateExpirationTimeUtc ((Get-Date).AddYears(100))

# Modify the DP
    Start-Sleep -Seconds 10
    Set-CMDistributionPoint `
        -SiteSystemServerName $DistributionPointName `
        -SiteCode $SiteCodePost `
        -ClientCommunicationType HTTP



#Add to set Distribution Point group - added Sleep to help with timing failures
    Start-Sleep -Seconds 10    
    Add-CMDistributionPointToGroup -DistributionPointName $DistributionPointName -DistributionPointGroupName $DistriubtionPointGroup
