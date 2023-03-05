[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

Function get-telenetStats
    {

    $headers = @{
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"
        "x-alt-referer" = "https://www2.telenet.be/nl/klantenservice/#/pages=1/menu=selfservice"
    }
    $url = "https://api.prd.telenet.be/ocapi/oauth/userdetails"
    $state, $nonce = ""
    try {
        $response = Invoke-WebRequest -Uri $url -Headers $headers -SessionVariable s -TimeoutSec 10
    }
    catch {
        Write-Host $_.ErrorDetails.Message
        $state = $_.ErrorDetails.Message.Split(",")[0]
        $nonce = $_.ErrorDetails.Message.Split(",")[1]
    }

    $url = "https://login.prd.telenet.be/openid/oauth/authorize?client_id=ocapi&response_type=code&claims={""id_token"":{""http://telenet.be/claims/roles"":null,""http://telenet.be/claims/licenses"":null}}&lang=nl&state=$state&nonce=$nonce&prompt=login"
    $response = Invoke-WebRequest -Uri $url -SessionVariable s -TimeoutSec 10
    $url = "https://login.prd.telenet.be/openid/login.do"
    $data = @{
        "j_username" = ""
        "j_password" = ""
        "rememberme" = $true
    }
    $response = Invoke-WebRequest -Uri $url -Method POST -Body $data -WebSession $s -TimeoutSec 10

    if ($s.Cookies.GetAllCookies() | Where-Object {$_.Name -like "TOKEN-XSRF"}) {
        $headers = @{
            "x-alt-referer" = "https://www2.telenet.be/nl/klantenservice/#/pages=1/menu=selfservice"
            "X-TOKEN-XSRF" = ($s.Cookies.GetAllCookies() | Where-Object {$_.Name -like "TOKEN-XSRF"}).Value
        }
    }

    $url = "https://api.prd.telenet.be/ocapi/public/?p=internetusage,internetusagereminder"
    $response = Invoke-WebRequest -Uri $url -Method Get -Headers $headers -WebSession $s -TimeoutSec 10

    $telenetValues = $response.Content | ConvertFrom-Json

    $currentPeak = [math]::Round(($telenetValues.internetusage[0].availableperiods[0].usages[0].totalusage.peak / 1024 / 1024))
    $currentoffPeak = [math]::Round(($telenetValues.internetusage[0].availableperiods[0].usages[0].totalusage.offpeak / 1024 / 1024))
    $currentStart = ($telenetValues.internetusage[0].availableperiods[0].usages[0].periodstart).ToString("dd/MM")
    $currentEnd = ($telenetValues.internetusage[0].availableperiods[0].usages[0].periodend).ToString("dd/MM")

    Return "$currentPeak;$currentoffPeak;$currentStart;$currentEnd"
}   

#
# LETS GO
#

$telenetStats = get-telenetStats

$Current_Folder = split-path $MyInvocation.MyCommand.Path
 
# Add assemblies
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | out-null
Add-Type -AssemblyName PresentationCore
 
# Prepare Telenet icon
$base64 = "AAABAAEAICAAAAEAIACoEAAAFgAAACgAAAAgAAAAQAAAAAEAIAAAAAAAABAAABMLAAATCwAAAAAAAAAAAAAhxP8AIcT/ACHE/wAhxP8AIcT/FyHE/1EhxP9yIcT/kCHE/6shxP++IcT/zyHE/98hxP/uIcT/7iHE//UhxP//IcT//yHE//UhxP/uIcT/7iHE/98hxP/PIcT/viHE/6shxP+QIcT/ciHE/1EhxP8XIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ESHE/54hxP/6IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//shxP+fIcT/ESHE/wAhxP8AIcT/ACHE/w8hxP/RIcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP/RIcT/DyHE/wAhxP8AIcT/nyHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP+fIcT/ACHE/xYhxP/7IcT//yHE//8hxP//IcT//yHE//8hxP//IcT/5yHE/8UhxP+rIcT/lyHE/4UhxP93IcT/dyHE/20hxP9tIcT/dyHE/3chxP+GIcT/lyHE/6shxP/FIcT/5yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//shxP8WIcT/UiHE//8hxP//IcT//yHE//8hxP//IcT/uCHE/ykhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/KSHE/7ghxP//IcT//yHE//8hxP//IcT//yHE/1EhxP9xIcT//yHE//8hxP//IcT//yHE/7ghxP8DIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/AyHE/7ghxP//IcT//yHE//8hxP//IcT/cSHE/40hxP//IcT//yHE//8hxP//IcT/KSHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/KSHE//8hxP//IcT//yHE//8hxP+NIcT/pyHE//8hxP//IcT//yHE/+YhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/5iHE//8hxP//IcT//yHE/6ghxP+6IcT//yHE//8hxP//IcT/yCHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ByHE/zUhxP9TIcT/UyHE/zYhxP8HIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP/IIcT//yHE//8hxP//IcT/uyHE/8shxP//IcT//yHE//8hxP+tIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/MCHE/6MhxP/zIcT//yHE//8hxP//IcT//yHE//QhxP+mIcT/NSHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/6whxP//IcT//yHE//8hxP/MIcT/3CHE//8hxP//IcT//yHE/5ohxP8AIcT/ACHE/wAhxP8AIcT/EyHE/6IhxP/9IcT//yHE//8hxP/tIcT/2CHE/9ghxP/sIcT//yHE//8hxP/+IcT/pSHE/xQhxP8AIcT/ACHE/wAhxP8AIcT/miHE//8hxP//IcT//yHE/90hxP/oIcT//yHE//8hxP//IcT/iSHE/wAhxP8AIcT/ACHE/wAhxP/cIcT//SHE/7IhxP9gIcT/GiHE/wAhxP8AIcT/ACHE/wAhxP8ZIcT/YCHE/7AhxP/8IcT/4SHE/wAhxP8AIcT/ACHE/wAhxP+JIcT//yHE//8hxP//IcT/6SHE//AhxP//IcT//yHE//8hxP94IcT/ACHE/wAhxP8AIcT/ACHE/6AhxP8iIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/yEhxP+hIcT/ACHE/wAhxP8AIcT/ACHE/3ghxP//IcT//yHE//8hxP/wIcT/8iHE//8hxP//IcT//yHE/3ghxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/eCHE//8hxP//IcT//yHE//MhxP//IcT//yHE//8hxP//IcT/ayHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP9qIcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP9rIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/2ohxP//IcT//yHE//8hxP//IcT/8iHE//8hxP//IcT//yHE/3ghxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/eCHE//8hxP//IcT//yHE//MhxP/wIcT//yHE//8hxP//IcT/eCHE/wAhxP8AIcT/ACHE/wAhxP8PIcT/pyHE//UhxP/rIcT/hiHE/wEhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8IIcT/CyHE/wAhxP8AIcT/ACHE/wAhxP94IcT//yHE//8hxP//IcT/8CHE/+ghxP//IcT//yHE//8hxP+JIcT/ACHE/wAhxP8AIcT/ACHE/3whxP//IcT//yHE//8hxP//IcT/RSHE/wAhxP8AIcT/hCHE/+4hxP/dIcT/7yHE//8hxP94IcT/ACHE/wAhxP8AIcT/ACHE/4khxP//IcT//yHE//8hxP/pIcT/3CHE//8hxP//IcT//yHE/5ohxP8AIcT/ACHE/wAhxP8AIcT/hiHE//8hxP//IcT//yHE//8hxP9PIcT/ACHE/wAhxP+FIcT//yHE//8hxP//IcT//yHE/3MhxP8AIcT/ACHE/wAhxP8AIcT/miHE//8hxP//IcT//yHE/90hxP/LIcT//yHE//8hxP//IcT/rSHE/wAhxP8AIcT/ACHE/wAhxP8aIcT/zCHE//8hxP/+IcT/riHE/wUhxP8AIcT/ACHE/wohxP8rIcT/RiHE/z8hxP8fIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP+sIcT//yHE//8hxP//IcT/zCHE/7ohxP//IcT//yHE//8hxP/IIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/GyHE/xIhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/8ghxP//IcT//yHE//8hxP+7IcT/pyHE//8hxP//IcT//yHE/+chxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/5iHE//8hxP//IcT//yHE/6ghxP+NIcT//yHE//8hxP//IcT//yHE/yohxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/ykhxP//IcT//yHE//8hxP//IcT/jSHE/3EhxP//IcT//yHE//8hxP//IcT/uCHE/wMhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8DIcT/uCHE//8hxP//IcT//yHE//8hxP9xIcT/UiHE//8hxP//IcT//yHE//8hxP//IcT/uCHE/ykhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8AIcT/KSHE/7ghxP//IcT//yHE//8hxP//IcT//yHE/1EhxP8WIcT/+yHE//8hxP//IcT//yHE//8hxP//IcT//yHE/+chxP/FIcT/rCHE/5ghxP+HIcT/dyHE/3chxP9wIcT/cCHE/3chxP93IcT/hyHE/5ghxP+sIcT/xSHE/+chxP//IcT//yHE//8hxP//IcT//yHE//8hxP/7IcT/FiHE/wAhxP+cIcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE/58hxP8AIcT/ACHE/w8hxP/RIcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP/RIcT/DyHE/wAhxP8AIcT/ACHE/xEhxP+dIcT/+iHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP//IcT//yHE//8hxP/6IcT/niHE/xEhxP8AIcT/ACHE/wAhxP8AIcT/ACHE/wAhxP8WIcT/UCHE/3AhxP+PIcT/qSHE/70hxP/PIcT/3yHE/+4hxP/uIcT/8yHE//8hxP//IcT/8yHE/+4hxP/uIcT/3yHE/88hxP+9IcT/qSHE/48hxP9wIcT/UCHE/xYhxP8AIcT/ACHE/wAhxP8A8AAAD8AAAAOAAAABgAAAAQAAAAAA//8AAf//gAP//8AH///gB/gf4AfgB+AHgAHgB4PB4Aef+eAH///gB///4Af//+AH///gB4H54AeBgeAHgYHgB4GD4Afn/+AH///gA///wAH//4AA//8AAAAAAIAAAAGAAAABwAAAA/AAAA8="
$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmap.BeginInit()
$bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64)
$bitmap.EndInit()
$bitmap.Freeze()
$image = [System.Drawing.Bitmap][System.Drawing.Image]::FromStream($bitmap.StreamSource)
$icon = [System.Drawing.Icon]::FromHandle($image.GetHicon())

