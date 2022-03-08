if (-not (Get-HPBIOSUpdates -check))
{
	Get-HPBIOSUpdates -Flash -Password 'W1o@D&b2o18' -Bitlocker Suspend -Yes
}
exit 0