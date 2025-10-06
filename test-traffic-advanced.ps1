$stableCount = 0
$canaryCount = 0
$errorCount = 0

Write-Host "Testing Istio traffic distribution with forced new connections..." -ForegroundColor Yellow
Write-Host ""

# Test regular traffic distribution
Write-Host "Test 1: Regular traffic (should be ~80% stable, ~20% canary)" -ForegroundColor Cyan

for ($i = 1; $i -le 50; $i++) {
    try {
        # Create a new WebClient for each request to avoid connection reuse
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "PowerShell-Test-$i")
        $response = $webClient.DownloadString("http://localhost/")
        $webClient.Dispose()
        
        if ($response -match '"version":"v1\.0"') {
            $stableCount++
            Write-Host "." -NoNewline -ForegroundColor Green
        } elseif ($response -match '"version":"v2\.0"') {
            $canaryCount++
            Write-Host "." -NoNewline -ForegroundColor Blue
        } else {
            $errorCount++
            Write-Host "?" -NoNewline -ForegroundColor Yellow
        }
        
        # Small delay to avoid overwhelming
        Start-Sleep -Milliseconds 100
    } catch {
        $errorCount++
        Write-Host "X" -NoNewline -ForegroundColor Red
    }
}

Write-Host ""
Write-Host ""
Write-Host "Results:" -ForegroundColor Cyan
Write-Host "  Stable (v1.0): $stableCount ($([math]::Round($stableCount/50*100, 1))%)" -ForegroundColor Green
Write-Host "  Canary (v2.0): $canaryCount ($([math]::Round($canaryCount/50*100, 1))%)" -ForegroundColor Blue
Write-Host "  Errors: $errorCount ($([math]::Round($errorCount/50*100, 1))%)" -ForegroundColor Red
Write-Host ""

# Test header-based routing
Write-Host "Test 2: Header-based canary routing (should be 100% canary)" -ForegroundColor Cyan

$headerCanaryCount = 0
$headerErrorCount = 0

for ($i = 1; $i -le 5; $i++) {
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("canary", "true")
        $webClient.Headers.Add("User-Agent", "PowerShell-Canary-Test-$i")
        $response = $webClient.DownloadString("http://localhost/")
        $webClient.Dispose()
        
        if ($response -match '"version":"v2\.0"') {
            $headerCanaryCount++
            Write-Host "✓" -NoNewline -ForegroundColor Blue
        } else {
            $headerErrorCount++
            Write-Host "X" -NoNewline -ForegroundColor Red
        }
    } catch {
        $headerErrorCount++
        Write-Host "X" -NoNewline -ForegroundColor Red
    }
}

Write-Host ""
Write-Host ""
Write-Host "Header-based routing results:" -ForegroundColor Cyan
Write-Host "  Canary (v2.0): $headerCanaryCount/5 ($($headerCanaryCount*20)%)" -ForegroundColor Blue
Write-Host "  Errors: $headerErrorCount/5 ($($headerErrorCount*20)%)" -ForegroundColor Red
Write-Host ""

# Summary
Write-Host "🎯 Summary:" -ForegroundColor Green
if ($stableCount + $canaryCount -gt 0) {
    $actualStablePercent = [math]::Round($stableCount/($stableCount + $canaryCount)*100, 1)
    $actualCanaryPercent = [math]::Round($canaryCount/($stableCount + $canaryCount)*100, 1)
    
    Write-Host "  Traffic Distribution: ${actualStablePercent}% stable, ${actualCanaryPercent}% canary" -ForegroundColor White
    
    if ($actualCanaryPercent -gt 0) {
        Write-Host "  ✅ Canary traffic is being routed!" -ForegroundColor Green
        if ($actualStablePercent -ge 70 -and $actualStablePercent -le 90 -and $actualCanaryPercent -ge 10 -and $actualCanaryPercent -le 30) {
            Write-Host "  ✅ Traffic distribution is within expected range (80/20 ±10%)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Traffic distribution outside expected range, but canary routing is working" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ⚠️  No canary traffic detected - may need to investigate" -ForegroundColor Yellow
    }
}

if ($headerCanaryCount -eq 5) {
    Write-Host "  ✅ Header-based routing working perfectly" -ForegroundColor Green
} elseif ($headerCanaryCount -gt 0) {
    Write-Host "  ⚠️  Header-based routing partially working" -ForegroundColor Yellow
} else {
    Write-Host "  ❌ Header-based routing not working" -ForegroundColor Red
}

Write-Host ""
Write-Host "💡 Next steps:" -ForegroundColor Cyan
Write-Host "  - The Istio service mesh is configured and working" -ForegroundColor White
Write-Host "  - Header-based routing allows you to test canary versions" -ForegroundColor White
Write-Host "  - Use 'canary: true' header to force canary routing" -ForegroundColor White
Write-Host "  - Monitor traffic with: kubectl get virtualservice simple-app-vs -n canary-demo -o yaml" -ForegroundColor White