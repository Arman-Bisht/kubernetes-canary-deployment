# Interview Demo Guide

## 🎯 Quick Demo Commands for Interviewers

### Prerequisites Check
```powershell
# Verify tools are available
docker --version
kubectl version --client
istioctl version  # If Istio is installed
```

### 1. Start the System

#### First Time Setup (5 minutes)
```powershell
# Build Docker images (only needed once)
docker build -t simple-canary-app:v1.0 --build-arg APP_VERSION=v1.0 ./app
docker build -t simple-canary-app:v2.0 --build-arg APP_VERSION=v2.0 ./app

# Deploy to Kubernetes (only needed once)
kubectl apply -f k8s/
kubectl label namespace canary-demo istio-injection=enabled --overwrite
kubectl apply -f k8s/istio-*.yaml

# Restart deployments for Istio sidecars
kubectl rollout restart deployment/simple-app-stable -n canary-demo
kubectl rollout restart deployment/simple-app-canary -n canary-demo
```

#### After System Restart (30 seconds)
```powershell
# Quick check - are pods running?
kubectl get pods -n canary-demo

# If pods are not running or not ready, restart deployments
kubectl rollout restart deployment/simple-app-stable -n canary-demo
kubectl rollout restart deployment/simple-app-canary -n canary-demo
```

### 2. Wait for System Ready (2 minutes)
```powershell
# Wait for deployments
kubectl rollout status deployment/simple-app-stable -n canary-demo --timeout=300s
kubectl rollout status deployment/simple-app-canary -n canary-demo --timeout=300s

# Verify pods are ready (should show 2/2 containers)
kubectl get pods -n canary-demo
```

### 3. Demo the System (5 minutes)

#### Show System Architecture
```powershell
# Show all components
kubectl get all -n canary-demo

# Show Istio configuration
kubectl get gateway,virtualservice,destinationrule -n canary-demo
```

#### Test Traffic Distribution
```powershell
# Run comprehensive test
powershell -ExecutionPolicy Bypass -File test-system.ps1
```

#### Manual Testing
```powershell
# Test stable version (regular traffic)
Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing | Select-Object -ExpandProperty Content

# Test canary version (header-based routing)
Invoke-WebRequest -Uri "http://localhost/" -Headers @{"canary"="true"} -UseBasicParsing | Select-Object -ExpandProperty Content

# Show health endpoints
Invoke-WebRequest -Uri "http://localhost/health/live" -UseBasicParsing | Select-Object -ExpandProperty Content
Invoke-WebRequest -Uri "http://localhost/health/ready" -UseBasicParsing | Select-Object -ExpandProperty Content

# Show metrics
Invoke-WebRequest -Uri "http://localhost/metrics" -UseBasicParsing | Select-Object -ExpandProperty Content
```

#### Show Traffic Distribution
```powershell
# Quick traffic test (10 requests)
Write-Host "Testing traffic distribution..." -ForegroundColor Yellow
for ($i = 1; $i -le 10; $i++) {
    $response = Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing
    $version = ($response.Content | ConvertFrom-Json).version
    Write-Host "Request $i`: $version" -ForegroundColor $(if($version -eq "v1.0") {"Green"} else {"Blue"})
}
```

### 4. Demo Canary Operations (3 minutes)

#### Show Rollback Capability
```powershell
# Show current traffic weights
kubectl get virtualservice simple-app-vs -n canary-demo -o jsonpath='{.spec.http[1].route[*].weight}'

# Simulate rollback (dry run)
Write-Host "Simulating rollback..." -ForegroundColor Yellow
Write-Host "Would route 100% traffic to stable and scale down canary" -ForegroundColor Cyan
```

#### Show Monitoring
```powershell
# Show pod logs
kubectl logs -n canary-demo -l app=simple-app --tail=5

# Show resource usage
kubectl top pods -n canary-demo 2>$null || Write-Host "Metrics server not available"
```

## 🎯 Key Points to Highlight

### Technical Skills Demonstrated
- **Kubernetes**: Deployments, Services, ConfigMaps, Secrets, RBAC
- **Istio Service Mesh**: Gateway, VirtualService, DestinationRule
- **Docker**: Multi-stage builds, container orchestration
- **DevOps**: Automation scripts, testing, monitoring
- **Traffic Management**: Weight-based and header-based routing

### Architecture Highlights
- **80/20 Traffic Split**: Automated traffic distribution
- **Istio Sidecars**: Service mesh integration (2/2 containers)
- **Health Probes**: Kubernetes liveness/readiness checks
- **Metrics**: Prometheus-compatible monitoring
- **Security**: RBAC, ConfigMaps, Secrets

### Production-Ready Features
- **Automated Rollback**: Safety mechanisms
- **Header-based Testing**: Force canary routing
- **Comprehensive Logging**: Structured JSON logs
- **Configuration Management**: Environment-specific settings

## 🚀 Interview Talking Points

1. **"This demonstrates production-ready canary deployments"**
2. **"Notice the 2/2 containers - that's Istio sidecar injection working"**
3. **"The system automatically splits traffic 80% stable, 20% canary"**
4. **"I can force canary routing with headers for testing"**
5. **"All components are monitored with health checks and metrics"**
6. **"The system includes automated rollback capabilities"**

## 🧹 Cleanup After Demo
```powershell
# Remove the application
kubectl delete namespace canary-demo

# Optional: Remove Istio (if needed)
# istioctl uninstall --purge -y
```

## ⏱️ Total Demo Time: ~15 minutes
- Setup: 5 minutes
- Wait: 2 minutes  
- Demo: 5 minutes
- Operations: 3 minutes