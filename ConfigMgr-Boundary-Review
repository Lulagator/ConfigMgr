$server = "NA902340-SAL.Delhaize.com"
$siteCode = "DAA"
$boundarytype = @("IPSubnet", "ADSite", "IPV6Prefix", "IPRange")
 
$members = Get-WmiObject -ComputerName $server -Namespace root\sms\site_$siteCode -Query "SELECT Boundary.*, BoundaryGroup.* FROM SMS_Boundary boundary LEFT JOIN SMS_BoundaryGroupMembers BGroupMembers ON boundary.boundaryId = BGroupMembers.boundaryId FULL JOIN SMS_BoundaryGroup BoundaryGroup ON BGroupMembers.GroupId = BoundaryGroup.GroupId"





$BoundaryMembershipInfo = @{}
foreach ($member in $members) {
    if ($BoundaryMembershipInfo[$member.Boundary.BoundaryId.ToString()]) {
        $BoundaryMembershipInfo[$member.Boundary.BoundaryId.ToString()].GroupMembershipInfo += $member.BoundaryGroup
    } else {
        $BoundaryInfo = New-Object PSObject
  
        # Save all the Boundary Information
        foreach ($Property in $member.boundary.PSObject.Properties) {
            $BoundaryInfo | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Property.Value
        }
 
        # Create an array to save boundary group membership information
        $BoundaryInfo | Add-Member -MemberType NoteProperty -Name "GroupMembershipInfo" -Value @($member.BoundaryGroup)
         
        $BoundaryMembershipInfo[$member.Boundary.BoundaryId.ToString()] = $BoundaryInfo
    }
}

#Convert Hash Table into a simple array of values so that we can easily use it within the pipeline
$BoundaryMembershipInfo = [array]$BoundaryMembershipInfo.Values

#Output the Information
$BoundaryMembershipInfo | select-object value, Displayname, @{N="BoundaryType"; e={$boundaryType[$_.BoundaryType]}}, @{N="BoundaryGroups"; e={($_.GroupMembershipInfo).Name -join "; "}} | Out-GridView -Title "Boundary Output"
