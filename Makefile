verify-docker:
	@echo "Checking if Docker is running..."
	@if ! docker system info > /dev/null 2>&1; then \
		echo "Docker is not running. Starting Docker..."; \
		$(MAKE) start-docker; \
	else \
		echo "Docker is already running."; \
	fi

start-docker:
	open --background -a Docker
	@echo "Waiting for Docker to launch..."
	until docker system info > /dev/null 2>&1; do \
		sleep 1; \
	done
	@echo "Docker is running."

create-cluster:
	kind create cluster --name istio-testing --config kind/kind-config.yaml

delete-cluster:
	kind delete cluster --name istio-testing

update-istio-chart-deps:
	helm dependency update istio-upstream

add-istio-repo:
	helm repo add istio https://istio-release.storage.googleapis.com/charts
	helm repo update

install-istio:
	helm install istio istio-upstream -n istio --create-namespace

uninstall-istio:
	helm uninstall istio -n istio

template-istio:
	helm template istio istio-upstream -n istio

up-istio-cluster: create-cluster install-istio

install-app-ch2:
	helm install istio-in-action-ch2 istio-in-action-ch2

uninstall-app-ch2:
	helm uninstall istio-in-action-ch2

upgrade-app-ch2:
	helm upgrade istio-in-action-ch2 istio-in-action-ch2

install-app-ch4:
	helm install istio-in-action-ch4 istio-in-action-ch4

uninstall-app-ch4:
	helm uninstall istio-in-action-ch4

upgrade-app-ch4:
	helm upgrade istio-in-action-ch4 istio-in-action-ch4

template-app-ch4:
	helm template istio-in-action-ch4 istio-in-action-ch4

template-app-ch5:
	helm template istio-in-action-ch5 istio-in-action-ch5

install-app-ch5:
	helm install istio-in-action-ch5 istio-in-action-ch5

uninstall-app-ch5:
	helm uninstall istio-in-action-ch5

upgrade-app-ch5:
	helm upgrade istio-in-action-ch5 istio-in-action-ch5
	