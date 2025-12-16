# User Documentation

## Overview

This document provides essential information for end users and system administrators who need to manage and interact with the Inception Docker hosting environment. The system provides a complete WordPress hosting solution built from Alpine Linux containers with automated deployment and management capabilities.

## Services Provided

The Inception stack includes the following services:

### Web Services
- **Nginx Web Server (Alpine 3.22)**: High-performance reverse proxy with automated SSL/TLS
  - Handles HTTPS traffic on port 443
  - Automatically generates self-signed SSL certificates on startup
  - Provides static file serving and PHP-FPM request forwarding
  - Uses domain name from environment variables for certificate generation

- **WordPress Content Management System**: Full-featured CMS with automated setup
  - Accessible via web interface
  - Admin panel available at `/wp-admin`
  - Automatically downloads and configures WordPress on first run
  - Creates admin and subscriber users automatically from secrets
  - Uses PHP-FPM 8.3 for optimal performance

### Database Services
- **MariaDB Database Server (Alpine 3.22)**: Robust relational database with OpenRC
  - Stores WordPress content, user data, and configuration
  - Automated database initialization with secure user accounts
  - Uses OpenRC for service management
  - Secure access limited to WordPress container

### Infrastructure Services
- **Docker Network Management**: Custom bridge network named "inception" for isolated communication
- **Persistent Storage**: Bind mount volumes to host filesystem at `/home/$USER/data/`
- **Health Monitoring**: Automated health checks for all services with dependency management

## Getting Started

### System Requirements

Before deploying the Inception stack, ensure your system meets these requirements:

- **Operating System**: Linux, macOS, or Windows with Docker support
- **Docker**: Version 20.10 or later
- **Docker Compose**: Version 2.0 or later
- **Make**: Build utility for project automation
- **Memory**: Minimum 2GB RAM (4GB recommended)
- **Storage**: Minimum 10GB free disk space in `/home/$USER/data/`
- **Network**: Port 443 must be available for HTTPS traffic
- **Permissions**: Ability to create directories in `/home/$USER/data/`

### Initial Setup

1. **Install Prerequisites**:
   ```bash
   # Install Docker (Ubuntu/Debian example)
   sudo apt update
   sudo apt install docker.io docker-compose-plugin make
   
   # Add user to docker group
   sudo usermod -aG docker $USER
   # Log out and back in for changes to take effect
   ```

2. **Clone the Repository**:
   ```bash
   git clone https://github.com/aal-hawa/inception.git
   cd inception
   ```

3. **Configure Environment Variables**:
   Create `srcs/.env` file:
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

4. **Configure Credentials**:
   Set up the `secrets/` directory with secure credentials:
   ```bash
   # Create secure passwords
   openssl rand -base64 32 > secrets/db_root_password.txt
   openssl rand -base64 32 > secrets/db_password.txt

   # Create WordPress credentials
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

## Starting and Stopping the Project

### Starting the Services

To start all services with a single command:
```bash
make all
```

This command performs the following actions:
1. Creates necessary directories: `/home/$USER/data/mariadb` and `/home/$USER/data/wordpress`
2. Builds all Docker images from Alpine 3.22
3. Starts services in dependency order (MariaDB → WordPress → Nginx)
4. Initializes database and WordPress automatically
5. Generates SSL certificates for Nginx

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

This stops and removes all containers while preserving data in host directories.

### Restarting Services

To restart all running services:
```bash
make restart
```

### Complete Shutdown and Cleanup

To remove all containers, networks, and host data:
```bash
make fclean
```
⚠️ **Warning**: This will permanently delete all website data and databases from `/home/$USER/data/`.

## Accessing the Website

### Website Access

1. **Main Website**: Open your web browser and navigate to:
   ```
   https://YOUR_DOMAIN_NAME
   ```
   Replace `YOUR_DOMAIN_NAME` with the DOMAIN_NAME from your `.env` file.

2. **WordPress Admin Panel**: Access the administration interface at:
   ```
   https://YOUR_DOMAIN_NAME/wp-admin
   ```

### SSL Certificate Information

- The project automatically generates self-signed SSL certificates on first startup
- Your browser will show a security warning (this is normal for self-signed certificates)
- Click "Advanced" and "Proceed to website" to continue
- Certificates are generated using the domain name from your `.env` file

### Initial WordPress Setup

The WordPress installation is automated:

1. **Automatic Configuration**:
   - WordPress is automatically downloaded and configured
   - Database connection is established automatically
   - Two users are created automatically from `secrets/credentials.txt`:
     - Admin user (configured in secrets)
     - Subscriber user (configured in secrets)

2. **Login Credentials**:
   - View current credentials:
     ```bash
     cat secrets/credentials.txt
     ```
   - Admin credentials: WP_USER and WP_PASS from secrets file
   - Subscriber credentials: WP_USER2 and WP_PASS2 from secrets file

3. **Recommended First Steps**:
   - Change default passwords for security
   - Configure site title and description in WordPress settings
   - Install necessary plugins and themes
   - Set up regular backups

## Managing Credentials

### Credential Locations

All sensitive credentials are stored in the `secrets/` directory:

- `secrets/db_root_password.txt` - MariaDB root password
- `secrets/db_password.txt` - WordPress database user password
- `secrets/credentials.txt` - WordPress admin and subscriber credentials

### Viewing Current Credentials

To view current credentials:
```bash
# Database root password
cat secrets/db_root_password.txt

