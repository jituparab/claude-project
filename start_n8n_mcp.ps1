# 1️⃣ Enable TCP transport and launch MCP server
Write-Host "Starting n8n-mcp with TCP transport on port 37229"

$env:MCP_USE_TCP = "true"
$env:MCP_TCP_PORT = "37229"

try {
    $process = Start-Process powershell -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "npx n8n-mcp" -WindowStyle Normal -PassThru
    Write-Host "n8n-mcp process started with ID: $($process.Id)"
}
catch {
    Write-Error "Failed to start n8n-mcp process."
    Write-Error $_
    exit 1
}

# 2️⃣ Wait for the TCP port
function Wait-ForPort {
    param(
        [int]$port,
        [int]$delaySeconds = 1,
        [int]$timeoutSeconds = 30
    )

    $timeout = New-TimeSpan -Seconds $timeoutSeconds
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    while ($stopwatch.Elapsed -lt $timeout) {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect("127.0.0.1", $port)
            if ($tcpClient.Connected) {
                Write-Host "Port $port is now open."
                $tcpClient.Close()
                return
            }
        }
        catch {
            # Port is not yet open
        }
        finally {
            if ($tcpClient) {
                $tcpClient.Dispose()
            }
        }

        Start-Sleep -Seconds $delaySeconds
    }

    Write-Error "Timeout: Port $port did not open within $timeoutSeconds seconds."
    exit 1
}

Wait-ForPort -port 37229 -delaySeconds 2
