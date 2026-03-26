<#
.SYNOPSIS
    Ookla Speedtest for PRTG - No-Clone Edition.
.PARAMETERS
    -AdapterNumber: Index (1, 2...)
    -d: Expected Download (Mbps)
    -u: Expected Upload (Mbps)
    -l, -j, -p: Max Latency, Jitter, Loss
    -IgnoreLimits: 1 = Active (LimitMode 0)
#>

param([int]$AdapterNumber=1,[int]$d=100,[int]$u=40,[float]$l=30.0,[float]$j=5.0,[float]$p=0.2,[int]$IgnoreLimits=0,[string]$ServerId,[int]$Precision=1)

$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'

try {
    $exe = Join-Path $PSScriptRoot 'Ookla-Speedtest\speedtest.exe'
    $adp = (Get-NetAdapter | Where Status -eq "Up" | Sort Name)[$AdapterNumber-1]
    $ip = (Get-NetIPAddress -InterfaceIndex $adp.ifIndex -AddressFamily IPv4).IPAddress

    $res = & $exe "--accept-license" "--accept-gdpr" "--format=json" "--precision=$Precision" "--ip=$ip" $(if($ServerId){"--server-id=$ServerId"}) 2>&1
    $json = ($res | Where { $_ -match '"type":"result"' }) | ConvertFrom-Json

    function n($name, $val, $unit, $cu, $w, $e, $mw) {
        $xml = "<result><channel>$name</channel><value>$val</value><unit>$unit</unit><customUnit>$cu</customUnit><float>1</float>"
        if ($IgnoreLimits -eq 1) {
            $xml += "<LimitMode>0</LimitMode>"
        } else {
            $xml += "<LimitMode>1</LimitMode>"
            if ($w) { $xml += "<LimitMinWarning>$w</LimitMinWarning><LimitMinError>$e</LimitMinError>" }
            if ($mw) { $xml += "<LimitMaxWarning>$mw</LimitMaxWarning>" }
        }
        $xml + "</result>"
    }

    $xml = "<prtg>"
    $xml += n "Download" ([math]::Round($json.download.bandwidth/125000,$Precision)) "Custom" "Mbps" ([math]::Round($d*0.9)) ([math]::Round($d*0.8)) $null
    $xml += n "Upload" ([math]::Round($json.upload.bandwidth/125000,$Precision)) "Custom" "Mbps" ([math]::Round($u*0.9)) ([math]::Round($u*0.8)) $null
    $xml += n "Latency" ([math]::Round($json.ping.latency,$Precision)) "TimeResponse" "" $null $null $l
    $xml += n "Jitter" ([math]::Round($json.ping.jitter,$Precision)) "TimeResponse" "" $null $null $j
    $xml += n "Packet Loss" ([math]::Round($json.packetLoss,2)) "Custom" "%" $null $null $p
    $xml += "<text>Ext IP: $($json.interface.externalIp) | Srv: $($json.server.name) | Adapt: $($adp.Name)</text></prtg>"
    
    Write-Host $xml.Trim()
} catch {
    Write-Host "<prtg><error>1</error><text>Error: $($_.Exception.Message -replace '[<>&]', '')</text></prtg>"
}