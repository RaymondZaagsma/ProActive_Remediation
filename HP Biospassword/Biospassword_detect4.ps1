$IsPasswordSet = (Get-WmiObject -Namespace root/hp/InstrumentedBIOS -Class HP_BIOSSetting | Where-Object Name -eq "Setup Password").IsSet
If($IsPasswordSet -eq 1)
	{
		write-output "Your BIOS is password protected"	
		Exit 0
	}
Else
	{
		write-output "Your BIOS is not password protected"	
		Exit 1
	}