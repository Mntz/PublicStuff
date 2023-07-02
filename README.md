# Systray Telemeter
Quick and dirty Powershell 7 script to add Telenet Telemeter stats to your systray.

![telemeter](https://github.com/Mntz/SystrayTelemeter/assets/3694374/c200a045-9e7a-49ea-bf78-f00ec8158795)

On first run you'll be prompted for Telenet credentials which will be stored encrypted under HKEY_CURRENT_USER\Software\SystrayTelenet

Option to run at user log on using the Task scheduler:
"C:\Program Files\PowerShell\7\pwsh.exe" -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Path\To\Systray-telenet.ps1"
