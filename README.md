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

- Docker
- Docker compose

### Running the Application

1. Clone this repository to your local machine.
   ```bash
   git clone https://github.com/remla25-team8/operation.git
   cd operation
   ```

2. Start all services
    ```bash
    docker compose up -d
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
All the steps up to and including step 22 are working. To test them out simply run:
```bash
vagrant up
```

After the inital setup is complete, you can finalize with the command:
```bash
ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization.yaml
```

When this playbook is complete it will give you the instructions for setting up the dashboard.


