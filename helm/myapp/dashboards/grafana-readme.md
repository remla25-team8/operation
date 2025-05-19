# Grafana Dashboard for Restaurant Sentiment Analysis

This directory contains a Grafana dashboard for the Restaurant Sentiment Analysis application, allowing you to monitor the application's metrics in real-time.

## Dashboard Features

- **Overview Section**:
  - Sentiment Analysis Rate: Shows the rate of positive vs negative sentiment analyses over time
  - Active Users by Page: Displays current user activity across different application pages

- **Performance Section**:
  - Model Response Time: Shows the distribution of model service response times (P50, P90, P99)
  - Average Response Time: Gauge showing the current average response time
  - Request Rate: Current rate of sentiment analysis requests

- **Feedback Section**:
  - Feedback by Sentiment and Correctness: Bar chart showing user feedback on model predictions
  - Model Accuracy: Gauge showing the percentage of predictions users marked as correct

- **Application Health Section**:
  - HTTP Request Rate by Status: Shows request rates categorized by HTTP status code
  - HTTP Request Rate by Endpoint: Shows request rates for different API endpoints

- **Time Range Selector**: Easily change the time range for all visualizations

## Installation Methods

### Method 1: Automatic Installation via Helm (Recommended)

The dashboard is automatically installed when you deploy the application using Helm with Grafana dashboard support enabled:


### Method 1: Manual Import

If you prefer to manually import the dashboard:

1. Access your Grafana UI (configure `/etc/hosts` first):
   ```bash
   # Add to your /etc/hosts file
   # 192.168.56.90 grafana.local
   ```

2. Open a browser and navigate to `http://grafana.local`

3. Log in to Grafana (default credentials for kube-prometheus-stack are admin/prom-operator)

4. Navigate to Dashboards → Import

5. Copy and paste the JSON content from `dashboards/restaurant-sentiment-dashboard.json` or upload the file

6. Click "Import" to finalize

## Generating Test Data

To generate test data and populate the dashboard, you can use the provided test script:

### Using the Bash Script (Linux/macOS)

```bash
# Run the script with default settings (30 requests to dev.myapp.local)
./scripts/test-grafana.sh

# Or specify the number of requests and host
./scripts/test-grafana.sh 50 dev.myapp.local
```

## Troubleshooting

### Dashboard Not Showing in Grafana

1. Verify that the ConfigMap was created:
   ```bash
   kubectl get configmap -n monitoring | grep dashboard
   ```

2. Ensure Grafana has the correct permissions to read ConfigMaps:
   ```bash
   kubectl get clusterrole -n monitoring | grep grafana
   ```

3. Restart the Grafana pod to force it to reload ConfigMaps:
   ```bash
   kubectl delete pod -l app.kubernetes.io/name=grafana -n monitoring
   ```

### Cannot Access Grafana via Ingress

1. Verify the Ingress is correctly configured:
   ```bash
   kubectl get ingress -n monitoring
   kubectl describe ingress grafana-ingress -n monitoring
   ```

2. Check if the Ingress controller is running:
   ```bash
   kubectl get pods -n ingress-nginx
   ```

3. Try accessing Grafana via NodePort:
   ```bash
   # Get the NodePort
   kubectl get svc -n monitoring | grep grafana
   
   # Access via NodePort
   # http://192.168.56.90:XXXXX
   ```
