#!/bin/bash

echo "Deploying basic canary setup to K3s..."

# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy stable version
echo "Deploying stable version..."
kubectl apply -f k8s/deployment-stable.yaml

# Deploy service
kubectl apply -f k8s/service.yaml

# Wait for stable deployment
echo "Waiting for stable deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/simple-app-stable -n canary-demo

echo "Basic deployment complete!"
echo "Check status with: kubectl get pods -n canary-demo"