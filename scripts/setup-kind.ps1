# Setup Kind (Kubernetes in Docker) as alternative to Docker Desktop Kubernetes

Write-Host "Setting up Kind cluster for canary deployment demo..." -ForegroundColor Green

# Check if kind is installed
try {
    kind version
    Write-Host "Kind is already installed!" -ForegroundColor Green
} catch {
    Write-Host "Kind not found. Please install it from: https://kind.sigs.k8s.io/docs/user/quick-start/#installation" -ForegroundColor Yellow
    Write-Host "For Windows: choco install kind" -ForegroundColor Yellow
    Write-Host "Or download from GitHub releases" -ForegroundColor Yellow
    exit 1
}

# Create kind cluster
Write-Host "Creating kind cluster..." -ForegroundColor Yellow
kind create cluster --name canary-demo

# Wait for cluster to be ready
Write-Host "Waiting for cluster to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Verify cluster
Write-Host "Cluster status:" -ForegroundColor Cyan
kubectl get nodes
kubectl cluster-info

Write-Host "Kind cluster is ready for canary deployment demo!" -ForegroundColor Green