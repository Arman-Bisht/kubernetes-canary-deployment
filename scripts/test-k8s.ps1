# Test Kubernetes canary deployment

Write-Host "Testing Kubernetes canary deployment..." -ForegroundColor Green
Write-Host "Make sure port-forward is running: kubectl port-forward svc/simple-app 8080:80 -n canary-demo" -ForegroundColor Yellow
Write-Host ""

# Test multiple requests to see load balancing
$stableCount = 0
$canaryCount = 0

Write-Host "Making 10 requests to see traffic distribution..." -ForegroundColor Cyan

for ($i = 1; $i -le 10; $i++) {
    try {
        $response = Invoke-WebRequest -Uri http://localhost:8080 -UseBasicParsing -TimeoutSec 5
        $json = $response.Content | ConvertFrom-Json
        
        if ($json.version -eq "v1.0") {
            $stableCount++
            Write-Host "Request $i`: STABLE (v1.0) - $($json.message)" -ForegroundColor Blue
        } elseif ($json.version -eq "v2.0") {
            $canaryCount++
            Write-Host "Request $i`: CANARY (v2.0) - $($json.message)" -ForegroundColor Green
        }
        
        Start-Sleep -Milliseconds 500
    } catch {
        Write-Host "Request $i`: Failed - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Traffic Distribution:" -ForegroundColor Yellow
Write-Host "Stable (v1.0): $stableCount requests ($(($stableCount/10)*100)%)" -ForegroundColor Blue
Write-Host "Canary (v2.0): $canaryCount requests ($(($canaryCount/10)*100)%)" -ForegroundColor Green
Write-Host ""

if ($canaryCount -gt 0 -and $stableCount -gt 0) {
    Write-Host "✅ Canary deployment is working! Traffic is being distributed between versions." -ForegroundColor Green
} elseif ($stableCount -eq 10) {
    Write-Host "⚠️  Only stable version responding. Check if canary pods are running." -ForegroundColor Yellow
} elseif ($canaryCount -eq 10) {
    Write-Host "⚠️  Only canary version responding. Check if stable pods are running." -ForegroundColor Yellow
} else {
    Write-Host "❌ No successful responses. Check if port-forward is running." -ForegroundColor Red
}