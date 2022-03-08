$Script_name = ""
Connect-MSGraph

$Main_Path = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"
$Get_script_info = (Invoke-MSGraphRequest -Url $Main_Path -HttpMethod Get).value | Where{$_.DisplayName -like "*$Script_name*"}
$Get_Script_ID = $Get_script_info.id
$Get_Script_Name = $Get_script_info.displayName

$Main_Details_Path = "$Main_Path/$Get_Script_ID/deviceRunStates/" + '?$expand=*'
$Get_script_details = (Invoke-MSGraphRequest -Url $Main_Details_Path -HttpMethod Get).value      

$Remediation_details = @()
ForEach($Detail in $Get_script_details)
	{
		$Remediation_Values = New-Object PSObject
		$Script_lastStateUpdateDateTime = $Detail.lastStateUpdateDateTime                                        
		$Script_DetectionScriptOutput   = $Detail.preRemediationDetectionScriptOutput  
		$deviceName = $Detail.managedDevice.deviceName
		$userPrincipalName = ($Detail.managedDevice.userPrincipalName).split("@")[0]             

		$Get_script_info = (Invoke-MSGraphRequest -Url $Main_Path -HttpMethod Get).value | Where{$_.DisplayName -like "*Devices_Onedrive_Check folder path*"}
		$Get_Script_ID = $Get_script_info.id
		$Get_Script_Name = $Get_script_info.displayName

		If(($Detail.detectionState) -eq "pending")
			{
				$Size_Value = "pending"
				$Size_On_Disk_Value = "pending"
			}
		Else
			{
				$Script_DetectionScriptOutput = $Detail.preRemediationDetectionScriptOutput  
				If($Script_DetectionScriptOutput -like "*-*")
					{
						$Script_DetectionScriptOutput = $Script_DetectionScriptOutput.replace("Size",'').replace(":","").replace("on disk","")						
						$Size_Value = $Script_DetectionScriptOutput.split("-")[0].trimstart()
						$Size_On_Disk_Value = $Script_DetectionScriptOutput.split("-")[1].trimstart()
						
					}
				ElseIf($Script_DetectionScriptOutput -eq $null)
					{
						$Size_Value = "No value"
						$Size_On_Disk_Value = "No value"
					}
			}
	
		$Remediation_Values = $Remediation_Values | Add-Member NoteProperty "Device name" $deviceName -passthru -force                    
		$Remediation_Values = $Remediation_Values | Add-Member NoteProperty "User name" $userPrincipalName -passthru -force                                           
		$Remediation_Values = $Remediation_Values | Add-Member NoteProperty "Last Intune check" $Script_lastStateUpdateDateTime -passthru -force
		$Remediation_Values = $Remediation_Values | Add-Member NoteProperty "Size" $Size_Value -passthru -force	
		$Remediation_Values = $Remediation_Values | Add-Member NoteProperty "Size on disk" $Size_On_Disk_Value -passthru -force	
		$Remediation_details += $Remediation_Values			
	} 
	
$Report_CSV = "$Current_Folder\$Script_name.csv"
$Remediation_details | select * | export-csv $Report_CSV -notype -Delimiter ";"

$Report_XLSX = "$Current_Folder\$Script_name.xlsx"
$xl = new-object -comobject excel.application 
$xl.visible = $False
$xl.DisplayAlerts=$False
sleep 10
$Workbook = $xl.workbooks.open($Report_CSV)

$WorkSheet=$WorkBook.activesheet
$WorkSheet.columns.autofit() | out-null

$table=$Workbook.ActiveSheet.ListObjects.add( 1,$Workbook.ActiveSheet.UsedRange,0,1)
$WorkSheet.columns.autofit() | out-null

$Workbook.SaveAs($Report_XLSX,51)
$Workbook.Saved = $True
$xl.Quit()
