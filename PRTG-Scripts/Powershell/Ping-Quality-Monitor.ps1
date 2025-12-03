<#
.SYNOPSIS
    PRTG Ping Quality Monitor
.PARAMETER Target
    IP/hostname to ping (default: 9.9.9.9)
.PARAMETER Count
    Number of pings (default: 10)
.PARAMETER DelayMs
    Delay between pings in ms (default: 5)
.EXAMPLE
    -Target 1.1.1.1 -Count 20 -DelayMs 10
.NOTES
    See README.md for full documentation
#>

param(
    [string]$Target = "9.9.9.9",
    [int]$Count = 10,
    [int]$DelayMs = 5
)

$ErrorActionPreference = 'Stop'

try {
    # Perform multiple pings with delay
    $pingResults = @()
    $successCount = 0
    
    for ($i = 0; $i -lt $Count; $i++) {
        $ping = Test-Connection -ComputerName $Target -Count 1 -ErrorAction SilentlyContinue
        if ($ping) {
            $pingResults += $ping.ResponseTime
            $successCount++
        }
        if ($i -lt ($Count - 1)) {
            Start-Sleep -Milliseconds $DelayMs
        }
    }
    
    # Calculate packet loss
    $packetLoss = [math]::Round((($Count - $successCount) / $Count) * 100, 2)
    
    # Calculate latency and jitter
    if ($successCount -gt 0) {
        $avgLatency = [math]::Round(($pingResults | Measure-Object -Average).Average, 2)
        $minLatency = [math]::Round(($pingResults | Measure-Object -Minimum).Minimum, 2)
        $maxLatency = [math]::Round(($pingResults | Measure-Object -Maximum).Maximum, 2)
        
        # Calculate jitter (consecutive packet variation)
        if ($successCount -gt 1) {
            $consecutiveDiffs = @()
            for ($i = 1; $i -lt $pingResults.Count; $i++) {
                $consecutiveDiffs += [Math]::Abs($pingResults[$i] - $pingResults[$i-1])
            }
            $jitter = [math]::Round(($consecutiveDiffs | Measure-Object -Average).Average, 2)
        } else {
            $jitter = 0
        }
    } else {
        $avgLatency = 0
        $minLatency = 0
        $maxLatency = 0
        $jitter = 0
    }
    
    # Build XML output
    $xml = '<prtg>' +
           "<r><channel>Latency Average</channel><value>$avgLatency</value><unit>TimeResponse</unit><float>1</float><LimitMaxWarning>30</LimitMaxWarning><LimitMaxError>50</LimitMaxError><LimitMode>1</LimitMode></r>" +
           "<r><channel>Latency Min</channel><value>$minLatency</value><unit>TimeResponse</unit><float>1</float></r>" +
           "<r><channel>Latency Max</channel><value>$maxLatency</value><unit>TimeResponse</unit><float>1</float></r>" +
           "<r><channel>Jitter</channel><value>$jitter</value><unit>TimeResponse</unit><float>1</float><LimitMaxWarning>5</LimitMaxWarning><LimitMaxError>10</LimitMaxError><LimitMode>1</LimitMode></r>" +
           "<r><channel>Packet Loss</channel><value>$packetLoss</value><unit>Custom</unit><customUnit>%</customUnit><float>1</float><LimitMaxWarning>1</LimitMaxWarning><LimitMaxError>5</LimitMaxError><LimitMode>1</LimitMode></r>" +
           "<text>Target: $Target ($successCount/$Count pings successful)</text>" +
           '</prtg>'
    
    Write-Host $xml
}
catch {
    Write-Host "<prtg><e>1</e><text>Ping test failed: $($_.Exception.Message)</text></prtg>"
    exit 0
}
