# Operation Repository README

## Assignment 5: Istio Service Mesh (Member 1 Contributions)

This repository contains the Kubernetes and Helm configurations for the *Restaurant Sentiment Analysis* project. For Assignment 5, Member 1 implemented the **Traffic Management** requirements at the **Excellent** level, including Istio Gateway, Virtual Services, and Sticky Sessions, ensuring compatibility with existing Kubernetes and monitoring setups.

### Changes Made

1. **Istio Installation**:
   - Added tasks to `ansible/ctrl.yaml` to install Istio 1.25.2, including downloading the binary, adding `istioctl` to PATH, and installing the `demo` profile.
   - Extends A2 Step 23 to enable Istio support in the Kubernetes cluster.

2. **Istio Gateway**:
   - Created `helm/myapp/templates/gateway.yaml` to configure an Istio Gateway, allowing access to the `app` service via `app.local` through the Istio IngressGateway.
   - Disabled Nginx Ingress in `helm/myapp/values.yaml` (`ingress.enabled: false`) to prevent conflicts.

3. **Virtual Services and Sticky Sessions**:
   - Added `helm/myapp/templates/virtualservice.yaml` to configure Virtual Services for the `app` service, implementing a 90/10 canary release (90% to v1: `ghcr.io/remla25-team8/app:1.1.4`, 10% to v2: `ghcr.io/remla25-team8/app:2.0.0`).
   - Implemented Sticky Sessions using the `x-user-id` header, routing requests with `x-user-id: test-user` to v2.
   - Updated `helm/myapp/values.yaml` with `istio` settings (`enabled`, `host: app.local`, `sticky.userId: test-user`).

4. **Canary Deployment**:
   - Modified `helm/myapp/templates/deployment.yaml` to deploy both v1 and v2 of the `app` service.
   - Updated `helm/myapp/templates/service.yaml` to match both versions.

5. **Testing Script**:
   - Added `helm/myapp/tests/sticky-session-test.sh` to verify 90/10 routing and Sticky Sessions.
   - Updated `helm/myapp/README.md` with testing instructions.

### Testing Instructions

1. **Prerequisites**:
   - Go through steps in main README up to but not including helm install
   <!-- - Verify Istio installation: `kubectl get pods -n istio-system` (expect `istio-ingressgateway` running).
   - Add `192.168.56.90 app.local` to `/etc/hosts` (local or Vagrant host, assuming MetalLB IP from A2).
   - Ensure `app` v2 image (`ghcr.io/remla25-team8/app:2.0.0`) is available. -->

2. **Deploy Helm Chart**:
   ```bash
   helm install my-app ./helm/myapp -n default
   ```

3. **Automated Testing: These don't work yet since they rely on model-service which isn't working via helm install yet**:
   ```bash
   bash helm/myapp/tests/sticky-session-test.sh
   ```
   - **Expected Output**:
     - First loop (10 requests): ~90% route to v1 (`1.1.4`), ~10% to v2 (`2.0.0`). Check response differences (e.g., version-specific headers, if implemented).
     - Second loop (5 requests): All requests with `x-user-id: test-user` route to v2.

4. **Manual Testing:**:
   ```bash
   # Test default routing
   curl -H "Host: app.local" http://192.168.56.91/analyze -d '{"review": "Great food!"}' -H "Content-Type: application/json"
   
   # Test Sticky Sessions
   curl -H "Host: app.local" -H "x-user-id: test-user" http://192.168.56.91/analyze -d '{"review": "Great food!"}' -H "Content-Type: application/json"
   ```

   You should get a 500 error from frontend failing to communicate with backend since it's not up yet.

### Verification Methods

1. **Istio Gateway**:
   - Confirm resource: `kubectl get gateway -n default` (should list `myapp-gateway`).
   - Access `http://app.local/analyze` via curl or browser (expect a valid response).

2. **Virtual Services and 90/10 Routing**:
   - Confirm resource: `kubectl get virtualservice -n default` (should list `myapp-vs`).
   - Run `sticky-session-test.sh` multiple times; verify ~90% v1 and ~10% v2 responses.
   - Use Kiali: `kubectl port-forward svc/kiali -n istio-system 20001:20001`, open `http://localhost:20001` to visualize traffic.

3. **Sticky Sessions**:
   - Check `app` v2 logs: `kubectl logs -l app.kubernetes.io/name=myapp,version=1 -n default`.
   - Confirm `x-user-id: test-user` requests consistently route to v2 in the test script’s second loop.

4. **Deployment**:
   - Verify deployments: `kubectl get deployments -n default` (expect `myapp-v1` and `myapp-v2`).
   - Check service: `kubectl get svc -n default` (expect `myapp-service`).

5. **Helm Integrity**:
   - Run `helm lint ./helm/myapp` for syntax errors.
   - Perform dry run: `helm install --dry-run my-app ./helm/myapp -n default`.

If issues occur, check Istio logs (`kubectl logs -n istio-system -l istio=ingressgateway`) or coordinate with team members for v2 image details.