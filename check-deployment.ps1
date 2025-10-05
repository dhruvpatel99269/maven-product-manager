# Complete Microservices Deployment Checker - PowerShell Version
# This script provides comprehensive checking of the microservices deployment

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "MICROSERVICES DEPLOYMENT CHECKER" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

# Check if kubectl is available
try {
    kubectl version --client | Out-Null
    Write-Host "[SUCCESS] kubectl is available" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] kubectl is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if kubectl can connect to cluster
try {
    kubectl cluster-info | Out-Null
    Write-Host "[SUCCESS] Connected to Kubernetes cluster" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Cannot connect to Kubernetes cluster" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "NAMESPACE STATUS" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

try {
    $namespace = kubectl get namespace microservices
    if ($namespace) {
        Write-Host "[SUCCESS] Namespace 'microservices' exists" -ForegroundColor Green
        kubectl get namespace microservices
    }
} catch {
    Write-Host "[WARNING] Namespace 'microservices' does not exist" -ForegroundColor Yellow
    Write-Host "Run: kubectl apply -f k8s/microservices/all-in-one.yaml" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "ALL RESOURCES IN MICROSERVICES NAMESPACE" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

try {
    kubectl get all -n microservices
} catch {
    Write-Host "[WARNING] Cannot check resources - namespace doesn't exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "PODS STATUS" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

try {
    kubectl get pods -n microservices -o wide
    Write-Host ""
    Write-Host "[INFO] Pod Status Summary:" -ForegroundColor Blue
    $pods = kubectl get pods -n microservices --no-headers
    $running = ($pods | Select-String "Running").Count
    $failed = ($pods | Select-String "ErrImagePull|ImagePullBackOff|Error|CrashLoopBackOff").Count
    $pending = ($pods | Select-String "Pending|ContainerCreating").Count
    
    Write-Host "Running Pods: $running" -ForegroundColor Green
    Write-Host "Failed Pods: $failed" -ForegroundColor Red
    Write-Host "Pending Pods: $pending" -ForegroundColor Yellow
} catch {
    Write-Host "[WARNING] Cannot check pods - namespace doesn't exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "SERVICES STATUS" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

try {
    kubectl get services -n microservices
    Write-Host ""
    Write-Host "[INFO] Service Endpoints:" -ForegroundColor Blue
    kubectl get endpoints -n microservices
} catch {
    Write-Host "[WARNING] Cannot check services - namespace doesn't exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "CONFIGMAPS STATUS" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

try {
    kubectl get configmaps -n microservices
} catch {
    Write-Host "[WARNING] Cannot check configmaps - namespace doesn't exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "SECRETS STATUS" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

try {
    kubectl get secrets -n microservices
} catch {
    Write-Host "[WARNING] Cannot check secrets - namespace doesn't exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "PERSISTENT VOLUME CLAIMS" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

try {
    kubectl get pvc -n microservices
} catch {
    Write-Host "[WARNING] Cannot check PVCs - namespace doesn't exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "HORIZONTAL POD AUTOSCALERS" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

try {
    kubectl get hpa -n microservices
} catch {
    Write-Host "[WARNING] Cannot check HPAs - namespace doesn't exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "IMAGE PULL ISSUES" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

try {
    $failedPods = kubectl get pods -n microservices --no-headers | Select-String "ErrImagePull|ImagePullBackOff"
    if ($failedPods) {
        Write-Host "[WARNING] Found pods with image pull issues:" -ForegroundColor Yellow
        kubectl get pods -n microservices | Select-String "ErrImagePull|ImagePullBackOff"
        Write-Host ""
        Write-Host "[INFO] To fix image pull issues:" -ForegroundColor Blue
        Write-Host "1. Build images: docker build -t product-service:latest ./docker/product-service/" -ForegroundColor Cyan
        Write-Host "2. Or use: docker-compose up -d (for local development)" -ForegroundColor Cyan
    } else {
        Write-Host "[SUCCESS] No image pull issues found" -ForegroundColor Green
    }
} catch {
    Write-Host "[WARNING] Cannot check image pull issues - namespace doesn't exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "USEFUL COMMANDS" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "View all resources:     kubectl get all -n microservices" -ForegroundColor Cyan
Write-Host "View pod logs:          kubectl logs -f deployment/product-service -n microservices" -ForegroundColor Cyan
Write-Host "Scale deployment:       kubectl scale deployment product-service --replicas=5 -n microservices" -ForegroundColor Cyan
Write-Host "Port forward:           kubectl port-forward service/api-gateway 8080:8080 -n microservices" -ForegroundColor Cyan
Write-Host "Delete deployment:      kubectl delete namespace microservices" -ForegroundColor Cyan
Write-Host "Local development:      docker-compose up -d" -ForegroundColor Cyan

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "CHECK COMPLETED" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

