#!/bin/bash

# Complete Microservices Deployment Checker
# This script provides comprehensive checking of the microservices deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

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

print_header "MICROSERVICES DEPLOYMENT CHECKER"

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

print_success "Connected to Kubernetes cluster"

# Check namespace
print_header "NAMESPACE STATUS"
if kubectl get namespace microservices &> /dev/null; then
    print_success "Namespace 'microservices' exists"
    kubectl get namespace microservices
else
    print_warning "Namespace 'microservices' does not exist"
fi

# Check all resources in microservices namespace
print_header "ALL RESOURCES IN MICROSERVICES NAMESPACE"
if kubectl get namespace microservices &> /dev/null; then
    kubectl get all -n microservices
else
    print_warning "Cannot check resources - namespace doesn't exist"
fi

# Check pods status
print_header "PODS STATUS"
if kubectl get namespace microservices &> /dev/null; then
    kubectl get pods -n microservices -o wide
    echo
    print_status "Pod Status Summary:"
    kubectl get pods -n microservices --no-headers | awk '{print $1 " - " $3}' | sort
else
    print_warning "Cannot check pods - namespace doesn't exist"
fi

# Check services
print_header "SERVICES STATUS"
if kubectl get namespace microservices &> /dev/null; then
    kubectl get services -n microservices
    echo
    print_status "Service Endpoints:"
    kubectl get endpoints -n microservices
else
    print_warning "Cannot check services - namespace doesn't exist"
fi

# Check configmaps
print_header "CONFIGMAPS STATUS"
if kubectl get namespace microservices &> /dev/null; then
    kubectl get configmaps -n microservices
    echo
    print_status "ConfigMap Details:"
    for cm in $(kubectl get configmaps -n microservices -o name --no-headers | grep -v kube-root-ca); do
        echo "--- $cm ---"
        kubectl describe $cm -n microservices | grep -A 10 "Data:"
        echo
    done
else
    print_warning "Cannot check configmaps - namespace doesn't exist"
fi

# Check secrets
print_header "SECRETS STATUS"
if kubectl get namespace microservices &> /dev/null; then
    kubectl get secrets -n microservices
    echo
    print_status "Secret Keys (without values):"
    for secret in $(kubectl get secrets -n microservices -o name --no-headers); do
        echo "--- $secret ---"
        kubectl describe $secret -n microservices | grep -A 10 "Data:"
        echo
    done
else
    print_warning "Cannot check secrets - namespace doesn't exist"
fi

# Check persistent volume claims
print_header "PERSISTENT VOLUME CLAIMS"
if kubectl get namespace microservices &> /dev/null; then
    kubectl get pvc -n microservices
    echo
    print_status "PVC Details:"
    kubectl describe pvc -n microservices
else
    print_warning "Cannot check PVCs - namespace doesn't exist"
fi

# Check horizontal pod autoscalers
print_header "HORIZONTAL POD AUTOSCALERS"
if kubectl get namespace microservices &> /dev/null; then
    kubectl get hpa -n microservices
    echo
    print_status "HPA Details:"
    kubectl describe hpa -n microservices
else
    print_warning "Cannot check HPAs - namespace doesn't exist"
fi

# Check deployments
print_header "DEPLOYMENTS STATUS"
if kubectl get namespace microservices &> /dev/null; then
    kubectl get deployments -n microservices
    echo
    print_status "Deployment Details:"
    kubectl describe deployments -n microservices
else
    print_warning "Cannot check deployments - namespace doesn't exist"
fi