# WordPress database password
cat secrets/db_password.txt

# WordPress user credentials
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

- **Change default passwords**: Immediately change the default credentials after first setup
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
   df -h /home/$USER/data/
   ```

4. **Verify environment variables**:
   ```bash
   cat srcs/.env
   ```

#### Website Not Accessible

1. **Verify Nginx is running**:
   ```bash
   docker logs nginx
   ```

2. **Check SSL certificates**:
   ```bash
   docker exec nginx ls -la /etc/self-signed.*
   ```

3. **Test local connectivity**:
   ```bash
   curl -k https://localhost
   ```

4. **Check domain name configuration**:
   ```bash
   docker exec nginx env | grep DOMAIN_NAME
   ```

#### Database Connection Issues

1. **Check MariaDB logs**:
   ```bash
   docker logs mariadb
   ```

2. **Test database connectivity**:
   ```bash
   docker exec wordpress wp --allow-root --path=/var/www/html/wordpress db check
   ```

3. **Verify database user exists**:
   ```bash
   docker exec mariadb mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW DATABASES;"
   ```

### Backup and Recovery

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

#### WordPress Files Backup

```bash
# Backup WordPress files
tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz \
  -C /home/$USER/data/wordpress .
```

#### Volume Restoration

```bash
# Stop services
make down

# Restore database from backup
gunzip -c backup-20231201.sql.gz | docker run -i --rm \
  -v mariadb:/data alpine sh -c "cat > /data/restore.sql"

# Restore WordPress files
tar -xzf wordpress-backup-20231201.tar.gz \
  -C /home/$USER/data/wordpress/

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
df -h /home/$USER/data/
```

### Optimization Tips

1. **WordPress Caching**: Install caching plugins like W3 Total Cache or WP Super Cache
2. **Image Optimization**: Use image optimization plugins for uploaded images
3. **Database Optimization**: Regular database cleanup and optimization using WP-CLI
4. **PHP-FPM Tuning**: Adjust PHP-FPM settings in `conf/www.conf` based on traffic
5. **Nginx Optimization**: Enable gzip compression and configure caching headers

### Scaling Considerations

- **Database Scaling**: Consider read replicas for high-traffic sites
- **Static File Serving**: Configure CDN for static assets
- **Load Balancing**: Multiple Nginx instances behind a load balancer
- **Container Resources**: Adjust memory and CPU limits based on usage patterns

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

#### SSL Certificate Issues

```bash
# Regenerate SSL certificates
docker exec nginx rm /etc/self-signed.*
docker compose restart nginx
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

### Data Locations

- **Database files**: `/home/$USER/data/mariadb/`
- **WordPress files**: `/home/$USER/data/wordpress/`
- **SSL certificates**: Generated inside Nginx container at `/etc/self-signed.*`
- **Configuration files**: `srcs/requirements/*/conf/`
- **Secrets**: `secrets/` directory