#Set variables:
#Change the Configmgr Report server name
$reportserver = "SERVERNAME"
$url = "http://$($reportserver)/reportserver/reportservice2010.asmx?WSDL"
#Provide New Data source Path ,you need to replace this with correct one from your SSRS report 
$newDataSourcePath = "/ConfigMgr_XXX/{5C6358F2-4BB6-4a1b-A16E-8D96795D8602}"
#Provide new Data source Name which is part of above source path
$newDataSourceName = ""
# provide Report folder path that contains reports to change the Data source.in my case,i want to change DS for all reports under eskonr/eswar/sup folder
$reportFolderPath = "/ConfigMgr_XXX/PATH/TO/FOLDER"
 #------------------------------------------------------------------------
 
 $ssrs = New-WebServiceProxy -uri $url -UseDefaultCredential
 
 $reports = $ssrs.ListChildren($reportFolderPath, $false)
 
 $reports | ForEach-Object {
 $reportPath = $_.path
 Write-Host "Report: " $reportPath
 $dataSources = $ssrs.GetItemDataSources($reportPath)
 $dataSources | ForEach-Object {
 $proxyNamespace = $_.GetType().Namespace
 $myDataSource = New-Object ("$proxyNamespace.DataSource")
 $myDataSource.Name = $newDataSourceName
 $myDataSource.Item = New-Object ("$proxyNamespace.DataSourceReference")
 $myDataSource.Item.Reference = $newDataSourcePath
 
 $_.item = $myDataSource.Item
 
 $ssrs.SetItemDataSources($reportPath, $_)
 
 Write-OUtput "Report's DataSource Reference ($($_.Name)): $($_.Item.Reference)"
 }
 
 Write-Output "------------------------"
 }
