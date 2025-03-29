#!/bin/bash
set -e  # Exit on error

echo "Updating system and installing dependencies..."
apt update -y && apt upgrade -y
apt install -y docker.io docker-compose

echo "Starting Docker service..."
systemctl enable docker
systemctl start docker

echo "Creating Docker network..."
docker network create devops-network || echo "Network already exists"

echo "Pulling Docker images..."
docker pull destinyobs/ictg_task-backend:latest
docker pull destinyobs/ictg_task-frontend:latest
docker pull postgres:latest

echo "Running PostgreSQL container..."
docker run -d --name postgres_database --network devops-network \
  -e POSTGRES_USER=app -e POSTGRES_PASSWORD=changethis123 -e POSTGRES_DB=app \
  -p 5432:5432 postgres:latest

echo "Waiting for PostgreSQL to start..."
sleep 10  # Give DB time to initialize

echo "Checking for environment file..."
if [ ! -f /root/.env ]; then
  echo "Environment file missing! Creating a default one..."
  cat <<EOF > /root/.env
DATABASE_URL=postgres://app:changethis123@postgres_database:5432/app
BACKEND_URL=http://backend_service:8000
FRONTEND_URL=http://frontend_service:5173
EOF
fi

echo "Running Backend container..."
docker run -d --name backend_service --network devops-network \
  -p 8000:8000 --env-file /root/.env destinyobs/ictg_task-backend:latest

echo "Running Frontend container..."
docker run -d --name frontend_service --network devops-network \
  -p 5173:5173 --env-file /root/.env destinyobs/ictg_task-frontend:latest

echo "Setup complete!"