# Check for image pull errors
print_header "IMAGE PULL ISSUES"
if kubectl get namespace microservices &> /dev/null; then
    print_status "Checking for image pull errors..."
    FAILED_PODS=$(kubectl get pods -n microservices --no-headers | grep -E "(ErrImagePull|ImagePullBackOff)" | wc -l)
    if [ "$FAILED_PODS" -gt 0 ]; then
        print_warning "Found $FAILED_PODS pods with image pull issues:"
        kubectl get pods -n microservices | grep -E "(ErrImagePull|ImagePullBackOff)"
        echo
        print_status "To fix image pull issues, you need to build Docker images:"
        echo "1. Build images: docker build -t product-service:latest ./docker/product-service/"
        echo "2. Build images: docker build -t user-service:latest ./docker/user-service/"
        echo "3. Build images: docker build -t order-service:latest ./docker/order-service/"
        echo "4. Build images: docker build -t payment-service:latest ./docker/payment-service/"
        echo "5. Build images: docker build -t api-gateway:latest ./docker/api-gateway/"
        echo "Or use: docker-compose up -d (for local development)"
    else
        print_success "No image pull issues found"
    fi
else
    print_warning "Cannot check image pull issues - namespace doesn't exist"
fi

# Check resource usage
print_header "RESOURCE USAGE"
if kubectl get namespace microservices &> /dev/null; then
    print_status "CPU and Memory usage:"
    if kubectl top pods -n microservices &> /dev/null; then
        kubectl top pods -n microservices
    else
        print_warning "Metrics server not available - cannot show resource usage"
    fi
    echo
    print_status "Node resource usage:"
    if kubectl top nodes &> /dev/null; then
        kubectl top nodes
    else
        print_warning "Metrics server not available - cannot show node usage"
    fi
else
    print_warning "Cannot check resource usage - namespace doesn't exist"
fi

# Check logs for any errors
print_header "RECENT LOGS CHECK"
if kubectl get namespace microservices &> /dev/null; then
    print_status "Checking recent logs for errors..."
    for pod in $(kubectl get pods -n microservices -o name --no-headers | head -5); do
        echo "--- Recent logs from $pod ---"
        kubectl logs $pod -n microservices --tail=5 2>/dev/null || echo "No logs available or pod not ready"
        echo
    done
else
    print_warning "Cannot check logs - namespace doesn't exist"
fi

# Summary
print_header "DEPLOYMENT SUMMARY"
if kubectl get namespace microservices &> /dev/null; then
    TOTAL_PODS=$(kubectl get pods -n microservices --no-headers | wc -l)
    RUNNING_PODS=$(kubectl get pods -n microservices --no-headers | grep "Running" | wc -l)
    FAILED_PODS=$(kubectl get pods -n microservices --no-headers | grep -E "(ErrImagePull|ImagePullBackOff|Error|CrashLoopBackOff)" | wc -l)
    PENDING_PODS=$(kubectl get pods -n microservices --no-headers | grep "Pending" | wc -l)
    
    echo "Total Pods: $TOTAL_PODS"
    echo "Running Pods: $RUNNING_PODS"
    echo "Failed Pods: $FAILED_PODS"
    echo "Pending Pods: $PENDING_PODS"
    echo
    
    if [ "$FAILED_PODS" -eq 0 ] && [ "$PENDING_PODS" -eq 0 ]; then
        print_success "🎉 All pods are running successfully!"
    elif [ "$FAILED_PODS" -gt 0 ]; then
        print_warning "⚠️  Some pods have issues (likely missing Docker images)"
        print_status "Run: docker-compose up -d (for local development)"
    else
        print_status "📋 Deployment in progress - some pods are still starting"
    fi
else
    print_warning "Namespace doesn't exist - run: kubectl apply -f k8s/microservices/all-in-one.yaml"
fi

print_header "USEFUL COMMANDS"
echo "View all resources:     kubectl get all -n microservices"
echo "View pod logs:          kubectl logs -f deployment/product-service -n microservices"
echo "Scale deployment:       kubectl scale deployment product-service --replicas=5 -n microservices"
echo "Port forward:           kubectl port-forward service/api-gateway 8080:8080 -n microservices"
echo "Delete deployment:      kubectl delete namespace microservices"
echo "Local development:      docker-compose up -d"
echo "Build images:           docker build -t product-service:latest ./docker/product-service/"

print_header "CHECK COMPLETED"

