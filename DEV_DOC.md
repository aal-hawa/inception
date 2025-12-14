# Developer Documentation

## Overview

This document provides comprehensive technical guidance for developers working on the Inception project. It covers environment setup, development workflows, build processes, and advanced container management techniques.

## Development Environment Setup

### Prerequisites

Before setting up the development environment, ensure you have:

- **Git**: Version 2.25 or later
- **Docker**: Version 20.10 or later with Docker Compose v2
- **Make**: Build utility for project automation
- **Text Editor/IDE**: VS Code, Vim, or similar with Docker extensions
- **Terminal**: Modern terminal with tab completion
- **System Permissions**: Ability to manage Docker containers and volumes

### Initial Repository Setup

1. **Clone and Navigate**:
   ```bash
   git clone https://github.com/aal-hawa/inception.git
   cd inception
   ```

2. **Verify Project Structure**:
   ```bash
   tree -L 3
   ```
   Expected structure:
   ```
   inception/
   ├── Makefile
   ├── README.md
   ├── USER_DOC.md
   ├── DEV_DOC.md
   ├── secrets/
   │   ├── db_root_password.txt
   │   ├── db_password.txt
   │   └── credentials.txt
   └── srcs/
       ├── docker-compose.yml
       └── requirements/
           ├── mariadb/
           ├── nginx/
           └── wordpress/
   ```

### Configuration Files Setup

#### 1. Environment Variables

Create and configure the `.env` file in `srcs/`:

```bash
# srcs/.env
DOMAIN_NAME=your-domain.com
WP_TITLE=My WordPress Site
WP_ADMIN_USER=admin
WP_ADMIN_EMAIL=admin@your-domain.com
WP_USER=user
WP_USER_EMAIL=user@your-domain.com
```

#### 2. Secrets Configuration

Set up secure credentials:

```bash
# Generate secure passwords
openssl rand -base64 32 > secrets/db_root_password.txt
openssl rand -base64 32 > secrets/db_password.txt

# Create WordPress admin credentials
echo "admin:$(openssl rand -base64 16)" > secrets/credentials.txt

# Set proper permissions
chmod 600 secrets/*
```

#### 3. SSL Certificates (Development)

For development, create self-signed certificates:

```bash
# Create SSL directory
mkdir -p srcs/requirements/nginx/ssl

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout srcs/requirements/nginx/ssl/nginx.key \
  -out srcs/requirements/nginx/ssl/nginx.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```

## Build and Launch Process

### Using the Makefile

The project provides a comprehensive Makefile for automation:

```bash
# Complete build and deployment
make all

# Individual steps
make create_volumes  # Create host directories
make build          # Build Docker images
make up             # Start services

# Management commands
make down           # Stop services
make restart        # Restart services
make clean          # Stop services (alias)
make fclean         # Complete cleanup
make re             # Rebuild from scratch
```

### Manual Build Process

For debugging or custom builds:

```bash
# 1. Create volume directories
mkdir -p /home/$USER/data/mariadb
mkdir -p /home/$USER/data/wordpress

# 2. Navigate to source directory
cd srcs

# 3. Build individual services
docker compose build mariadb
docker compose build wordpress
docker compose build nginx

# 4. Start services in dependency order
docker compose up -d mariadb
docker compose up -d wordpress
docker compose up -d nginx
```

### Development Build Options

#### Debug Mode

Enable debug logging during development:

```bash
# Build with debug flags
cd srcs
docker compose build --build-arg DEBUG=1 wordpress

# Run with verbose logging
docker compose up --build
```

#### Development Overrides

Create `docker-compose.override.yml` for development:

```yaml
# srcs/docker-compose.override.yml
services:
  wordpress:
    volumes:
      - ./requirements/wordpress/tools:/tools:ro
    environment:
      - WP_DEBUG=1
      - WP_DEBUG_LOG=1
  
  nginx:
    volumes:
      - ./requirements/nginx/conf:/etc/nginx/conf.d:ro
```

## Container Management Commands

### Basic Container Operations

```bash
# List all containers
docker ps -a

# Show running containers with stats
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# View container details
docker inspect nginx
docker inspect wordpress
docker inspect mariadb
```

### Log Management

