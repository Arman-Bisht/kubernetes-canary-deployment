# Install Istio on Kubernetes cluster

Write-Host "Installing Istio for canary deployment..." -ForegroundColor Green

# Check if istioctl is available
try {
    istioctl version --remote=false
    Write-Host "Istio CLI is already installed!" -ForegroundColor Green
} catch {
    Write-Host "Istio CLI not found. Please install it first:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://istio.io/latest/docs/setup/getting-started/#download" -ForegroundColor Yellow
    Write-Host "2. Or use: curl -L https://istio.io/downloadIstio | sh -" -ForegroundColor Yellow
    Write-Host "3. Add istioctl to your PATH" -ForegroundColor Yellow
    exit 1
}

# Install Istio with demo profile (good for learning)
Write-Host "Installing Istio with demo profile..." -ForegroundColor Yellow
istioctl install --set values.defaultRevision=default -y

# Enable automatic sidecar injection for our namespace
Write-Host "Enabling sidecar injection for canary-demo namespace..." -ForegroundColor Yellow
kubectl label namespace canary-demo istio-injection=enabled --overwrite

# Verify installation
Write-Host "Verifying Istio installation..." -ForegroundColor Cyan
kubectl get pods -n istio-system

Write-Host "Istio installation complete!" -ForegroundColor Green
Write-Host "Next: Restart pods to get Istio sidecars injected" -ForegroundColor Yellow