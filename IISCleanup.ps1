#IIS Log Location
$logPath = "D:\IIS Logs" 
#Number of Days to keep
$maxDaystoKeep = -30
#Name and Location for Log export
$cleanupRecordPath = "D:\IIS_Log_Cleanup.log" 

$itemsToDelete = dir $logPath -Recurse -File *.log | Where LastWriteTime -lt ((get-date).AddDays($maxDaystoKeep)) 

If ($itemsToDelete.Count -gt 0)
{ 
    ForEach ($item in $itemsToDelete)
    { 
        "$($item.FullName) is older than $((get-date).AddDays($maxDaystoKeep)) and will be deleted." | Add-Content $cleanupRecordPath 
        Remove-Item $item.FullName -Verbose 
    } 
} 
Else
{ 
    "No items to be deleted today $($(Get-Date).DateTime)." | Add-Content $cleanupRecordPath 
}    

Write-Output "Cleanup of log files older than $((get-date).AddDays($maxDaystoKeep)) completed!" 