```bash
# View all service logs
cd srcs
docker compose logs

# Follow logs in real-time
docker compose logs -f

# View specific service logs
docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb

# View last 100 lines
docker compose logs --tail=100

# View logs with timestamps
docker compose logs -t
```

### Resource Monitoring

```bash
# Live resource usage
docker stats

# Resource usage for specific containers
docker stats nginx wordpress mariadb

# Historical resource usage
docker stats --no-stream

# Check disk usage
docker system df
```

### Health Check Management

```bash
# Check health status
docker ps --format "table {{.Names}}\t{{.Status}}"

# Detailed health information
docker inspect --format='{{json .State.Health}}' mariadb

# Manual health check
docker exec mariadb mysqladmin ping -u root -p$(cat secrets/db_root_password.txt)
```

## Volume and Data Management

### Volume Operations

```bash
# List all volumes
docker volume ls

# Inspect volume details
docker volume inspect mariadb
docker volume inspect wordpress

# View volume usage
docker system df -v
```

### Backup Procedures

#### Database Backup

```bash
# Create database backup
docker exec mariadb mysqldump \
  -u root \
  -p$(cat secrets/db_root_password.txt) \
  --single-transaction \
  --routines \
  --triggers \
  wordpress > backup-$(date +%Y%m%d).sql

# Compressed backup
docker exec mariadb mysqldump \
  -u root \
  -p$(cat secrets/db_root_password.txt) \
  wordpress | gzip > backup-$(date +%Y%m%d).sql.gz
```

#### Volume Backup

```bash
# Backup MariaDB volume
sudo tar -czf mariadb-backup-$(date +%Y%m%d).tar.gz \
  -C /home/$USER/data/mariadb .

# Backup WordPress volume
sudo tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz \
  -C /home/$USER/data/wordpress .
```

### Data Recovery

```bash
# Stop services
make down

# Restore database
docker run --rm -v mariadb:/data \
  -v $(pwd):/backup alpine \
  tar -xzf /backup/mariadb-backup.tar.gz -C /data

# Restore WordPress files
docker run --rm -v wordpress:/data \
  -v $(pwd):/backup alpine \
  tar -xzf /backup/wordpress-backup.tar.gz -C /data

# Restart services
make up
```

## Development Workflow

### Code Structure Understanding

#### Dockerfile Analysis

**MariaDB Dockerfile** (`srcs/requirements/mariadb/Dockerfile`):
```dockerfile
FROM alpine:latest
# Custom MariaDB installation and configuration
# Security hardening
# Initialization scripts
```

**WordPress Dockerfile** (`srcs/requirements/wordpress/Dockerfile`):
```dockerfile
FROM alpine:latest
# PHP-FPM installation
# WordPress download and configuration
# WP-CLI setup
# Performance optimization
```

**Nginx Dockerfile** (`srcs/requirements/nginx/Dockerfile`):
```dockerfile
FROM alpine:latest
# Nginx installation
# SSL configuration
# Performance tuning
# Security headers
```

#### Configuration Files

- **Nginx Config**: `srcs/requirements/nginx/conf/nginx.conf`
- **PHP-FPM Config**: `srcs/requirements/wordpress/conf/www.conf`
- **MariaDB Config**: `srcs/requirements/mariadb/conf/mariadb-server.cnf`

### Making Changes

#### 1. Modifying Docker Images

```bash
# Edit Dockerfile
vim srcs/requirements/wordpress/Dockerfile

# Rebuild specific service
cd srcs
docker compose build --no-cache wordpress

# Restart service with new image
docker compose up -d wordpress
```

#### 2. Updating Configuration

```bash
# Edit configuration files
vim srcs/requirements/nginx/conf/nginx.conf

# Restart affected service
docker compose restart nginx

# Test configuration
docker exec nginx nginx -t
```

#### 3. Adding New Services

```bash
# Create new service directory
mkdir -p srcs/requirements/newservice

# Create Dockerfile
vim srcs/requirements/newservice/Dockerfile

# Update docker-compose.yml
vim srcs/docker-compose.yml

# Build and test
cd srcs
docker compose build newservice
docker compose up -d newservice
```

### Testing and Validation

#### Service Connectivity Tests

```bash
# Test Nginx to WordPress connectivity
docker exec nginx wget -qO- http://wordpress:9000

# Test WordPress to MariaDB connectivity
docker exec wordpress wp-cli.phar db check

# Test external connectivity
docker exec nginx ping -c 3 google.com
```

