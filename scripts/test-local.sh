#!/bin/bash

echo "Testing simple canary app locally..."

# Start both versions
echo "Starting v1.0 (stable) on port 3001..."
docker run -d -p 3001:3000 -e APP_VERSION=v1.0 --name test-stable simple-canary-app:v1.0

echo "Starting v2.0 (canary) on port 3002..."
docker run -d -p 3002:3000 -e APP_VERSION=v2.0 --name test-canary simple-canary-app:v2.0

echo "Waiting for containers to start..."
sleep 3

echo ""
echo "Testing stable version (v1.0):"
curl -s http://localhost:3001 | jq .

echo ""
echo "Testing canary version (v2.0):"
curl -s http://localhost:3002 | jq .

echo ""
echo "Health checks:"
echo "Stable health:"
curl -s http://localhost:3001/health | jq .

echo ""
echo "Canary health:"
curl -s http://localhost:3002/health | jq .

echo ""
echo "Cleaning up..."
docker stop test-stable test-canary
docker rm test-stable test-canary

echo "Local test complete!"