# REMLA25 - Team 8 - Operation Repository

## Overview

This repository orchestrates the deployment of our Restaurant Sentiment Analysis system, combining the application frontend and machine learning backend into a production-ready solution using Docker Compose.


### Related Repositories

- [Model Training](https://github.com/remla25-team8/model-training)
- [Model Service](https://github.com/remla25-team8/model-service)
- [Library for Machine Learning (lib-ml)](https://github.com/remla25-team8/lib-ml)
- [Library for Versioning (lib-version)](https://github.com/remla25-team8/lib-version)
- [Application Frontend and Service (app)](https://github.com/remla25-team8/app)

## Getting Started

### Prerequisites

- Docker (minimum version: 24.0.0)
- Docker Compose (minimum version: 2.20.0)
- Vagrant (minimum version: 2.4.0)
- Ansible (minimum version: 8.0.0)
- SSH key pair (for accessing private repositories)

### SSH Key Setup

1. Generate an SSH key pair if you don't have one:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. Add your public key to the project:
   - Copy your public key (usually `~/.ssh/id_ed25519.pub`) to the `ansible/keys` directory
   - Rename it to `id_ed25519.pub` if it's not already named that
   - Ensure the key has the correct permissions:
     ```bash
     chmod 644 ansible/keys/id_ed25519.pub
     ```

3. Update the SSH key path in `ansible/group_vars/all/general.yaml`:
   ```yaml
   ssh_public_key_path: "{{ playbook_dir }}/keys/id_ed25519.pub"
   ```

4. Add your public key to your GitHub account:
   - Copy the contents of your public key (usually `~/.ssh/id_ed25519.pub`)
   - Go to GitHub → Settings → SSH and GPG keys → New SSH key
   - Paste your public key and save

Note: Never share or commit your private key. Keep it secure on your local machine only.

### Low Requirements Testing

For testing with minimal requirements, we provide a bash script that sets up a basic environment. This is useful for quick testing or when you don't want to use the full Vagrant/Ansible setup.

1. Make the script executable:
   ```bash
   chmod +x scripts/low_requirements_test.sh
   ```

2. Run the script:
   ```bash
   ./scripts/low_requirements_test.sh
   ```

The script will:
- Check for required dependencies
- Set up a minimal Docker environment
- Start the essential services
- Provide instructions for accessing the application

Note: This setup is for testing purposes only and doesn't include all features of the full deployment.

### Running the Application

1. Clone this repository to your local machine.
   ```bash
   git clone https://github.com/remla25-team8/operation.git
   cd operation
   ```

2. Start the Kubernetes environment
    ```bash
    vagrant up
    vagrant ssh ctrl
   ```

3. Inside the VM (ctrl), deploy the app:
    ```bash
      cd /vagrant/k8s

      # Create the required secret (required only the first time)
      kubectl create secret generic app-secrets \
      --from-literal=SMTP_PASSWORD=your-actual-password \
      --dry-run=client -o yaml > secret.yaml

      # Apply all Kubernetes manifests
      kubectl apply -f .

      # Install NGINX Ingress Controller
      kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml

      # Patch for Vagrant
      kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec":{"type":"NodePort"}}'

   ```

4. Check deployment status:
    ```bash
      kubectl get pods -n ingress-nginx  # Should show Running status   
   ```

5. Access the application:
    ```bash

      # Some options require access via your NodePort (3XXXX), command to find the NodePort: 
      kubectl get svc -n ingress-nginx

      # Option 1 (on browser), where 3XXXX (is the NodePort) 
      http://myapp.local:3XXXX/

      # Option 2: 

      # Port-Forward to a Pod 
      kubectl port-forward deployment/app-service 8080:8080     
      # Then access
      curl http://localhost:8080

      # Option 3:
      curl http://192.168.56.100:3XXXX  
   ```

6. Clean up:
    ```bash
      # Delete deployment
      kubectl delete -f .

      # Destroy Vagrant environment (from host)
      vagrant destroy -f   
   ```

## Code Structure

Key files and directories for understanding the deployment architecture:

| File/Directory | Purpose |
|---------------|---------|
| `docker-compose.yml` | Main orchestration file defining all services and their relationships |
| `.env` | Environment variables configuration (ports, versions, resource limits) |


## Assignment Progress Log

### Assignment A1

Significant progress has been made across various repositories:

- **Model-Training**: Created the ML training pipeline using Hugging Face model as model registry. Also created workflow for relase automation of both model to hugging face and docker image to ghcr when a version tag is created.
- **Model-Service**: Set up a Docker container to serve the ML model via a Flask API, ensuring the model can be queried independently. Workflow is used to automatically release an image in GHCR.
- **Lib-ML**: Contains the preprocessing logic, which is used both in model-training and model-service, released via PyPi for easy dependency management.
- **Lib-Version**: Developed a version-aware library that can be asked for the version of the library.
- **App**: A Dockerized web application built with JavaScript for the frontend and Flask for the backend.
- **Operation**: Established as the central repository for deployment and operation, including Docker Compose file for easy startup and README.md for detailed documentation.

### Assignment A2
You need to have ansible installed. 
All the steps up to and including step 22 are working. To test them out simply run:
```bash
vagrant up
```

After the inital setup is complete, you can finalize with the command:
```bash
ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization.yaml
```

When this playbook is complete it will give you the instructions for setting up the dashboard.