#### SSL Certificate Validation

```bash
# Check SSL certificate
docker exec nginx openssl x509 -in /etc/ssl/certs/nginx.crt -text -noout

# Test SSL configuration
docker exec nginx nginx -t

# Verify SSL endpoint
openssl s_client -connect localhost:443 -servername localhost
```

#### Performance Testing

```bash
# Basic load test
ab -n 100 -c 10 https://localhost/

# WordPress performance test
docker exec wordpress wp-cli.phar cache flush

# Database performance
docker exec mariadb mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW PROCESSLIST;"
```

## Advanced Development Techniques

### Multi-Stage Builds

For optimizing image sizes:

```dockerfile
# Example multi-stage WordPress Dockerfile
FROM alpine:latest as builder
# Build stage with development tools

FROM alpine:latest as runtime
# Runtime stage with only necessary components
COPY --from=builder /path/to/artifacts /path/to/destination
```

### Custom Networks

```bash
# Create custom network
docker network create --driver bridge inception-dev

# Connect containers to custom network
docker network connect inception-dev nginx
docker network connect inception-dev wordpress
```

### Development Scripts

Create helper scripts in `scripts/` directory:

```bash
#!/bin/bash
# scripts/dev-setup.sh

# Development environment setup
set -e

echo "Setting up development environment..."

# Create development override
cat > srcs/docker-compose.override.yml << EOF
version: '3.8'
services:
  wordpress:
    environment:
      - WP_DEBUG=1
      - WP_DEBUG_LOG=1
    volumes:
      - ./logs:/var/log/wordpress
EOF

echo "Development environment configured!"
```

### Integration with CI/CD

#### GitHub Actions Example

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker
      uses: docker/setup-buildx-action@v2
    
    - name: Build services
      run: |
        cd srcs
        docker compose build
    
    - name: Run tests
      run: |
        cd srcs
        docker compose up -d
        # Add test commands here
```

## Troubleshooting Guide

### Common Development Issues

#### Build Failures

```bash
# Clear build cache
docker builder prune -a

# Rebuild without cache
docker compose build --no-cache

# Check build logs
docker compose build --progress=plain
```

#### Container Startup Issues

```bash
# Check container logs
docker compose logs service-name

# Inspect container state
docker inspect service-name

# Debug container interaction
docker run -it --rm --network inception alpine sh
```

#### Network Issues

```bash
# Check network configuration
docker network ls
docker network inspect inception

# Test connectivity
docker exec nginx ping wordpress
docker exec wordpress ping mariadb
```

### Performance Debugging

```bash
# Monitor resource usage
docker stats --no-stream

# Check disk I/O
docker exec mariadb iotop

# Analyze slow queries
docker exec mariadb mysql -u root -p -e "SHOW SLOW QUERY LOG;"
```

## Best Practices

### Security Considerations

1. **Regular Updates**: Keep base images updated
2. **Minimal Images**: Use minimal base images (Alpine)
3. **Secret Management**: Never commit secrets to version control
4. **Network Isolation**: Use custom networks for service isolation
5. **Regular Scanning**: Scan images for vulnerabilities

### Performance Optimization

1. **Image Layer Caching**: Optimize Dockerfile layer order
2. **Resource Limits**: Set appropriate resource constraints
3. **Health Checks**: Implement comprehensive health checks
4. **Monitoring**: Set up monitoring and alerting
5. **Backup Strategies**: Implement automated backup procedures

### Development Workflow

1. **Feature Branches**: Use feature branches for development
2. **Code Review**: Implement code review processes
3. **Testing**: Write and maintain tests
4. **Documentation**: Keep documentation updated
5. **Version Control**: Use semantic versioning

## Contributing Guidelines

### Code Standards

- Follow Dockerfile best practices
- Use consistent naming conventions
- Write clear, concise commit messages
- Document changes in documentation
- Test changes thoroughly

### Pull Request Process

1. Create feature branch from `develop`
2. Implement changes with tests
3. Update documentation
4. Submit pull request with clear description
5. Address review feedback
6. Merge after approval

This developer documentation provides the foundation for effective development, testing, and maintenance of the Inception project. For specific implementation details, refer to the source code and inline comments.