# User Documentation

## Overview

This document provides essential information for end users and system administrators who need to manage and interact with the Inception Docker hosting environment. The system provides a complete WordPress hosting solution with automated deployment and management capabilities.

## Services Provided

The Inception stack includes the following services:

### Web Services
- **Nginx Web Server**: High-performance reverse proxy with SSL/TLS encryption
  - Handles HTTPS traffic on port 443
  - Provides static file serving and PHP request forwarding
  - Includes security headers and SSL configuration

- **WordPress Content Management System**: Full-featured CMS
  - Accessible via web interface
  - Admin panel available at `/wp-admin`
  - Custom themes and plugins supported
  - Database-driven content storage

### Database Services
- **MariaDB Database Server**: Robust relational database
  - Stores WordPress content, user data, and configuration
  - Automated backup and recovery capabilities
  - Secure access limited to WordPress container

### Infrastructure Services
- **Docker Network Management**: Isolated communication between services
- **Persistent Storage**: Data persistence across container restarts
- **Health Monitoring**: Automated service health checks

## Getting Started

### System Requirements

Before deploying the Inception stack, ensure your system meets these requirements:

- **Operating System**: Linux, macOS, or Windows with Docker support
- **Docker**: Version 20.10 or later
- **Docker Compose**: Version 2.0 or later
- **Memory**: Minimum 2GB RAM (4GB recommended)
- **Storage**: Minimum 10GB free disk space
- **Network**: Port 443 must be available for HTTPS traffic

### Initial Setup

1. **Install Prerequisites**:
   ```bash
   # Install Docker (Ubuntu/Debian example)
   sudo apt update
   sudo apt install docker.io docker-compose-plugin
   
   # Add user to docker group
   sudo usermod -aG docker $USER
   # Log out and back in for changes to take effect
   ```

2. **Clone the Repository**:
   ```bash
   git clone https://github.com/aal-hawa/inception.git
   cd inception
   ```

3. **Configure Credentials**:
   - Edit files in the `secrets/` directory
   - Set strong, unique passwords for each service
   - Ensure domain name is properly configured

## Starting and Stopping the Project

### Starting the Services

To start all services with a single command:
```bash
make all
```

This command performs the following actions:
1. Creates necessary directories on the host system
2. Builds all Docker images
3. Starts all services in detached mode
4. Initializes the database and WordPress

### Manual Step-by-Step Start

If you prefer to start services manually:
```bash
# Create volume directories
make create_volumes

# Build Docker images
make build

# Start services
make up
```

### Stopping the Services

To stop all services:
```bash
make down
```

This stops and removes all containers while preserving data volumes.

### Restarting Services

To restart all running services:
```bash
make restart
```

### Complete Shutdown and Cleanup

To remove all containers, volumes, and data:
```bash
make fclean
```
⚠️ **Warning**: This will permanently delete all website data and databases.

## Accessing the Website

### Website Access

1. **Main Website**: Open your web browser and navigate to:
   ```
   https://your-domain-name
   ```
   Replace `your-domain-name` with your configured domain.

2. **WordPress Admin Panel**: Access the administration interface at:
   ```
   https://your-domain-name/wp-admin
   ```

### SSL Certificate Information

- The project uses self-signed SSL certificates
- Your browser will show a security warning
- Click "Advanced" and "Proceed to website" to continue
- For production use, replace with proper SSL certificates

### Initial WordPress Setup

1. **First-Time Configuration**:
   - Visit the admin panel URL
   - Create your WordPress administrator account
   - Configure site title and description
   - Select preferred language and timezone

2. **Recommended Settings**:
   - Enable automatic updates
   - Configure backup plugins
   - Set up security plugins
   - Configure caching for better performance

## Managing Credentials

### Credential Locations

All sensitive credentials are stored in the `secrets/` directory:

- `secrets/db_root_password.txt` - MariaDB root password
- `secrets/db_password.txt` - WordPress database user password
- `secrets/credentials.txt` - WordPress admin credentials

### Viewing Current Credentials

To view current credentials:
```bash
# Database root password
cat secrets/db_root_password.txt

# WordPress database password
cat secrets/db_password.txt

# WordPress admin credentials
cat secrets/credentials.txt
```

### Updating Credentials

1. **Stop all services**:
   ```bash
   make down
   ```