# Add the systray icon
$Main_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
$Main_Tool_Icon.Text = "Piekuren: $($telenetStats.Split(";")[0])GB  Daluren: $($telenetStats.Split(";")[1])GB  Reset op: $($telenetStats.Split(";")[3])"
$Main_Tool_Icon.Icon = $icon
$Main_Tool_Icon.Visible = $true
 
# Make PowerShell Disappear
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
 
# Use a Garbage colection to reduce Memory RAM
[System.GC]::Collect()

# Add all menus as context menus
$contextmenu = New-Object System.Windows.Forms.ContextMenuStrip

$Menu_Refresh = New-Object System.Windows.Forms.ToolStripMenuItem
$Menu_Refresh.Text = "Last Refresh: $((Get-Date).ToShortTimeString())"
$contextmenu.Items.Add($Menu_Refresh)
 
$Menu_Exit = New-Object System.Windows.Forms.ToolStripMenuItem
$Menu_Exit.Text = "Exit"
$contextmenu.Items.Add($Menu_Exit)

$Main_Tool_Icon.ContextMenuStrip = $contextmenu

# Refresh data
$Menu_Refresh.add_Click({
    $Menu_Refresh.Text = "Last Refresh: $((Get-Date).ToShortTimeString())"
    $telenetStats = get-telenetStats
    $Main_Tool_Icon.Text = "Piekuren: $($telenetStats.Split(";")[0])GB  Daluren: $($telenetStats.Split(";")[1])GB  Reset op: $($telenetStats.Split(";")[3])"
})

# Action after clicking on the Exit context menu
$Menu_Exit.add_Click({
    $Main_Tool_Icon.Visible = $false
    $window.Close()
    Stop-Process $pid
})

$appContext = New-Object System.Windows.Forms.ApplicationContext
[void][System.Windows.Forms.Application]::Run($appContext)

