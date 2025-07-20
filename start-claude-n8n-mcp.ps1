# Launcher script for Claude + n8n-MCP

$logFile = "$HOME\Documents\mcp-launch.log"

function Write-Log {
    param ([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp - $msg"
    Write-Host $msg
    Add-Content -Path $logFile -Value $line
}

function Wait-ForPort {
    param (
        [int]$port = 37229,
        [int]$delaySeconds = 2
    )
    while ($true) {
        $check = netstat -aon | Select-String ":$port.*LISTENING"
        if ($check) {
            Write-Log "Port $port is now listening."
            return $true
        } else {
            Write-Log "Waiting for port $port..."
            Start-Sleep -Seconds $delaySeconds
        }
    }
}

# Step 1: Start n8n-MCP Server
Write-Log "Starting n8n-MCP server..."
$env:MCP_USE_TCP = "true"
$env:MCP_TCP_PORT = "37229"
Start-Process powershell -ArgumentList "npx n8n-mcp" -WindowStyle Normal

# Step 2: Wait for port 37229
Wait-ForPort -port 37229 -delaySeconds 2

# Step 3: Launch Claude Desktop
$claudePath = "$env:USERPROFILE\AppData\Local\Programs\claude\Claude.exe"
if (Test-Path $claudePath) {
    Write-Log "Launching Claude Desktop..."
    Start-Process $claudePath
} else {
    Write-Log "Claude Desktop not found at: $claudePath"
    Read-Host "Press Enter to exit"
    exit
}

Start-Sleep -Seconds 3

# Step 4: Launch mcp-inspector
Write-Log "Launching mcp-inspector..."
Start-Process powershell -ArgumentList "npx mcp-inspector" -WindowStyle Normal

Write-Log "All systems started successfully."
