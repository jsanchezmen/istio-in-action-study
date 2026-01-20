# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an Istio study/testing environment that uses Helm charts to deploy Istio to a local Kind (Kubernetes in Docker) cluster. The repository contains a Helm chart wrapper that depends on the official Istio base chart.

## Architecture

### Repository Structure

- `istio-upstream/` - Helm chart for deploying Istio components
  - `Chart.yaml` - Defines dependency on istio-base v1.28.0 from official Istio charts repository
  - `values.yaml` - Currently empty; can be used to override default Istio configurations
  - `templates/` - Currently empty; can add custom Kubernetes manifests
- `istio-in-action-ch2/` - Chapter 2: Basic Istio deployment and service mesh fundamentals
- `istio-in-action-ch4/` - Chapter 4: Traffic management with Gateway, VirtualService, TLS/mTLS
- `istio-in-action-ch5/` - Chapter 5: Advanced routing with headers, canary deployments, traffic shifting
- `istio-in-action-ch6/` - Chapter 6: Resilience patterns including circuit breakers, outlier detection, retries
- `Makefile` - Automation for Docker, Kind cluster management, and chapter deployments
- `scripts/` - Helper scripts for validation and setup
- `certs/` - TLS certificates for secure gateway configurations

### Helm Chart Architecture

The chart uses a dependency-based approach:
- Depends on `istio-base` v1.28.0 from `https://istio-release.storage.googleapis.com/charts`
- Istio base chart provides CRDs and foundational resources for Istio service mesh
- Custom configurations can be added via `values.yaml` or additional templates

## Development Commands

### Environment Setup

```bash
# Start Docker (macOS)
make start-docker

# Create Kind cluster for testing
make create-cluster

# Delete Kind cluster
make delete-cluster
```

### Helm Operations

```bash
# Update/download chart dependencies
helm dependency update istio-upstream/

# Install the chart
helm install istio-test istio-upstream/ -n istio-system --create-namespace

# Upgrade existing installation
helm upgrade istio-test istio-upstream/ -n istio-system

# Uninstall
helm uninstall istio-test -n istio-system

# Dry-run to see generated manifests
helm install istio-test istio-upstream/ --dry-run --debug

# Template rendering (no cluster needed)
helm template istio-test istio-upstream/
```

### Kubernetes Operations

```bash
# Set context to kind cluster
kubectl cluster-info --context kind-istio-testing

# Check Istio installation
kubectl get all -n istio-system

# View Istio CRDs
kubectl get crds | grep istio
```

## Required Tools

- Docker Desktop (for Kind)
- kind v0.30.0+
- kubectl v1.34+
- Helm v3.13+

## Working with Istio

When modifying Istio configurations:
1. Edit `istio-upstream/values.yaml` to override default Istio base chart values
2. Add custom Kubernetes resources in `istio-upstream/templates/` if needed
3. Use `helm dependency update` after modifying Chart.yaml dependencies
4. Test changes with `helm template` before applying to cluster
5. Deploy to Kind cluster with `helm upgrade` or `helm install`

## Typical Workflow

### Initial Setup
1. Start Docker: `make start-docker`
2. Create cluster: `make create-cluster`
3. Update dependencies: `helm dependency update istio-upstream/`
4. Install Istio: `helm install istio istio-upstream/ -n istio --create-namespace`
5. Verify: `kubectl get pods -n istio`

### Quick Start (Combined)
```bash
make up-istio-cluster  # Creates cluster and installs Istio
```

### Working with Chapter Examples

#### Chapter 2 - Basic Service Mesh
```bash
make install-app-ch2    # Install chapter 2 examples
make upgrade-app-ch2    # Upgrade after changes
make uninstall-app-ch2  # Clean up
```

#### Chapter 4 - Traffic Management & TLS
```bash
make template-app-ch4   # Preview manifests
make install-app-ch4    # Deploy traffic management examples
make upgrade-app-ch4    # Apply changes
make uninstall-app-ch4  # Clean up
```

Test endpoints:
```bash
# HTTP Gateway
curl http://127.0.0.1:30080/api/catalog -H "Host: webapp.istioinaction.io"

# HTTPS with simple TLS
curl -v https://webapp.istioinaction.io:30443/ \
  --resolve webapp.istioinaction.io:30443:127.0.0.1 \
  --cacert certs/ca-chain.cert.pem

# HTTPS with mTLS
curl -v https://webapp.istioinaction.io:30443/api/catalog \
  --resolve webapp.istioinaction.io:30443:127.0.0.1 \
  --cacert certs/ca-chain.cert.pem \
  --cert certs/client-cert.cert.pem \
  --key certs/client-key.key.pem
```

#### Chapter 5 - Advanced Routing
```bash
make template-app-ch5   # Preview manifests
make install-app-ch5    # Deploy advanced routing
make validate-namespace-ch5  # Validate namespace exists
make upgrade-app-ch5    # Apply changes
make uninstall-app-ch5  # Clean up
```

Test endpoints:
```bash
# Standard request
curl http://localhost:30080/items -H "Host: catalog.istioinaction.io"

# Request with custom header for canary routing
curl http://localhost:30080/items \
  -H "Host: catalog.istioinaction.io" \
  -H "x-istio-cohort: internal"

# Load test
for i in {1..100}; do
  curl -s http://localhost:30080/items -H "Host: catalog.istioinaction.io"
done
```

#### Chapter 6 - Resilience Patterns
```bash
make template-app-ch6   # Preview manifests
make install-app-ch6    # Deploy resilience patterns (validates namespace first)
make validate-namespace-ch6  # Validate namespace exists
make upgrade-app-ch6    # Apply changes (validates namespace first)
make uninstall-app-ch6  # Clean up
```

Features:
- Circuit breakers
- Outlier detection with 5s ejection time
- Connection pool management
- Periodic failure injection (500 errors)

Test endpoints:
```bash
# Simple request
curl http://localhost:30080 -H "Host: simple-web.istioinaction.io"

# Load test to trigger circuit breaker
for i in {1..100}; do
  time curl -s -H "Host: simple-web.istioinaction.io" \
    http://localhost:30080 | jq .code
  printf "\n"
done

# Fortio load test - single connection
fortio load -H "Host: simple-web.istioinaction.io" \
  -quiet -jitter -t 30s -c 1 -qps 1 http://localhost:30080/

# Fortio load test - multiple connections to trigger resilience
fortio load -H "Host: simple-web.istioinaction.io" \
  -allow-initial-errors -quiet -jitter -t 30s -c 10 -qps 20 \
  http://localhost:30080/
```

### Cleanup
```bash
make delete-cluster  # Delete entire Kind cluster
```

## Important Notes

- Gateway NodePorts are fixed for easy access:
  - HTTP: 30080 → http://localhost:30080
  - HTTPS: 30443 → https://localhost:30443
- When ingress-gateway needs to read certificates from secrets, restart the deployment
- Chapter 6 includes automatic namespace validation before install/upgrade
- The validation script is located at `scripts/validate-namespace.sh`

## Reference Links

- Makefile commands: `Makefile`
- Istio base chart values: https://github.com/istio/istio/blob/master/manifests/charts/base/values.yaml
- Istio chart with dependencies: `istio-upstream/`
- Istiod chart values: https://github.com/istio/istio/blob/master/manifests/charts/istio-control/istio-discovery/values.yaml
- Gateway chart values: https://github.com/istio/istio/blob/master/manifests/charts/gateway/values.yaml
- Book source code: https://github.com/istioinaction/book-source-code/tree/master