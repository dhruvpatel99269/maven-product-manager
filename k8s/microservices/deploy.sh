#!/bin/bash

# Microservices Deployment Script
# This script deploys a complete microservices architecture with 4 services

set -e

echo "🚀 Starting Microservices Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if kubectl can connect to cluster
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster"
    exit 1
fi

print_status "Connected to Kubernetes cluster"

# Create namespace
print_status "Creating namespace..."
kubectl apply -f namespace.yaml
print_success "Namespace created"

# Create secrets
print_status "Creating secrets..."
kubectl apply -f secrets.yaml
print_success "Secrets created"

# Create configmaps
print_status "Creating configmaps..."
kubectl apply -f configmaps.yaml
print_success "ConfigMaps created"

# Deploy databases
print_status "Deploying databases..."
kubectl apply -f databases.yaml
print_success "Databases deployed"

# Wait for databases to be ready
print_status "Waiting for databases to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/product-mongodb -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/user-mongodb -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/order-mongodb -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/payment-mongodb -n microservices
print_success "All databases are ready"

# Deploy microservices
print_status "Deploying microservices..."
kubectl apply -f product-service-deployment.yaml
kubectl apply -f user-service-deployment.yaml
kubectl apply -f order-service-deployment.yaml
kubectl apply -f payment-service-deployment.yaml
kubectl apply -f api-gateway-deployment.yaml
print_success "Microservices deployed"

# Wait for services to be ready
print_status "Waiting for services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/product-service -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/user-service -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/order-service -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/payment-service -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/api-gateway -n microservices
print_success "All services are ready"

# Deploy HPA
print_status "Deploying Horizontal Pod Autoscalers..."
kubectl apply -f hpa.yaml
print_success "HPAs deployed"

# Deploy Ingress (optional - requires ingress controller)
print_warning "Ingress deployment requires an ingress controller (like nginx-ingress)"
read -p "Do you want to deploy Ingress? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deploying Ingress..."
    kubectl apply -f ingress.yaml
    print_success "Ingress deployed"
    print_warning "Make sure to add 'microservices.local' to your /etc/hosts file pointing to your ingress controller IP"
fi

# Display deployment status
print_status "Deployment completed! Here's the status:"
echo
kubectl get pods -n microservices
echo
kubectl get services -n microservices
echo
kubectl get ingress -n microservices

print_success "🎉 Microservices deployment completed successfully!"
print_status "You can access the services through the API Gateway at the LoadBalancer IP or through Ingress"

# Display useful commands
echo
print_status "Useful commands:"
echo "  View logs: kubectl logs -f deployment/product-service -n microservices"
echo "  Scale service: kubectl scale deployment product-service --replicas=5 -n microservices"
echo "  Port forward: kubectl port-forward service/api-gateway 8080:8080 -n microservices"
echo "  Delete deployment: kubectl delete namespace microservices"
