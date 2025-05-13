#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting low-requirements test setup...${NC}\n"

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed${NC}"
        echo "Please install $1 before continuing"
        exit 1
    fi
}

# Check required dependencies
echo "Checking dependencies..."
check_command "docker"

# Check if docker-compose is available (either as plugin or standalone)
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not available${NC}"
    echo "Please install Docker Compose (either as a Docker plugin or standalone)"
    exit 1
fi

# Set compose command based on what's available
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# Check Docker version
DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d'.' -f1,2)
if (( $(echo "$DOCKER_VERSION < 24.0" | bc -l) )); then
    echo -e "${RED}Warning: Docker version $DOCKER_VERSION is below minimum required version 24.0${NC}"
    echo "Some features might not work as expected"
fi

# Check Docker Compose version
if [[ $COMPOSE_CMD == "docker compose" ]]; then
    COMPOSE_VERSION=$(docker compose version | grep -oP 'v\K[0-9]+\.[0-9]+')
else
    COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d'.' -f1,2)
fi

if (( $(echo "$COMPOSE_VERSION < 2.20" | bc -l) )); then
    echo -e "${RED}Warning: Docker Compose version $COMPOSE_VERSION is below minimum required version 2.20${NC}"
    echo "Some features might not work as expected"
fi

echo -e "\n${GREEN}All dependencies checked successfully${NC}\n"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    if [ -f .env.template ]; then
        cp .env.template .env
        echo "Created .env file. Please review and modify the values if needed."
    else
        echo -e "${RED}Error: .env.template not found${NC}"
        exit 1
    fi
fi

# Start essential services
echo -e "\n${YELLOW}Starting essential services...${NC}"
$COMPOSE_CMD up -d

# Check if services are running
echo -e "\n${YELLOW}Checking service status...${NC}"
if $COMPOSE_CMD ps | grep -q "Up"; then
    echo -e "${GREEN}Services are running successfully${NC}"
else
    echo -e "${RED}Error: Some services failed to start${NC}"
    echo "Please check the logs with: $COMPOSE_CMD logs"
    exit 1
fi

# Print access information
echo -e "\n${GREEN}Setup complete!${NC}"
echo -e "\nYou can access the application at:"
echo -e "Frontend: ${YELLOW}http://localhost:3000${NC}"
echo -e "Backend API: ${YELLOW}http://localhost:5000${NC}"
echo -e "\nTo view logs:"
echo -e "  ${YELLOW}$COMPOSE_CMD logs -f${NC}"
echo -e "\nTo stop the services:"
echo -e "  ${YELLOW}$COMPOSE_CMD down${NC}" 