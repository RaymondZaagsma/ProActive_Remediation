if ((Get-Date).DayOfWeek -eq "Monday") {
   exit ([int](-not (Get-HPBIOSUpdates -check))) 
}
exit 0