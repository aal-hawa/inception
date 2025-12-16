# Developer Documentation

## Overview

This document provides comprehensive technical guidance for developers working on the Inception project. It covers environment setup, development workflows, build processes, and advanced container management techniques specific to this Alpine Linux-based Docker implementation.

## Development Environment Setup

### Prerequisites

Before setting up the development environment, ensure you have:

- **Git**: Version 2.25 or later
- **Docker**: Version 20.10 or later with Docker Compose v2
- **Make**: Build utility for project automation
- **Text Editor/IDE**: VS Code, Vim, or similar with Docker extensions
- **Terminal**: Modern terminal with tab completion
- **System Permissions**: Ability to manage Docker containers and create directories in `/home/$USER/data/`

### Initial Repository Setup

1. **Clone and Navigate**:
   ```bash
   git clone https://github.com/aal-hawa/inception.git
   cd inception
   ```

2. **Verify Project Structure**:
   ```bash
   tree -L 4
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
           │   ├── Dockerfile
           │   ├── conf/mariadb-server.cnf
           │   └── tools/entrypoint.sh
           ├── nginx/
           │   ├── Dockerfile
           │   ├── conf/nginx.conf
           │   └── tools/entrypoint.sh
           └── wordpress/
               ├── Dockerfile
               ├── conf/www.conf
               ├── tools/entrypoint.sh
               └── tools/wp-cli.phar
   ```

### Configuration Files Setup

#### 1. Environment Variables

Create and configure the `.env` file in `srcs/`:

```bash
# srcs/.env
DOMAIN_NAME=YOUR_DOMAIN_NAME
DB_NAME=YOUR_DB_NAME
DB_USER=YOUR_DB_USER
DB_HOST=mariadb
MARIADB_USER=mysql
MARIADB_DATABASE_DIR=/var/lib/mysql
MARIADB_PLUGIN_DIR=/usr/lib/mariadb/plugin
MARIADB_PID_FILE=/run/mysqld/mysqld.pid
DB_ROOT_USER=root
```

#### 2. Secrets Configuration

Set up secure credentials:

```bash
# Generate secure passwords
openssl rand -base64 32 > secrets/db_root_password.txt
openssl rand -base64 32 > secrets/db_password.txt

# Create WordPress credentials (maintain the format)
cat > secrets/credentials.txt << EOF
WP_USER=YOUR_WP_ADMIN_USER
WP_PASS=YOUR_WP_ADMIN_PASSWORD
WP_EMAIL=YOUR_WP_ADMIN_EMAIL
WP_USER2=YOUR_WP_USER
WP_PASS2=YOUR_WP_USER_PASSWORD
WP_EMAIL2=YOUR_WP_USER_EMAIL
EOF

# Set proper permissions
chmod 600 secrets/*
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
# Wait for MariaDB to be healthy
docker compose up -d wordpress
# Wait for WordPress to be healthy
docker compose up -d nginx
```

### Development Build Options

#### Debug Mode

Enable debug logging during development:

```bash
# Build with verbose output
cd srcs
docker compose build --progress=plain

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

# Test WordPress health
docker exec wordpress wp --allow-root --path=/var/www/html/wordpress db check

# Test Nginx configuration
docker exec nginx nginx -t
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

# Check host directory contents
ls -la /home/$USER/data/mariadb/
ls -la /home/$USER/data/wordpress/
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
sudo rm -rf /home/$USER/data/mariadb/*
sudo tar -xzf mariadb-backup-20231201.tar.gz \
  -C /home/$USER/data/mariadb/

# Restore WordPress files
sudo rm -rf /home/$USER/data/wordpress/*
sudo tar -xzf wordpress-backup-20231201.tar.gz \
  -C /home/$USER/data/wordpress/

# Fix permissions
sudo chown -R 999:999 /home/$USER/data/wordpress/
sudo chown -R mysql:mysql /home/$USER/data/mariadb/

# Restart services
make up
```

## Development Workflow

### Code Structure Understanding

#### Dockerfile Analysis

**MariaDB Dockerfile** (`srcs/requirements/mariadb/Dockerfile`):
```dockerfile
FROM alpine:3.22
RUN apk update
RUN apk add mariadb mariadb-client openrc
RUN mkdir -p /run/openrc && touch /run/openrc/softlevel
COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
```

