$stableCount = 0
$canaryCount = 0

Write-Host "Testing traffic distribution..." -ForegroundColor Yellow

for ($i = 1; $i -le 20; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing
        $content = $response.Content
        
        if ($content -match '"version":"v1\.0"') {
            $stableCount++
            Write-Host "Request $i`: STABLE (v1.0)" -ForegroundColor Green
        } elseif ($content -match '"version":"v2\.0"') {
            $canaryCount++
            Write-Host "Request $i`: CANARY (v2.0)" -ForegroundColor Blue
        } else {
            Write-Host "Request $i`: UNKNOWN" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Request $i`: ERROR - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Results:" -ForegroundColor Cyan
Write-Host "  Stable (v1.0): $stableCount ($([math]::Round($stableCount/20*100, 1))%)" -ForegroundColor Green
Write-Host "  Canary (v2.0): $canaryCount ($([math]::Round($canaryCount/20*100, 1))%)" -ForegroundColor Blue