*This project has been created as part of the 42 curriculum by aal-hawa.*

# Inception

## Description

Inception is a comprehensive Docker-based project that demonstrates advanced containerization skills by building a complete LEMP stack (Linux, Nginx, MariaDB, PHP) from scratch using Alpine Linux containers. This project creates a fully functional WordPress hosting environment with automated SSL certificate generation, secure credential management, and persistent data storage.

The project architecture consists of:
- **Nginx** (Alpine 3.21) as a reverse proxy and web server with automated SSL/TLS support
- **MariaDB** (Alpine 3.21) as the database backend with OpenRC service management
- **WordPress** (Alpine 3.21) with PHP-FPM 8.3 and WP-CLI for automated WordPress installation
- **Docker Compose** for orchestration and service management
- **Docker Secrets** for secure credential management
- **Custom Docker bridge network** for isolated service communication
- **Bind mount volumes** for persistent data storage on host filesystem

The main goal is to demonstrate proficiency in containerization, service orchestration, security best practices, and system administration through building each component from minimal base images.

## Instructions

### Prerequisites
- Docker and Docker Compose installed
- Make utility
- Sufficient disk space for volumes in `/home/$USER/data/`
- Appropriate permissions to manage Docker containers and create directories

### Environment Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/aal-hawa/inception.git
   cd inception
   ```

2. **Set up environment variables:**
   Create `srcs/.env` file with the following variables:
   ```bash
   # srcs/.env
   DOMAIN_NAME=your-domain.com
   DB_NAME=wordpress
   DB_USER=wordpress_user
   DB_HOST=mariadb
   MARIADB_USER=mysql
   MARIADB_DATABASE_DIR=/var/lib/mysql
   MARIADB_PLUGIN_DIR=/usr/lib/mariadb/plugin
   MARIADB_PID_FILE=/run/mysqld/mysqld.pid
   DB_ROOT_USER=root
   ```

3. **Configure secrets:**
   The `secrets/` directory contains:
   - `secrets/db_root_password.txt` - MariaDB root password
   - `secrets/db_password.txt` - WordPress database user password  
   - `secrets/credentials.txt` - WordPress admin and user credentials

   Current credentials format:
   ```
   WP_USER=root
   WP_PASS=root
   WP_EMAIL=root@42.fr
   WP_USER2=aal-hawa
   WP_PASS2=aal-hawa
   WP_EMAIL2=aal-hawa@42.fr
   ```

### Compilation and Installation

1. **Build and launch the project:**
   ```bash
   make all
   ```
   This command will:
   - Create necessary directories: `/home/$USER/data/mariadb` and `/home/$USER/data/wordpress`
   - Build all Docker images from Alpine 3.21 base
   - Start all services in dependency order with health checks
   - Initialize MariaDB database and WordPress installation

### Available Make Commands

- `make all` - Build and start all services
- `make create_volumes` - Create host directories for bind mounts
- `make build` - Build Docker images only
- `make up` - Start all services in detached mode
- `make down` - Stop and remove all containers
- `make restart` - Restart all services
- `make clean` - Stop all services (alias for down)
- `make fclean` - Complete cleanup: remove containers, volumes, networks, and host data
- `make re` - Complete rebuild: clean, then build and start

### Accessing the Services

- **Website**: Access via HTTPS at `https://your-domain-name`
- **WordPress Admin**: Access via `/wp-admin` path using credentials from `secrets/credentials.txt`
- **Database**: Accessible only from within the Docker network at `mariadb:3306`

## Resources

