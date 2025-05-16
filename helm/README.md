# MyApp Helm Chart

This Helm chart is used to deploy the application stack to a Kubernetes cluster.

## Prerequisites

- Helm 3.x installed
- A running Kubernetes cluster (e.g., Minikube or a self-hosted cluster)
- An Ingress controller installed in the cluster (e.g., NGINX)
- A pre-created Secret named `<namePrefix>-myapp-secret` containing the key `smtpPassword`

## Installation Steps

1. **Clone the operations repository:**
   ```sh
   git clone <repository-URL>
   cd operations/helm/myapp
   ```

2. **Create the Secret for sensitive data:**
   ```sh
   kubectl create secret generic <namePrefix>-myapp-secret --from-literal=smtpPassword=<your-SMTP-password>
   ```

3. **Install the chart:**
   ```sh
   helm install <release-name> . --set namePrefix=<prefix> --set ingress.host=<your-hostname>
   ```
   **Example:**
   ```sh
   helm install dev-myapp . --set namePrefix=dev --set ingress.host=dev.myapp.local
   ```

4. **Access the application via the Ingress host** (e.g., http://dev.myapp.local).

## Customization

Edit `values.yaml` or use `--set` to customize:

- `namePrefix`: Prefix for resource names (e.g., dev, prod)
- `service.port`: Model service port
- `ingress.host`: DNS hostname for the application
- `configMap.modelServiceUrl`: Model service URL

## Multiple Installations

To install multiple instances:
```sh
helm install prod-myapp . --set namePrefix=prod --set ingress.host=prod.myapp.local --set service.port=8081
```

## Uninstallation

To uninstall a release:
```sh
helm uninstall <release-name>
``` 