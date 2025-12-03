<#
.SYNOPSIS
    PRTG Speedtest Sensor - Ookla CLI
.NOTES
    See README.md for full documentation
#>

$ErrorActionPreference = 'Stop'

# Path to speedtest.exe
$exePath = Join-Path $PSScriptRoot 'Ookla-Speedtest\speedtest.exe'

if (-not (Test-Path $exePath)) {
    Write-Host '<prtg><error>1</error><text>speedtest.exe not found at expected location</text></prtg>'
    exit 0
}

try {
    # Run speedtest with JSON output
    $result = & $exePath --accept-license --accept-gdpr --format=json 2>&1
    
    # Convert from JSON
    $json = $result | ConvertFrom-Json
    
    # Extract values with null checks
    $download = if ($json.download.bandwidth) { [math]::Round($json.download.bandwidth / 125000, 2) } else { 0 }
    $upload = if ($json.upload.bandwidth) { [math]::Round($json.upload.bandwidth / 125000, 2) } else { 0 }
    $latency = if ($json.ping.latency) { [math]::Round($json.ping.latency, 2) } else { 0 }
    $jitter = if ($json.ping.jitter) { [math]::Round($json.ping.jitter, 2) } else { 0 }
    $packetLoss = if ($json.packetLoss) { [math]::Round($json.packetLoss, 2) } else { 0 }
    $externalIP = if ($json.interface.externalIp) { $json.interface.externalIp } else { 'N/A' }
    
    # Build XML with warning and error limits
    $xml = '<prtg>' +
           "<result><channel>Download</channel><value>$download</value><unit>Custom</unit><customUnit>Mbps</customUnit><float>1</float><LimitMinWarning>900</LimitMinWarning><LimitMinError>800</LimitMinError><LimitMode>1</LimitMode></result>" +
           "<result><channel>Upload</channel><value>$upload</value><unit>Custom</unit><customUnit>Mbps</customUnit><float>1</float><LimitMinWarning>40</LimitMinWarning><LimitMinError>35</LimitMinError><LimitMode>1</LimitMode></result>" +
           "<result><channel>Latency</channel><value>$latency</value><unit>TimeResponse</unit><float>1</float><LimitMaxWarning>30</LimitMaxWarning><LimitMaxError>35</LimitMaxError><LimitMode>1</LimitMode></result>" +
           "<result><channel>Jitter</channel><value>$jitter</value><unit>TimeResponse</unit><float>1</float><LimitMaxWarning>5</LimitMaxWarning><LimitMaxError>10</LimitMaxError><LimitMode>1</LimitMode></result>" +
           "<result><channel>Packet Loss</channel><value>$packetLoss</value><unit>Custom</unit><customUnit>%</customUnit><float>1</float><LimitMaxWarning>0.2</LimitMaxWarning><LimitMaxError>0.5</LimitMaxError><LimitMode>1</LimitMode></result>" +
           "<text>External IP: $externalIP</text>" +
           '</prtg>'
    
    Write-Host $xml
}
catch {
    Write-Host "<prtg><error>1</error><text>Speedtest failed: $($_.Exception.Message)</text></prtg>"
    exit 0
}
