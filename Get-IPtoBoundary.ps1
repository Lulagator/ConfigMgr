Function Get-IPAddressToBoundary 
{

[CmdletBinding()]
param(
    #specify the SCCM server with SMS namespace provider installed
    [parameter(Mandatory=$true)]
    $SiteServer,

    #Input the IPAddresses to check 
    [parameter(Mandatory=$true)]
    [string[]]$IPAddress
)

BEGIN 
{
    Write-Verbose -Message "[BEGIN] Starting the Function"
    TRY
    {
        Write-Verbose -Message "[BEGIN] checking if the $SiteServer has SMS Provider for local site"
        #Query if the SiteServer specifed has the SMS Provider for the local site on it
        $sccmProvider = Get-CimInstance -query "select * from SMS_ProviderLocation where ProviderForLocalSite = true" -Namespace "root\sms" -ComputerName $SiteServer -ErrorAction Stop
        $Splits = $sccmProvider.NamespacePath -split "\\", 4

        Write-Verbose -Message "[BEGIN] Trying to get the IP Range Boundaries"
        #get the Boundaries
        $Boundaries = Get-WmiObject -Namespace ($Splits[3]) -Class SMS_Boundary -Filter "BoundaryType = 3" -ComputerName $SiteServer -ErrorAction stop
        #Closure / Lambda in PowerShell
        $parse = {param($IP) $temp= [System.Net.IPAddress]::Parse($IP).GetAddressBytes();[Array]::Reverse($temp) ; [System.BitConverter]::ToUInt32($temp,0) }
    }
    CATCH
    {
        Write-Warning -Message "[BEGIN] Something went wrong"
        throw $_.Exception
    }
    
}
PROCESS
{
    foreach ($IP in $IPAddress)
    {
        Write-Verbose -Message "[PROCESS] Processing the IPAddress $IP"
        $Boundaries | ForEach-Object {
                  
            $IPStartRange,$IPEndRange = $_.Value.Split("-") 
        
            $ParseIP = & $parse $IP
      
            $ParseStartIP = & $parse $IPStartRange
        
            $ParseEndIP = & $parse $IPEndRange
               
            if (($ParseStartIP -le $ParseIP) -and ($ParseIP -le $ParseEndIP)) 
            {
                Write-Verbose -Message "$IP falls in the boundary $($_.DisplayName)"
                Add-Member -InputObject $_ -MemberType NoteProperty -Name IPAddress -Value $IP -PassThru |
                     select -Property IPAddress,Boundary*,DisplayName,*by,
                                @{Name="Date Created";E={[System.Management.ManagementDateTimeConverter]::ToDateTime($_.createdon)}},
                                @{Name="Date Modified";E={[System.Management.ManagementDateTimeConverter]::ToDateTime($_.ModifiedOn)}} 
                            
            }
        }
    
    }

}#end PROCESS

END
{
    Write-Verbose -Message "[END] Ending the Function"
}

}
