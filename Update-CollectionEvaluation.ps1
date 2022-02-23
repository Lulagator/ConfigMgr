
#$a.refreshtype: 1=No Evaluation, 2=Manual Evaluation, 3=Incremental Evaluation, 4=Full Evaluation, 5=Both Full and Incremental Evalation



$siteserver = "SITESERVER"
$site = "SCCMSITECODE"
[datetime]$startTime = [datetime]::Today
$SMS_ST_RecurInterval = "SMS_ST_RecurInterval"
$class_SMS_ST_RecurInterval = [wmiclass]""
$class_SMS_ST_RecurInterval.psbase.Path = "\\$siteserver\ROOT\SMS\Site_$site" + ":$SMS_ST_RecurInterval"
$script:scheduleToken = $class_SMS_ST_RecurInterval.CreateInstance()
if($scheduleToken){
    $scheduleToken.DayDuration = 0
    $scheduleToken.DaySpan = 1
    $scheduleToken.HourDuration = 0
    $scheduleToken.HourSpan = 0
    $scheduleToken.IsGMT = $false
    $scheduleToken.MinuteDuration = 0
    $scheduleToken.MinuteSpan = 0
    $scheduleToken.StartTime = [System.Management.ManagementDateTimeconverter]::ToDMTFDateTime($starttime)
}

$today = get-date -Format G
$collections = get-ciminstance -namespace \\$siteserver\root\sms\site_$site -class sms_collection | select * | where {"Name, Your, Collections, Here"}

foreach($collection in $collections){
    #$id = $collection.CollectionID
    $id = $collection
    $a = [wmi] "\\$siteserver\root\sms\site_$site:SMS_Collection.CollectionID='$id'"
    $a.RefreshType = 2 
    $a.RefreshSchedule = $script:scheduleToken
    $a.put()
} 
