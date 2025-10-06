# Install Istio on Windows

Write-Host "Installing Istio for Windows..." -ForegroundColor Green

# Download Istio
$ISTIO_VERSION = "1.20.1"
$url = "https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istio-$ISTIO_VERSION-win.zip"
$output = "istio-$ISTIO_VERSION-win.zip"

Write-Host "Downloading Istio $ISTIO_VERSION..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $url -OutFile $output

Write-Host "Extracting Istio..." -ForegroundColor Yellow
Expand-Archive -Path $output -DestinationPath . -Force

# Add istioctl to PATH for this session
$env:PATH += ";$(Get-Location)\istio-$ISTIO_VERSION\bin"

Write-Host "Istio downloaded and extracted!" -ForegroundColor Green
Write-Host "istioctl location: $(Get-Location)\istio-$ISTIO_VERSION\bin\istioctl.exe" -ForegroundColor Cyan

# Test istioctl
Write-Host "Testing istioctl..." -ForegroundColor Yellow
& ".\istio-$ISTIO_VERSION\bin\istioctl.exe" version --remote=false

Write-Host "Now installing Istio to Kubernetes..." -ForegroundColor Yellow
& ".\istio-$ISTIO_VERSION\bin\istioctl.exe" install --set values.defaultRevision=default -y

Write-Host "Enabling sidecar injection for canary-demo namespace..." -ForegroundColor Yellow
kubectl label namespace canary-demo istio-injection=enabled --overwrite

Write-Host "Verifying Istio installation..." -ForegroundColor Cyan
kubectl get pods -n istio-system

Write-Host "Istio installation complete!" -ForegroundColor Green