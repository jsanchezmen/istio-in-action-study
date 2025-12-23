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
- `Makefile` - Automation for Docker, Kind cluster management

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

1. Start Docker: `make start-docker`
2. Create cluster: `make create-cluster`
3. Update dependencies: `helm dependency update istio-upstream/`
4. Install Istio: `helm install istio-test istio-upstream/ -n istio-system --create-namespace`
5. Verify: `kubectl get pods -n istio-system`
6. Clean up: `make delete-cluster`
- The commands for setting up the local cluster are in the file @Makefile
- The helm chart values for the istio/base chart are in the next link https://github.com/istio/istio/blob/master/manifests/charts/base/values.yaml
- The istio chart with all the dependencies is in the @istio-upstream/
- The default values for the istio/istiod chart are in the next link https://github.com/istio/istio/blob/master/manifests/charts/istio-control/istio-discovery/values.yaml
- The default values for the istio/gateway chart are in the next link https://github.com/istio/istio/blob/master/manifests/charts/gateway/values.yaml