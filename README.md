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

### Running with Docker

One way to run the application is using Docker Compose.

#### Quick Start with Docker Compose

1. **Clone the repository:**
   ```bash
   git clone https://github.com/remla25-team8/operation.git
   cd operation
   ```

2. **Set up environment (if needed):**
   ```bash
   # Create .env file from template if it doesn't exist
   cp .env.template .env
   # Edit .env file with your configuration
   ```

3. **Create secrets directory:**
   ```bash
   mkdir -p secrets
   # Create a dummy model config (or use your actual config)
   echo '{"model": "dummy"}' > secrets/model_config.json
   ```
4. **Login to GHCR:**
echo <YOUR_GH_TOKEN> | docker login ghcr.io -u <YOUR_GITHUB_USERNAME> --password-stdin

5. **Start the services:**
   ```bash
   docker-compose up -d
   ```

6. **Check service status (optional):**
   ```bash
   docker-compose ps
   ```

7. **Access the application:**
   - **Frontend:** http://localhost:8080
   - **Information about app and model service:** http://localhost:8080/info
   - **API Documentation:** http://localhost:8080/api/docs

#### Docker Compose Commands

```bash
# If any command gives a permission denied error, using sudo before the commands will work.

# Start services
docker-compose up

# Stop services
docker-compose down

# Restart services
docker-compose restart

# Stop all running containers (forcefully if needed)
docker-compose down --volumes --remove-orphans

# Prune unused networks (optional, but can help)
docker network prune -f

# Rebuild and start services
docker-compose up --build -d
```

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

### Configuring Host Access

Add the following entries to your local machine's `/etc/hosts` file:

```bash
192.168.56.90 myapp.local dashboard.local grafana.local prometheus.local
```

This will allow you to access the various web interfaces by hostname.

### Running the Application

1. Clone this repository to your local machine.
   ```bash
   git clone https://github.com/remla25-team8/operation.git
   cd operation
   ```

2. Start the Kubernetes environment
    ```bash
      # On host machine:
      vagrant up
      ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization.yaml
      vagrant ssh ctrl
   ```

3. Inside the VM (ctrl), deploy the app:
    ```bash
      cd /vagrant/helm/myapp
   ```
      Create the required secret (required only the first time):
      ```sh
      kubectl create secret generic dev-myapp-secret --from-literal=smtpPassword=<your-SMTP-password>
      ```

      Install the chart:
      ```sh
      helm install dev-myapp . --set namePrefix=dev 
      ```
      Test Istio:
      ```bash
         bash tests/sticky-session-test.sh
      ```
      

5. Outside the VMs, on your host machine:

      Add to `/etc/hosts` file the following:

         - 192.168.56.90 grafana.myapp.local
         - 192.168.56.91 app.local
         - 192.168.56.90 prometheus.local

### Accessing the Application

After deployment, you can access the following services:

* Web Application: http://app.local
* Kubernetes Dashboard: https://dashboard.local (setup instructions during provisioning also requires adding to hosts file)
* Grafana: http://grafana.myapp.local (credentials: admin/prom-operator)
* Prometheus: http://prometheus.local

#### Monitoring with Grafana
Accessing Grafana Dashboard

1. Make sure you've added grafana.local to your hosts file as described above
2. Navigate to http://grafana.myapp.local in your browser
3. Log in with default credentials: Username: admin Password: prom-operator
4. Go to Dashboards → Browse to find the "Restaurant Sentiment Analysis Dashboard"

#### Generating Test Data

We provide scripts to generate test data for the dashboard:

##### Using Bash (Linux/macOS)
```bash
./scripts/test-grafana-bash.sh 50 myapp.local
```

##### Using PowerShell (Windows)
*coming soon*

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


### Assignment A3
During this phase, following tasks were implemented:
- Kubernetes migration with Helm chart.
- Monitoring Stack including Metrics, Alerting, Prometheus and Grafana.
- Documentation for each of the above.

### Assignment A4
During this phase, we implemented comprehensive ML Testing and Configuration Management following the ML Test Score methodology.
- Automated Tests
- Continuous Training Pipeline
- Project Organization
- Pipeline Management with DVC
- Code Quality

### Assignment A5
During this phase, we implemented advanced Traffic Management, Continuous Experimentation, and comprehensive Documentation.

#### Traffic Management
- **Gateway and VirtualService Implementation**: Complete Istio Gateway and VirtualService configuration
- **Application Accessibility**: Application accessible through IngressGateway with proper host routing
- **DestinationRules and Weighted Routing**: Implemented 90/10 traffic distribution between app versions
- **Version Consistency**: Model-service and app versions properly synchronized across deployments
- **Sticky Sessions**: Full implementation of sticky sessions using x-user-id headers and version cookies
  - Requests from same origin maintain stable routing
  - Cookie-based session persistence for consistent user experience
  - Header-based routing for specific test users

#### Additional Use Case - Shadow Launch
- **Traffic Mirroring**: Implemented shadow launch capability for safe production testing
- **Mirror Configuration**: 100% traffic mirroring to shadow model service
- **Non-intrusive Testing**: Production traffic mirrored without affecting user experience
- **Metrics Collection**: Comprehensive metrics collection from both production and shadow services
- **A/B Testing Support**: Foundation for advanced A/B testing scenarios

#### Continuous Experimentation
- **Experiment Documentation**: Comprehensive documentation in `docs/continuous-experimentation.md`
- **Two-Version Deployment**: Both v1 and v2 versions deployed and accessible
- **Hypothesis-Driven Testing**: Clear experiment design with measurable hypotheses
- **Metrics Implementation**: Custom metrics for experiment evaluation
- **Prometheus Integration**: Metrics automatically collected by Prometheus
- **Grafana Dashboard**: Importable dashboard (`restaurant-sentiment-dashboard.json`) for experiment visualization
- **Decision Process**: Detailed criteria for experiment acceptance/rejection
- **Visual Documentation**: Screenshots and diagrams supporting decision-making process

#### Documentation
- **Deployment Documentation**: Comprehensive `docs/deployment.md` with:
  - Complete deployment structure and entity relationships
  - Detailed data flow diagrams with dynamic routing points
  - Visual Mermaid diagrams for component interactions
  - 90/10 split and sticky session routing explanations
  - Resource type coverage with clear relations
- **Extension Proposal**: Release engineering extension in `docs/extension.md`:
  - Identified critical shortcoming: lack of automated release validation
  - Proposed Release Validation Pipeline addressing the gap
  - External source citations (Dynatrace blog)
  - Objective measurement criteria for improvement validation
  - General applicability beyond the current project scope
- **Visual Appeal**: Professional documentation with clear diagrams and structured content
- **Team Onboarding**: Documentation enables new team members to contribute effectively