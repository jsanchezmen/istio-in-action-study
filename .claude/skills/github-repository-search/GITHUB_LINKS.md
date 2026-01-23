# Github Repository Links

This document stores frequently used GitHub repository links for quick access by the github-repository-search skill.

## Format

Each entry follows the pattern:
```
repository-key: github-url
```

Keys should be descriptive and match common ways users might refer to the repository.

---

## Repositories

### Kubernetes & Helm Charts

#### Prometheus Stack
kube-prometheus-stack: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
kube-prometheus-stack values.yaml: https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml
kube-prometheus-stack chart: https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/Chart.yaml
prometheus-community charts: https://github.com/prometheus-community/helm-charts

#### Istio
istio-charts: https://github.com/istio/istio/tree/master/manifests/charts
istio-base: https://github.com/istio/istio/tree/master/manifests/charts/base
istio-base values.yaml: https://github.com/istio/istio/blob/master/manifests/charts/base/values.yaml
istiod: https://github.com/istio/istio/tree/master/manifests/charts/istio-control/istio-discovery
istiod values.yaml: https://github.com/istio/istio/blob/master/manifests/charts/istio-control/istio-discovery/values.yaml
istio-gateway: https://github.com/istio/istio/tree/master/manifests/charts/gateway
istio-gateway values.yaml: https://github.com/istio/istio/blob/master/manifests/charts/gateway/values.yaml
istio: https://github.com/istio/istio

---

## Adding New Repositories

To add a new repository to this registry:

1. Identify the repository name/key (use common terminology)
2. Get the full GitHub URL
3. Add it under the appropriate category
4. If creating a new category, add a `###` heading

Example:
```
my-chart: https://github.com/organization/repo/tree/main/charts/my-chart
my-chart values.yaml: https://github.com/organization/repo/blob/main/charts/my-chart/values.yaml
```