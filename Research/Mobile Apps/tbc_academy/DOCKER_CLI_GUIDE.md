# Docker CLI Guide: Setup, Automation & Building Objects

## Table of Contents
1. [Basic Concepts](#basic-concepts)
2. [Essential Commands](#essential-commands)
3. [Building Docker Images](#building-docker-images)
4. [Running Containers](#running-containers)
5. [Docker Networking & Volumes](#docker-networking--volumes)
6. [Automation with Docker Compose](#automation-with-docker-compose)
7. [Best Practices](#best-practices)

---

## Basic Concepts

### Docker Objects:
- **Image:** Blueprint for creating containers (immutable)
- **Container:** Running instance of an image
- **Volume:** Persistent data storage
- **Network:** Communication between containers
- **Registry:** Repository for images (Docker Hub, etc.)

---

## Essential Commands

### Authentication & Account Management

```bash
# Login to Docker Hub
docker login

# Login with specific credentials
docker login -u username -p password

# View currently logged-in user
docker whoami

# Logout
docker logout
```

### Image Management

```bash
# List all local images
docker images

# Search for images on Docker Hub
docker search ubuntu

# Pull an image from Docker Hub
docker pull ubuntu:latest

# Remove an image
docker rmi image_id_or_name

# Tag an image
docker tag ubuntu:latest myusername/ubuntu:v1.0

# Push image to registry
docker push myusername/ubuntu:v1.0

# View image history
docker history image_name

# Inspect image details
docker inspect image_name
```

### Container Management

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Run a container
docker run -d --name my_container ubuntu:latest

# Run with interactive terminal
docker run -it ubuntu:latest /bin/bash

# Start a stopped container
docker start container_id

# Stop a running container
docker stop container_id

# Remove a container
docker rm container_id

# View container logs
docker logs container_id

# Execute command in running container
docker exec -it container_id /bin/bash

# View container stats (CPU, memory)
docker stats container_id

# Copy files to/from container
docker cp local_path container_id:/container_path
docker cp container_id:/container_path local_path
```

---

## Building Docker Images

### Method 1: Using Dockerfile

Create a `Dockerfile`:

```dockerfile
# Use a base image
FROM ubuntu:20.04

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

# Copy files from host to container
COPY . /app

# Install Python dependencies
RUN pip install -r requirements.txt

# Expose port
EXPOSE 8000

# Set environment variable
ENV APP_ENV=production

# Run command on container start
CMD ["python3", "app.py"]
```

### Build the Image

```bash
# Build image with tag
docker build -t myapp:1.0 .

# Build with multiple tags
docker build -t myapp:1.0 -t myapp:latest .

# Build with build arguments
docker build -t myapp:1.0 --build-arg NODE_ENV=production .

# View build process
docker build --progress=plain -t myapp:1.0 .
```

### Example: Multi-stage Build

```dockerfile
# Stage 1: Build
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm install --production
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

---

## Running Containers

### Basic Run Examples

```bash
# Run in detached mode (background)
docker run -d --name webserver nginx:latest

# Run with port mapping
docker run -d -p 8080:80 --name webserver nginx:latest
# Host port 8080 -> Container port 80

# Run with environment variables
docker run -d -e DB_HOST=localhost -e DB_PORT=5432 myapp:1.0

# Run with volume mount
docker run -d -v /host/path:/container/path myapp:1.0

# Run with resource limits
docker run -d --memory=512m --cpus=1.0 myapp:1.0

# Run with restart policy
docker run -d --restart=always myapp:1.0
# Policies: no, always, on-failure, unless-stopped

# Run multiple containers together
docker run -d --name db postgres:13
docker run -d --link db:db --name app myapp:1.0
```

### Container Inspection

```bash
# View container details
docker inspect container_id

# View only specific info
docker inspect --format='{{.State.Status}}' container_id

# Get container IP address
docker inspect --format='{{.NetworkSettings.IPAddress}}' container_id

# View processes in container
docker top container_id
```

---

## Docker Networking & Volumes

### Networks

```bash
# List networks
docker network ls

# Create a custom network
docker network create my_network

# Connect container to network
docker network connect my_network container_name

# Disconnect container from network
docker network disconnect my_network container_name

# Run container on specific network
docker run -d --network=my_network --name=service1 myapp:1.0
```

### Volumes

```bash
# List volumes
docker volume ls

# Create a volume
docker volume create my_volume

# Inspect volume
docker volume inspect my_volume

# Run container with volume
docker run -d -v my_volume:/app/data myapp:1.0

# Bind mount (map host directory)
docker run -d -v $(pwd)/data:/app/data myapp:1.0

# Remove volume
docker volume rm my_volume

# Remove unused volumes
docker volume prune
```

---

## Automation with Docker Compose

### docker-compose.yml Example

```yaml
version: '3.8'

services:
  # Database Service
  db:
    image: postgres:13
    container_name: tbc_db
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secure_password
      POSTGRES_DB: tbc_academy
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - tbc_network
    restart: always

  # API Service
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: tbc_api
    ports:
      - "8000:8000"
    environment:
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: admin
      DB_PASSWORD: secure_password
    depends_on:
      - db
    volumes:
      - ./app:/app
    networks:
      - tbc_network
    restart: always

  # Redis Cache
  cache:
    image: redis:7-alpine
    container_name: tbc_cache
    ports:
      - "6379:6379"
    networks:
      - tbc_network
    restart: always

volumes:
  db_data:

networks:
  tbc_network:
    driver: bridge
```

### Docker Compose Commands

```bash
# Start all services
docker-compose up -d

# View services
docker-compose ps

# View logs
docker-compose logs -f service_name

# Stop all services
docker-compose down

# Remove volumes too
docker-compose down -v

# Rebuild images
docker-compose up -d --build

# Run command in service
docker-compose exec api /bin/bash

# Scale service
docker-compose up -d --scale api=3
```

---

## Cleanup & Maintenance

```bash
# Remove unused images
docker image prune

# Remove stopped containers
docker container prune

# Remove all unused objects
docker system prune

# View disk usage
docker system df

# Remove specific container with force
docker rm -f container_id

# Remove all stopped containers
docker container prune -f

# View Docker stats
docker stats
```

---

## Best Practices

### 1. **Dockerfile Optimization**
```dockerfile
# ✅ Good: Combine commands to reduce layers
RUN apt-get update && apt-get install -y \
    package1 \
    package2 && \
    rm -rf /var/lib/apt/lists/*

# ❌ Avoid: Multiple RUN commands
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2
```

### 2. **Use .dockerignore**
Create `.dockerignore` file:
```
node_modules
.git
.env
__pycache__
*.pyc
.DS_Store
```

### 3. **Security**
```bash
# Don't run as root
USER appuser

# Use specific versions, not 'latest'
FROM ubuntu:20.04

# Scan image for vulnerabilities
docker scan myapp:1.0
```

### 4. **Resource Management**
```bash
# Set memory and CPU limits
docker run -d --memory=512m --cpus=0.5 myapp:1.0
```

### 5. **Logging**
```bash
# View logs with timestamps
docker logs -t container_id

# Follow logs (tail -f)
docker logs -f container_id

# View last 100 lines
docker logs --tail 100 container_id
```

---

## Useful Aliases for Windows PowerShell

Add to your PowerShell profile (`$PROFILE`):

```powershell
# Edit profile
notepad $PROFILE

# Add these aliases
function d { docker @args }
function dc { docker-compose @args }
function dps { docker ps -a }
function dimg { docker images }
function dlogs { docker logs -f @args }
function drun { docker run -it @args }
```

---

## Quick Reference Commands

```bash
# Show Docker version and info
docker version
docker info

# Show disk usage
docker system df

# Clean up (careful!)
docker system prune -a

# Get help
docker --help
docker run --help
docker-compose --help
```

---

## Troubleshooting

```bash
# Container won't start? Check logs
docker logs container_id

# Port already in use?
netstat -ano | findstr :8080  # Windows
# Then: docker run -p 9000:8000 image_name

# Check container exit code
docker inspect container_id --format='{{.State.ExitCode}}'

# Debug by running shell
docker run -it image_name /bin/bash
```

---

## Resources

- [Official Docker Docs](https://docs.docker.com/)
- [Docker CLI Reference](https://docs.docker.com/engine/reference/commandline/docker/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)
