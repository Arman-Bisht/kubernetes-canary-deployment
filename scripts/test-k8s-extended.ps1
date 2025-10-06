# Extended test for Kubernetes canary deployment

Write-Host "Extended testing of Kubernetes canary deployment..." -ForegroundColor Green
Write-Host "Make sure port-forward is running: kubectl port-forward svc/simple-app 8080:80 -n canary-demo" -ForegroundColor Yellow
Write-Host ""

# Test more requests with different approaches
$stableCount = 0
$canaryCount = 0
$totalRequests = 30

Write-Host "Making $totalRequests requests to see traffic distribution..." -ForegroundColor Cyan

for ($i = 1; $i -le $totalRequests; $i++) {
    try {
        # Create a new web session for each request to avoid connection reuse
        $response = Invoke-WebRequest -Uri http://localhost:8080 -UseBasicParsing -TimeoutSec 5 -SessionVariable "session$i"
        $json = $response.Content | ConvertFrom-Json
        
        if ($json.version -eq "v1.0") {
            $stableCount++
            Write-Host "Request $i`: STABLE (v1.0) - Pod: $($json.hostname)" -ForegroundColor Blue
        } elseif ($json.version -eq "v2.0") {
            $canaryCount++
            Write-Host "Request $i`: CANARY (v2.0) - Pod: $($json.hostname)" -ForegroundColor Green
        }
        
        Start-Sleep -Milliseconds 200
    } catch {
        Write-Host "Request $i`: Failed - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Traffic Distribution:" -ForegroundColor Yellow
Write-Host "Stable (v1.0): $stableCount requests ($(($stableCount/$totalRequests)*100)%)" -ForegroundColor Blue
Write-Host "Canary (v2.0): $canaryCount requests ($(($canaryCount/$totalRequests)*100)%)" -ForegroundColor Green
Write-Host ""

$expectedCanaryPercent = 33.33  # 1 canary pod out of 3 total pods
$actualCanaryPercent = ($canaryCount/$totalRequests)*100

Write-Host "Expected canary traffic: ~33% (1 canary pod out of 3 total)" -ForegroundColor Yellow
Write-Host "Actual canary traffic: $([math]::Round($actualCanaryPercent, 1))%" -ForegroundColor Yellow

if ($canaryCount -gt 0 -and $stableCount -gt 0) {
    Write-Host "✅ Canary deployment is working! Traffic is being distributed between versions." -ForegroundColor Green
} elseif ($stableCount -eq $totalRequests) {
    Write-Host "⚠️  Only stable version responding. This might be due to connection persistence." -ForegroundColor Yellow
    Write-Host "   Try stopping the port-forward and starting it again." -ForegroundColor Yellow
} elseif ($canaryCount -eq $totalRequests) {
    Write-Host "⚠️  Only canary version responding. Check if stable pods are running." -ForegroundColor Yellow
} else {
    Write-Host "❌ No successful responses. Check if port-forward is running." -ForegroundColor Red
}