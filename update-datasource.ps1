#Set variables:
#Change the Configmgr Report server name
$reportserver = "ncsccmesqlprd01";
$url = "http://$($reportserver)/reportserver/reportservice2005.asmx?WSDL";
#Provide New Data source Path ,you need to replace this with correct one from your SSRS report 
$newDataSourcePath = "/CM_ETS"
#Provide new Data source Name which is part of above source path
$newDataSourceName = "";
# provide Report folder path that contains reports to change the Data source.in my case,i want to change DS for all reports under eskonr/eswar/sup folder
$reportFolderPath = "/ConfigMgr_ETS/Software Distribution - Application Monitoring/Software Distribution - Application Monitoring Hidden"
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
 
 Write-Host "Report's DataSource Reference ($($_.Name)): $($_.Item.Reference)";
 }
 
 Write-Host "------------------------"
 }
