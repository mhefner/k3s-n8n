# K3s n8n Deployment

A containerized n8n deployment optimized for Raspberry Pi hardware running on K3s Kubernetes, managed through ArgoCD for GitOps workflows.

## Overview

This project provides a production-ready deployment of n8n (workflow automation tool) designed specifically for ARM-based Raspberry Pi systems. The deployment leverages K3s for lightweight Kubernetes orchestration and ArgoCD for continuous deployment and configuration management.

## Prerequisites

### Hardware Requirements
- Raspberry Pi 4 (4GB RAM recommended)
- MicroSD card (32GB+ recommended)
- Stable internet connection

### Software Requirements
- K3s cluster running on Raspberry Pi OS
- ArgoCD installed and configured
- kubectl configured to access your cluster
- Docker Hub access (for pulling the ARM-optimized image)

## Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd k3s-n8n
```

### 2. Deploy via ArgoCD
```bash
# Apply the ArgoCD application manifest
kubectl apply -f argocd/application.yaml
```

### 3. Access n8n
Once deployed, n8n will be available at the configured ingress URL or through port-forwarding:
```bash
kubectl port-forward svc/n8n-service 5678:5678 -n n8n
```

Navigate to `http://localhost:5678` to access the n8n interface.

## Configuration

### Environment Variables
The deployment supports the following key environment variables:

- `N8N_BASIC_AUTH_ACTIVE`: Enable/disable basic authentication
- `N8N_BASIC_AUTH_USER`: Basic auth username
- `N8N_BASIC_AUTH_PASSWORD`: Basic auth password
- `DB_TYPE`: Database type (sqlite, postgres, mysql)
- `WEBHOOK_URL`: External webhook URL for n8n

### Persistent Storage
The deployment includes persistent volume claims for:
- n8n data directory (`/home/node/.n8n`)
- Database files (when using SQLite)

### Resource Limits
Optimized for Raspberry Pi hardware:
- CPU: 500m request, 1000m limit
- Memory: 512Mi request, 1Gi limit

## Docker Image

This deployment uses the custom ARM-optimized image:
```
mhefner1983/k3s-n8n:arm
```

The image is specifically built for ARM architecture and includes:
- n8n workflow automation platform
- ARM64 compatibility
- Optimized resource usage for Raspberry Pi

## Directory Structure

```
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   └── secrets.yaml
├── argocd/
│   └── application.yaml
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── README.md
```

## ArgoCD Management

### Application Configuration
The ArgoCD application is configured to:
- Monitor the Git repository for changes
- Automatically sync deployments
- Perform health checks
- Handle rollbacks when needed

### Sync Policy
```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
  syncOptions:
    - CreateNamespace=true
```

## Monitoring and Logging

### Health Checks
The deployment includes:
- Readiness probes on port 5678
- Liveness probes with appropriate timeouts
- Resource monitoring through K3s metrics

### Logging
Application logs are available through:
```bash
kubectl logs -f deployment/n8n-deployment -n n8n
```

## Networking

### Service Configuration
- Type: ClusterIP (default)
- Port: 5678
- Protocol: TCP

### Ingress (Optional)
Configure ingress for external access:
- Supports HTTPS termination
- Path-based routing
- Compatible with Traefik (K3s default)

## Security Considerations

### Authentication
- Enable basic authentication in production
- Use strong passwords
- Consider integrating with external auth providers

### Network Policies
Implement network policies to restrict traffic:
- Allow ingress on port 5678 only
- Restrict egress to necessary services
- Isolate n8n namespace

### Secrets Management
- Store sensitive data in Kubernetes secrets
- Use sealed-secrets or external secret management
- Rotate credentials regularly

## Backup and Recovery

### Data Backup
Regular backups of persistent volumes:
```bash
kubectl exec -n n8n deployment/n8n-deployment -- tar czf - /home/node/.n8n | kubectl exec -i backup-pod -- tar xzf -
```

### Database Backup (if using external DB)
Configure automated database backups based on your database type.

## Troubleshooting

### Common Issues

#### Pod Not Starting
```bash
kubectl describe pod -n n8n -l app=n8n
kubectl logs -n n8n -l app=n8n
```

#### Storage Issues
```bash
kubectl get pv,pvc -n n8n
kubectl describe pvc n8n-data -n n8n
```

#### ARM Compatibility
Ensure you're using the ARM-specific image:
- Image: `mhefner1983/k3s-n8n:arm`
- Platform: linux/arm64

### Performance Tuning for Raspberry Pi
- Adjust resource limits based on available RAM
- Enable swap if necessary
- Monitor CPU temperature and throttling
- Use fast MicroSD cards (Class 10 or better)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on Raspberry Pi hardware
5. Submit a pull request

## License

[License information]

## Support

For issues and questions:
- Check the troubleshooting section
- Review K3s and n8n documentation
- Open an issue in this repository

## Changelog

### v1.0.0
- Initial release
- ARM-optimized Docker image
- K3s deployment manifests
- ArgoCD integration
- Raspberry Pi optimization
