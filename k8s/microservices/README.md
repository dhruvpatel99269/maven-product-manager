# Microservices Kubernetes Deployment

This directory contains Kubernetes manifests for a complete microservices architecture with 4 core services plus an API Gateway.

## Architecture Overview

### Services
1. **Product Service** (Port 8081) - Manages product catalog
2. **User Service** (Port 8082) - Handles user management and authentication
3. **Order Service** (Port 8083) - Manages order processing
4. **Payment Service** (Port 8084) - Handles payment processing
5. **API Gateway** (Port 8080) - Routes requests to appropriate services

### Databases
- Each microservice has its own MongoDB instance
- Persistent storage using PVCs
- Separate databases for data isolation

### Infrastructure Components
- **ConfigMaps** - Application configuration
- **Secrets** - Sensitive data (passwords, API keys)
- **Services** - Internal communication
- **Ingress** - External access routing
- **HPA** - Auto-scaling based on CPU/memory
- **PVCs** - Persistent storage for databases

## Prerequisites

1. Kubernetes cluster (v1.19+)
2. kubectl configured to connect to your cluster
3. Ingress controller (nginx-ingress recommended)
4. Sufficient resources (at least 4 CPU cores and 8GB RAM)

## Quick Deployment

```bash
# Make the deployment script executable
chmod +x deploy.sh

# Run the deployment
./deploy.sh
```

## Manual Deployment

### 1. Create Namespace
```bash
kubectl apply -f namespace.yaml
```

### 2. Deploy Secrets
```bash
kubectl apply -f secrets.yaml
```

### 3. Deploy ConfigMaps
```bash
kubectl apply -f configmaps.yaml
```

### 4. Deploy Databases
```bash
kubectl apply -f databases.yaml
```

### 5. Deploy Microservices
```bash
kubectl apply -f product-service-deployment.yaml
kubectl apply -f user-service-deployment.yaml
kubectl apply -f order-service-deployment.yaml
kubectl apply -f payment-service-deployment.yaml
kubectl apply -f api-gateway-deployment.yaml
```

### 6. Deploy Additional Resources
```bash
kubectl apply -f hpa.yaml
kubectl apply -f ingress.yaml  # Optional
```

## Configuration

### Environment Variables
Each service is configured through ConfigMaps and Secrets:

**ConfigMaps contain:**
- Database connection strings
- Service URLs
- Application settings
- Management endpoints configuration

**Secrets contain:**
- Database credentials
- JWT secrets
- API keys (Stripe, PayPal)
- Other sensitive data

### Resource Limits
Each service has resource requests and limits:
- **Requests:** 250m CPU, 256Mi memory
- **Limits:** 500m CPU, 512Mi memory

### Health Checks
All services include:
- Liveness probes on `/actuator/health`
- Readiness probes on `/actuator/health/readiness`
- Initial delay: 60s (liveness), 30s (readiness)

## Scaling

### Horizontal Pod Autoscaler (HPA)
Each service has HPA configured:
- **Product Service:** 2-10 replicas
- **User Service:** 2-8 replicas
- **Order Service:** 2-8 replicas
- **Payment Service:** 2-8 replicas
- **API Gateway:** 2-5 replicas

### Manual Scaling
```bash
kubectl scale deployment product-service --replicas=5 -n microservices
```

## Monitoring

### Health Endpoints
- All services expose Spring Boot Actuator endpoints
- Health checks: `/actuator/health`
- Metrics: `/actuator/metrics`
- Info: `/actuator/info`

### Logs
```bash
# View logs for a specific service
kubectl logs -f deployment/product-service -n microservices

# View logs for all pods
kubectl logs -l app=product-service -n microservices
```

## Accessing Services

### LoadBalancer (API Gateway)
```bash
# Get the external IP
kubectl get service api-gateway -n microservices

# Access the API Gateway
curl http://<EXTERNAL-IP>:8080/api/products
```

### Port Forwarding
```bash
# Forward API Gateway port
kubectl port-forward service/api-gateway 8080:8080 -n microservices

# Access locally
curl http://localhost:8080/api/products
```

### Ingress
If using Ingress, add to `/etc/hosts`:
```
<INGRESS-IP> microservices.local
```

Then access:
- API Gateway: `http://microservices.local/`
- Product Service: `http://microservices.local/api/products`
- User Service: `http://microservices.local/api/users`
- Order Service: `http://microservices.local/api/orders`
- Payment Service: `http://microservices.local/api/payments`

## API Endpoints

### Product Service
- `GET /api/products` - List all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product

### User Service
- `POST /api/users/register` - Register new user
- `POST /api/users/login` - User login
- `GET /api/users/{id}` - Get user by ID
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user

### Order Service
- `GET /api/orders` - List orders
- `GET /api/orders/{id}` - Get order by ID
- `POST /api/orders` - Create new order
- `PUT /api/orders/{id}` - Update order status
- `DELETE /api/orders/{id}` - Cancel order

### Payment Service
- `POST /api/payments/process` - Process payment
- `GET /api/payments/{id}` - Get payment status
- `POST /api/payments/refund` - Process refund

## Troubleshooting

### Common Issues

1. **Pods not starting:**
   ```bash
   kubectl describe pod <pod-name> -n microservices
   kubectl logs <pod-name> -n microservices
   ```

2. **Database connection issues:**
   ```bash
   kubectl logs deployment/product-mongodb -n microservices
   ```

3. **Service discovery issues:**
   ```bash
   kubectl get endpoints -n microservices
   ```

4. **Resource constraints:**
   ```bash
   kubectl top pods -n microservices
   kubectl describe nodes
   ```

### Cleanup
```bash
# Delete entire microservices namespace
kubectl delete namespace microservices

# Or delete individual resources
kubectl delete -f .
```

## Security Considerations

1. **Secrets Management:** All sensitive data is stored in Kubernetes secrets
2. **Network Policies:** Consider implementing network policies for service isolation
3. **RBAC:** Implement proper RBAC for service accounts
4. **Image Security:** Use trusted base images and scan for vulnerabilities
5. **Encryption:** Enable encryption at rest for databases

## Development

### Building Docker Images
```bash
# Build images for each service
docker build -t product-service:latest ./docker/product-service/
docker build -t user-service:latest ./docker/user-service/
docker build -t order-service:latest ./docker/order-service/
docker build -t payment-service:latest ./docker/payment-service/
docker build -t api-gateway:latest ./docker/api-gateway/
```

### Local Development
Use port-forwarding to develop against the deployed services:
```bash
kubectl port-forward service/product-service 8081:8081 -n microservices
kubectl port-forward service/user-service 8082:8082 -n microservices
# ... etc
```

## Contributing

1. Make changes to the appropriate YAML files
2. Test deployments in a development environment
3. Update documentation as needed
4. Submit pull requests for review

## License

This project is licensed under the MIT License.
