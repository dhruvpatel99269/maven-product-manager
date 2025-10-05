# 🔍 How to Check Your Microservices Deployment

## 📊 **Current Status Summary**

### ✅ **What's Working (Infrastructure):**
- **Namespace:** `microservices` ✅ Active
- **ConfigMaps:** 5 config maps ✅ Created
- **Secrets:** 4 secrets ✅ Created  
- **Services:** 9 services ✅ Created
- **Databases:** 4 MongoDB instances ✅ Running (4/4 pods)
- **HPA:** 5 auto-scalers ✅ Configured
- **PVCs:** 4 persistent volumes ✅ Bound (5GB each)

### ⚠️ **What Needs Docker Images:**
- **Microservices:** 11/15 pods have `ImagePullBackOff` (need Docker images)

## 🚀 **Quick Commands to Check Everything**

### 1. **Check Overall Status**
```bash
kubectl get all -n microservices
```

### 2. **Check Pod Status**
```bash
kubectl get pods -n microservices
```

### 3. **Check Services**
```bash
kubectl get services -n microservices
```

### 4. **Check ConfigMaps and Secrets**
```bash
kubectl get configmaps -n microservices
kubectl get secrets -n microservices
```

### 5. **Check Persistent Volumes**
```bash
kubectl get pvc -n microservices
```

### 6. **Check Auto-scalers**
```bash
kubectl get hpa -n microservices
```

### 7. **Check Specific Issues**
```bash
kubectl describe pod <pod-name> -n microservices
```

## 🔧 **How to Fix the Image Pull Issues**

### **Option 1: Use Docker Compose (Recommended for Local Development)**
```bash
docker-compose up -d
```

### **Option 2: Build Individual Images**
```bash
# Build all microservice images
docker build -t product-service:latest ./docker/product-service/
docker build -t user-service:latest ./docker/user-service/
docker build -t order-service:latest ./docker/order-service/
docker build -t payment-service:latest ./docker/payment-service/
docker build -t api-gateway:latest ./docker/api-gateway/
```

### **Option 3: Use the PowerShell Checker**
```bash
powershell -ExecutionPolicy Bypass -File check-deployment.ps1
```

## 📈 **Real-time Monitoring Commands**

### **Watch Pod Status**
```bash
kubectl get pods -n microservices -w
```

### **View Logs**
```bash
kubectl logs -f deployment/product-service -n microservices
kubectl logs -f deployment/user-service -n microservices
kubectl logs -f deployment/order-service -n microservices
kubectl logs -f deployment/payment-service -n microservices
kubectl logs -f deployment/api-gateway -n microservices
```

### **Check Resource Usage**
```bash
kubectl top pods -n microservices
kubectl top nodes
```

## 🌐 **Access Your Services**

### **Port Forwarding (Access Locally)**
```bash
# API Gateway
kubectl port-forward service/api-gateway 8080:8080 -n microservices

# Individual Services
kubectl port-forward service/product-service 8081:8081 -n microservices
kubectl port-forward service/user-service 8082:8082 -n microservices
kubectl port-forward service/order-service 8083:8083 -n microservices
kubectl port-forward service/payment-service 8084:8084 -n microservices
```

### **Check Service Endpoints**
```bash
kubectl get endpoints -n microservices
```

## 🔍 **Troubleshooting Commands**

### **Check Events**
```bash
kubectl get events -n microservices --sort-by='.lastTimestamp'
```

### **Describe Resources**
```bash
kubectl describe deployment product-service -n microservices
kubectl describe service api-gateway -n microservices
```

### **Check Pod Logs for Errors**
```bash
kubectl logs <pod-name> -n microservices --previous
```

## 📊 **Expected Final Status**

Once Docker images are built, you should see:
- **Total Pods:** 15 (4 databases + 11 microservices)
- **Running Pods:** 15
- **Failed Pods:** 0
- **Pending Pods:** 0

## 🎯 **API Endpoints (After Images are Built)**

### **Product Service (Port 8081)**
- `GET /api/products` - List products
- `POST /api/products` - Create product
- `GET /api/products/{id}` - Get product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product

### **User Service (Port 8082)**
- `POST /api/users/register` - Register user
- `POST /api/users/login` - User login
- `GET /api/users/{id}` - Get user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user

### **Order Service (Port 8083)**
- `GET /api/orders` - List orders
- `POST /api/orders` - Create order
- `GET /api/orders/{id}` - Get order
- `PUT /api/orders/{id}` - Update order
- `DELETE /api/orders/{id}` - Cancel order

### **Payment Service (Port 8084)**
- `POST /api/payments/process` - Process payment
- `GET /api/payments/{id}` - Get payment status
- `POST /api/payments/refund` - Process refund

### **API Gateway (Port 8080)**
- Routes all requests to appropriate services

## 🧹 **Cleanup Commands**

### **Delete Everything**
```bash
kubectl delete namespace microservices
```

### **Delete Individual Resources**
```bash
kubectl delete -f k8s/microservices/all-in-one.yaml
```

## ✅ **Success Indicators**

Your deployment is successful when you see:
1. All 15 pods in "Running" status
2. All services have endpoints
3. API Gateway LoadBalancer has external IP
4. Health checks passing (`/actuator/health`)
5. No error events in the namespace

## 🆘 **Need Help?**

Run the PowerShell checker for detailed status:
```bash
powershell -ExecutionPolicy Bypass -File check-deployment.ps1
```

This will give you a comprehensive report of everything!

