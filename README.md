# PRTG Custom Sensors

A collection of PowerShell-based custom sensors for PRTG Network Monitor that extend monitoring capabilities beyond standard sensors.

## 📊 Available Sensors

### 🌐 Ookla Speedtest Sensor
**File:** `Ookla-Speedtest.ps1`

Monitors internet connection bandwidth using Ookla's Speedtest CLI.

**Channels:**
- Download Speed (Mbps)
- Upload Speed (Mbps)
- Latency (ms)
- Jitter (ms)
- Packet Loss (%)
- External IP (displayed in sensor message)

**Requirements:**
- [Ookla Speedtest CLI](https://www.speedtest.net/apps/cli)
- Extract `speedtest.exe` to subfolder: `Ookla-Speedtest\speedtest.exe`

**Limits:**
- Download: Warning <900 Mbps, Error <800 Mbps
- Upload: Warning <40 Mbps, Error <35 Mbps
- Latency: Warning >30ms, Error >35ms
- Jitter: Warning >5ms, Error >10ms
- Packet Loss: Warning >0.2%, Error >0.5%

**Recommended Interval:** 4-6 times daily (bandwidth tests consume full connection)

---

### 🏓 Ping Quality Monitor
**File:** `Ping-Quality-Monitor.ps1`

Lightweight network quality monitoring using ICMP pings - no bandwidth consumption.

**Channels:**
- Latency Average (ms)
- Latency Min (ms)
- Latency Max (ms)
- Jitter (ms) - consecutive packet variation
- Packet Loss (%)

**Parameters:**
- `-Target` - IP/hostname to ping (default: 9.9.9.9)
- `-Count` - Number of pings (default: 10)
- `-DelayMs` - Delay between pings in ms (default: 5)

**Example Usage:**
```powershell
# Default (9.9.9.9)
./Ping-Quality-Monitor.ps1

# Custom target
./Ping-Quality-Monitor.ps1 -Target 1.1.1.1

# Custom target with more pings
./Ping-Quality-Monitor.ps1 -Target 8.8.8.8 -Count 20
```

**Recommended Targets:**
- `9.9.9.9` - Quad9 DNS (privacy-focused, reliable)
- `1.1.1.1` - Cloudflare (fast, popular)
- `8.8.4.4` - Google secondary DNS
- `208.67.222.222` - OpenDNS

**Limits:**
- Latency: Warning >30ms, Error >50ms
- Jitter: Warning >5ms, Error >10ms
- Packet Loss: Warning >1%, Error >5%

**Recommended Interval:** 2-5 minutes (lightweight, no bandwidth impact)

---

## 🚀 Installation

### General Setup
1. Download the desired sensor script(s)
2. Copy to PRTG Custom Sensors directory:
   ```
   C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML\
   ```
3. For Speedtest sensor: Create subfolder `Ookla-Speedtest` and place `speedtest.exe` inside
4. In PRTG: Add new sensor → **EXE/Script Advanced**
5. Select the script and configure parameters if needed
6. Set appropriate scanning interval

### First-Time Speedtest Setup
Run `speedtest.exe` manually once to accept the license:
```powershell
cd "C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML\Ookla-Speedtest"
./speedtest.exe --accept-license --accept-gdpr
```

---

## 💡 Why These Sensors?

**Multi-Channel Efficiency**
- Combine multiple metrics in one sensor (reduces sensor count)
- Custom limits tailored to your SLA requirements
- Proper jitter calculation using consecutive packet variation

**Bandwidth-Aware Monitoring**
- Speedtest: Full bandwidth tests for SLA verification
- Ping Monitor: Continuous quality checks without bandwidth consumption
- Use both for complete coverage

**Flexible & Customizable**
- Adjustable limits in script or PRTG interface
- Configurable parameters
- Easy to modify for specific needs

---

## 📝 Customizing Limits

Edit limit values directly in the scripts by modifying these XML attributes:
- `<LimitMinWarning>` / `<LimitMinError>` - Minimum thresholds (bandwidth)
- `<LimitMaxWarning>` / `<LimitMaxError>` - Maximum thresholds (latency, jitter, packet loss)

Or adjust limits after creation via PRTG sensor settings.

---

## 🤝 Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

---

## 📄 License

MIT License - feel free to use and modify for your monitoring needs.

---

## ⚙️ Requirements

- PRTG Network Monitor
- PowerShell 5.0 or later
- Windows Server/Client with PRTG probe installed
- Ookla Speedtest CLI (for speedtest sensor)

---

## 🔧 Troubleshooting

**Sensor shows "0 #" values:**
- Run script manually in PowerShell ISE to verify XML output
- Check execution policy: `Set-ExecutionPolicy RemoteSigned`
- Verify file paths and speedtest.exe location

**Speedtest fails:**
- Run `speedtest.exe` manually to accept license
- Check network proxy settings
- Verify speedtest.exe version compatibility

**Ping sensor not working:**
- Verify target IP is reachable
- Check Windows Firewall allows ICMP
- Test with: `Test-Connection -ComputerName 9.9.9.9 -Count 4`

---

## 📬 Support

For issues or questions, please open an issue on GitHub.
