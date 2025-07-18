# PowerShell launcher with TCP support for Claude + MCP

$logFile = "$HOME\Documents\mcp-launch.log"

function Write-Log {
    param([string]$msg)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host $msg
    Add-Content -Path $logFile -Value "$ts - $msg"
}

function Wait-ForPort {
    param([int]$port=37229, [int]$delay=2)
    while ($true) {
        $conn = netstat -aon | Select-String ":$port.*LISTENING"
        if ($conn) { Write-Log "Port $port is listening."; return }
        else { Write-Log "Waiting for port $port..."; Start-Sleep -Seconds $delay }
    }
}

# Step 1: Launch MCP server in TCP mode
Write-Log "Starting n8n-mcp with TCP on port 37229"
$env:MCP_USE_TCP = "true"
$env:MCP_TCP_PORT = "37229"
Start-Process powershell -ArgumentList 'npx n8n-mcp' -WindowStyle Normal

# Step 2: Wait for the TCP port to become available
Wait-ForPort -port 37229 -delay 2

# Step 3: Launch Claude Desktop
$claudePath = "$env:USERPROFILE\AppData\Local\Programs\claude\Claude.exe"
if (Test-Path $claudePath) {
    Write-Log "Launching Claude Desktop..."
    Start-Process $claudePath
} else {
    Write-Log "ERROR: Claude Desktop not found at $claudePath"
    Read-Host "Press Enter to exit"
    exit
}

# Step 4: Launch mcp-inspector
Start-Sleep -Seconds 3
Write-Log "Launching mcp-inspector"
Start-Process powershell -ArgumentList 'npx mcp-inspector' -WindowStyle Normal

Write-Log "✅ All systems started. TCP-based MCP is ready and should connect to Claude."
