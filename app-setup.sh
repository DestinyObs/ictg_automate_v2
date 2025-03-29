#!/bin/bash
# Update and install required packages
apt update -y && apt upgrade -y
apt install -y docker.io docker-compose

# Start Docker service
systemctl enable docker
systemctl start docker

# Pull Docker images
docker pull destinyobs/ictg_task-backend:latest
docker pull destinyobs/ictg_task-frontend:latest
docker pull postgres:latest

# Create a Docker network
docker network create devops-network

# Run Postgres container
docker run -d --name postgres_database --network devops-network -e POSTGRES_USER=app -e POSTGRES_PASSWORD=changethis123 -e POSTGRES_DB=app -p 5432:5432 postgres:latest

# Run Backend container
docker run -d --name backend_service --network devops-network -p 8000:8000 --env-file /root/.env destinyobs/ictg_task-backend:latest

# Run Frontend container
docker run -d --name frontend_service --network devops-network -p 5173:5173 --env-file /root/.env destinyobs/ictg_task-frontend:latest
