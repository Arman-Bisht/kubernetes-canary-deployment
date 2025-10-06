# Test simple canary app locally on Windows

Write-Host "Testing simple canary app locally..." -ForegroundColor Green

# Start both versions
Write-Host "Starting v1.0 (stable) on port 3001..." -ForegroundColor Yellow
docker run -d -p 3001:3000 -e APP_VERSION=v1.0 --name test-stable simple-canary-app:v1.0

Write-Host "Starting v2.0 (canary) on port 3002..." -ForegroundColor Yellow  
docker run -d -p 3002:3000 -e APP_VERSION=v2.0 --name test-canary simple-canary-app:v2.0

Write-Host "Waiting for containers to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "Testing stable version (v1.0):" -ForegroundColor Cyan
$stable = Invoke-WebRequest -Uri http://localhost:3001 -UseBasicParsing
$stable.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3

Write-Host ""
Write-Host "Testing canary version (v2.0):" -ForegroundColor Cyan
$canary = Invoke-WebRequest -Uri http://localhost:3002 -UseBasicParsing  
$canary.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3

Write-Host ""
Write-Host "Health checks:" -ForegroundColor Cyan
Write-Host "Stable health:"
$stableHealth = Invoke-WebRequest -Uri http://localhost:3001/health -UseBasicParsing
$stableHealth.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3

Write-Host ""
Write-Host "Canary health:"
$canaryHealth = Invoke-WebRequest -Uri http://localhost:3002/health -UseBasicParsing
$canaryHealth.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3

Write-Host ""
Write-Host "Cleaning up..." -ForegroundColor Yellow
docker stop test-stable test-canary
docker rm test-stable test-canary

Write-Host "Local test complete!" -ForegroundColor Green