### Documentation and References
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [WordPress Codex](https://codex.wordpress.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Alpine Linux Documentation](https://wiki.alpinelinux.org/wiki/Main_Page)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)

### Articles and Tutorials
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Alpine Linux for Docker](https://wiki.alpinelinux.org/wiki/Docker)
- [WordPress with WP-CLI](https://wp-cli.org/)
- [OpenRC Service Management](https://github.com/OpenRC/openrc)

### AI Usage

AI tools were utilized in this project for:

1. **Documentation Generation**: Assisted in creating comprehensive README and documentation files following 42 curriculum standards
2. **Code Review and Optimization**: Helped identify potential improvements in Docker configurations and security practices
3. **Troubleshooting Guidance**: Provided solutions for common Docker networking and volume management issues
4. **Best Practices Research**: Assisted in researching industry standards for container security and Alpine Linux optimization

AI was used as a supplementary tool to enhance project quality and ensure adherence to best practices, while all core implementation and architectural decisions were made independently.

## Project Design Choices

### Docker Usage

This project leverages Docker's containerization capabilities to create isolated, reproducible environments for each service. Each component runs in its own Alpine Linux container with minimal dependencies, ensuring security, efficiency, and maintainability.

### Sources Included

- **Custom Dockerfiles** for each service based on Alpine 3.21:
  - `srcs/requirements/mariadb/Dockerfile` - MariaDB with OpenRC
  - `srcs/requirements/wordpress/Dockerfile` - PHP-FPM 8.3 with WP-CLI
  - `srcs/requirements/nginx/Dockerfile` - Nginx with OpenSSL

- **Configuration files**:
  - `srcs/requirements/nginx/conf/nginx.conf` - Nginx configuration with SSL and PHP-FPM proxy
  - `srcs/requirements/mariadb/conf/mariadb-server.cnf` - MariaDB server configuration
  - `srcs/requirements/wordpress/conf/www.conf` - PHP-FPM pool configuration

- **Shell scripts** for automated container initialization:
  - `srcs/requirements/mariadb/tools/entrypoint.sh` - Database initialization and service startup
  - `srcs/requirements/wordpress/tools/entrypoint.sh` - WordPress download, configuration, and PHP-FPM startup
  - `srcs/requirements/nginx/tools/entrypoint.sh` - SSL certificate generation and Nginx startup

- **Docker Compose** orchestration file for service management with health checks and dependencies

### Technology Comparisons

#### Virtual Machines vs Docker

**Virtual Machines (VMs):**
- **Pros**: Complete OS isolation, stronger security boundaries, can run different OS kernels
- **Cons**: Higher resource usage, slower startup times, larger disk footprint
- **Use Case**: Running applications requiring different OS kernels or maximum isolation

**Docker Containers:**
- **Pros**: Lightweight, fast startup, efficient resource usage, easier scaling
- **Cons**: Shared host kernel, potentially weaker isolation
- **Choice for Project**: Docker was selected for its efficiency, portability, and minimal resource overhead using Alpine Linux base images

#### Secrets vs Environment Variables

**Environment Variables:**
- **Pros**: Simple to implement, widely supported
- **Cons**: Visible in container inspection, stored in plain text, limited security
- **Risk**: Credentials can be exposed through logs or container inspection

**Docker Secrets:**
- **Pros**: Encrypted at rest, only available to authorized services, not stored in container images
- **Cons**: More complex setup, requires file-based implementation in compose
- **Choice for Project**: Docker secrets implemented via files provide superior security for sensitive data like database passwords and WordPress credentials

#### Docker Network vs Host Network

**Host Network:**
- **Pros**: Better performance, no network overhead
- **Cons**: Port conflicts, reduced isolation, security risks
- **Risk**: All services compete for the same ports

**Docker Network (Bridge):**
- **Pros**: Service isolation, automatic DNS resolution, enhanced security
- **Cons**: Slight performance overhead, additional configuration
- **Choice for Project**: Custom bridge network named "inception" provides secure, isolated communication between services while maintaining external access only through Nginx on port 443

#### Docker Volumes vs Bind Mounts

**Bind Mounts:**
- **Pros**: Simple to set up, direct host filesystem access, easier for development
- **Cons**: Host-dependent, potential permission issues, less portable
- **Risk**: Host filesystem structure dependencies

**Docker Volumes:**
- **Pros**: Docker-managed, portable, backup-friendly, better performance
- **Cons**: Less direct host access, requires Docker commands for management
- **Choice for Project**: Bind mounts with local driver provide the best balance of data persistence and direct host access at `/home/$USER/data/` for easy backup and management

### Security Considerations

- **Alpine Linux base images** for minimal attack surface and reduced size
- **Non-root user execution** where possible (nobody for PHP-FPM)
- **Automated SSL certificate generation** using OpenSSL
- **Secret management** through Docker secrets
- **Network isolation** through custom bridge networks
- **Health checks** for service monitoring and automatic recovery
- **Restart policies** for high availability (`unless-stopped`)
- **Database user isolation** with limited privileges

## Features

- **Automated SSL certificate generation** with self-signed certificates using domain name from environment
- **Database initialization** with secure root and user accounts using OpenRC
- **WordPress auto-configuration** with WP-CLI and dual user setup (admin and subscriber)
- **Health monitoring** for all services with custom health checks
- **Persistent data storage** using bind mounts to host filesystem
- **Secure credential management** using Docker secrets
- **Optimized performance** through Alpine Linux and custom configurations
- **Easy deployment** through comprehensive Makefile automation
- **Service dependency management** with proper startup order and health checks