2. **Edit the credential files**:
   ```bash
   nano secrets/db_root_password.txt
   nano secrets/db_password.txt
   nano secrets/credentials.txt
   ```

3. **Restart services**:
   ```bash
   make up
   ```

### Security Best Practices

- **Use strong passwords**: Minimum 12 characters with mixed case, numbers, and symbols
- **Regular rotation**: Change passwords every 90 days
- **Limited access**: Only share credentials with authorized personnel
- **Secure storage**: Keep backup copies of credentials in secure locations

## Monitoring and Maintenance

### Checking Service Status

To verify all services are running correctly:

1. **Using Docker Compose**:
   ```bash
   cd srcs
   docker compose ps
   ```

2. **Using Docker**:
   ```bash
   docker ps
   ```

3. **Check Service Logs**:
   ```bash
   # View all service logs
   cd srcs
   docker compose logs
   
   # View specific service logs
   docker compose logs nginx
   docker compose logs wordpress
   docker compose logs mariadb
   ```

### Health Check Status

Each service includes automated health checks:

```bash
# Check container health
docker ps --format "table {{.Names}}\t{{.Status}}"

# Detailed health information
docker inspect --format='{{.State.Health.Status}}' mariadb
docker inspect --format='{{.State.Health.Status}}' wordpress
docker inspect --format='{{.State.Health.Status}}' nginx
```

### Common Issues and Solutions

#### Service Won't Start

1. **Check port availability**:
   ```bash
   sudo netstat -tlnp | grep :443
   ```

2. **Check Docker status**:
   ```bash
   sudo systemctl status docker
   ```

3. **Check disk space**:
   ```bash
   df -h
   ```

#### Website Not Accessible

1. **Verify Nginx is running**:
   ```bash
   docker logs nginx
   ```

2. **Check SSL certificates**:
   ```bash
   docker exec nginx ls -la /etc/ssl/certs/
   ```

3. **Test local connectivity**:
   ```bash
   curl -k https://localhost
   ```

#### Database Connection Issues

1. **Check MariaDB logs**:
   ```bash
   docker logs mariadb
   ```

2. **Test database connectivity**:
   ```bash
   docker exec wordpress wp-cli.phar db check
   ```

### Backup and Recovery

#### Database Backup

```bash
# Create database backup
docker exec mariadb mysqldump -u root -p$(cat secrets/db_root_password.txt) wordpress > backup.sql

# Automated daily backup (add to crontab)
0 2 * * * docker exec mariadb mysqldump -u root -p$(cat /path/to/secrets/db_root_password.txt) wordpress > /path/to/backups/backup-$(date +\%Y\%m\%d).sql
```

#### WordPress Files Backup

```bash
# Backup WordPress files
tar -czf wordpress-backup.tar.gz /home/$USER/data/wordpress
```

#### Volume Restoration

```bash
# Stop services
make down

# Restore from backup
sudo rm -rf /home/$USER/data/mariadb/*
sudo rm -rf /home/$USER/data/wordpress/*

# Extract backups
tar -xzf mariadb-backup.tar.gz -C /home/$USER/data/mariadb/
tar -xzf wordpress-backup.tar.gz -C /home/$USER/data/wordpress/

# Restart services
make up
```

## Performance Optimization

### Monitoring Resource Usage

```bash
# Check container resource usage
docker stats

# Check disk usage
docker system df
```

### Optimization Tips

1. **Enable WordPress Caching**: Install caching plugins like W3 Total Cache
2. **Optimize Images**: Use image optimization plugins
3. **Database Optimization**: Regular database cleanup and optimization
4. **CDN Integration**: Consider CDN for static assets

## Troubleshooting

### Emergency Procedures

#### Complete System Reset

If you need to completely reset the system:

```bash
# Complete cleanup (removes all data)
make fclean

# Fresh start
make all
```

#### Individual Service Recovery

```bash
# Restart specific service
cd srcs
docker compose restart nginx
docker compose restart wordpress
docker compose restart mariadb
```

### Getting Help

For additional support:
1. Check service logs for error messages
2. Verify all prerequisites are met
3. Ensure sufficient system resources
4. Review Docker and Docker Compose documentation
5. Consult the project README for technical details

### Log Analysis

Important log locations:
- Nginx access/error logs: `docker logs nginx`
- WordPress errors: `docker logs wordpress`
- Database errors: `docker logs mariadb`
- System logs: `journalctl -u docker`