**WordPress Dockerfile** (`srcs/requirements/wordpress/Dockerfile`):
```dockerfile
FROM alpine:3.22
RUN apk update && apk add php php83 php83-fpm php83-mysqli \
  php83-mbstring php83-gd php83-opcache php83-phar php83-xml \
  mariadb-client wget tar
COPY tools/entrypoint.sh /entrypoint.sh
COPY tools/wp-cli.phar /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

**Nginx Dockerfile** (`srcs/requirements/nginx/Dockerfile`):
```dockerfile
FROM alpine:3.22
RUN apk update && apk add nginx openssl
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD [ "/entrypoint.sh" ]
```

#### Configuration Files

- **Nginx Config**: `srcs/requirements/nginx/conf/nginx.conf`
  - SSL configuration with self-signed certificates
  - PHP-FPM proxy to wordpress:9000
  - Static file serving and WordPress URL rewriting

- **PHP-FPM Config**: `srcs/requirements/wordpress/conf/www.conf`
  - Process manager: dynamic
  - User/group: nobody
  - Listen on 0.0.0.0:9000

- **MariaDB Config**: `srcs/requirements/mariadb/conf/mariadb-server.cnf`
  - Bind address: 0.0.0.0
  - Network access enabled for container communication

#### Entrypoint Scripts

**MariaDB Entrypoint** (`srcs/requirements/mariadb/tools/entrypoint.sh`):
- Initializes OpenRC
- Sets up MariaDB data directory
- Creates database and users on first run
- Starts MariaDB server with proper parameters

**WordPress Entrypoint** (`srcs/requirements/wordpress/tools/entrypoint.sh`):
- Downloads WordPress if not present
- Configures wp-config.php with database credentials
- Installs WordPress if not already installed
- Creates admin and subscriber users from secrets
- Starts PHP-FPM service

**Nginx Entrypoint** (`srcs/requirements/nginx/tools/entrypoint.sh`):
- Generates self-signed SSL certificates using DOMAIN_NAME
- Starts Nginx service

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
docker exec wordpress wp --allow-root --path=/var/www/html/wordpress db check

# Test external connectivity
docker exec nginx ping -c 3 google.com
```

#### SSL Certificate Validation

```bash
# Check SSL certificate
docker exec nginx openssl x509 -in /etc/self-signed.crt -text -noout

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
docker exec wordpress wp --allow-root --path=/var/www/html/wordpress cache flush

# Database performance
docker exec mariadb mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW PROCESSLIST;"
```

## Advanced Development Techniques

### Multi-Stage Builds

For optimizing image sizes:

```dockerfile
# Example optimized WordPress Dockerfile
FROM alpine:3.22 as builder
RUN apk add --no-cache php83 php83-phar wget
COPY tools/wp-cli.phar /usr/local/bin/wp

FROM alpine:3.22 as runtime
RUN apk add --no-cache php83 php83-fpm php83-mysqli \
  php83-mbstring php83-gd php83-opcache php83-xml \
  mariadb-client
COPY --from=builder /usr/local/bin/wp /usr/local/bin/wp
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY tools/entrypoint.sh /entrypoint.sh
```

### Custom Networks

```bash
# Create custom network (already defined in docker-compose.yml)
docker network create --driver bridge inception

# Connect containers to custom network
docker network connect inception nginx
docker network connect inception wordpress
docker network connect inception mariadb
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
  nginx:
    volumes:
      - ./logs/nginx:/var/log/nginx
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
        sleep 30
        docker compose exec -T wordpress wp --allow-root --path=/var/www/html/wordpress db check
        docker compose down
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

#### Permission Issues

```bash
# Fix WordPress file permissions
sudo chown -R 999:999 /home/$USER/data/wordpress/

# Fix MariaDB permissions
sudo chown -R mysql:mysql /home/$USER/data/mariadb/
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

1. **Regular Updates**: Keep Alpine base images updated
2. **Minimal Images**: Use minimal base images and remove unnecessary packages
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

### Project-Specific Guidelines

1. **Alpine Linux**: Use Alpine 3.22 as base image for minimal size
2. **Service Dependencies**: Respect service dependencies in docker-compose.yml
3. **Health Checks**: Implement proper health checks for all services
4. **Secret Management**: Use Docker secrets for all sensitive data
5. **Data Persistence**: Use bind mounts for data persistence

### Pull Request Process

1. Create feature branch from `main`
2. Implement changes with tests
3. Update documentation
4. Submit pull request with clear description
5. Address review feedback
6. Merge after approval

This developer documentation provides the foundation for effective development, testing, and maintenance of the Inception project. For specific implementation details, refer to the source code and inline comments.