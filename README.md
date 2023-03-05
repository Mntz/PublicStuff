# Systray Telemeter
Quick and dirty Powershell script to add Telenet Telemeter stats to your systray.

![systray-telenet](https://user-images.githubusercontent.com/3694374/222962465-07095efe-e645-49cc-acb5-704a60286408.png)

Enter your credentials under:
- "j_username" = ""
- "j_password" = ""

Option to run at user log on using the Task scheduler:
"C:\Program Files\PowerShell\7\pwsh.exe" -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Path\To\Systray-telenet.ps1"
