*This project has been created as part of the 42 curriculum by aal-hawa.*

# Inception

## Description

Inception is a comprehensive Docker-based project that sets up a secure, multi-service web hosting environment. This project demonstrates advanced containerization skills by building a complete LEMP stack (Linux, Nginx, MariaDB, PHP) from scratch using Docker containers.

The project creates a fully functional WordPress hosting environment with:
- **Nginx** as a reverse proxy and web server with SSL/TLS support
- **MariaDB** as the database backend
- **WordPress** as the content management system
- **Docker Compose** for orchestration and service management
- **Docker Secrets** for secure credential management
- **Custom Docker networks** for isolated communication
- **Persistent volumes** for data storage and backup

The main goal is to demonstrate proficiency in containerization, service orchestration, security best practices, and system administration through a practical, real-world application.

## Instructions

### Prerequisites
- Docker and Docker Compose installed
- Make utility
- Sufficient disk space for volumes
- Appropriate permissions to manage Docker containers

### Compilation and Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/aal-hawa/inception.git
   cd inception
   ```

2. **Set up credentials:**
   - Edit the files in the `secrets/` directory with your desired passwords
   - Ensure the secrets contain secure, unique passwords

3. **Build and launch the project:**
   ```bash
   make all
   ```
   This command will:
   - Create necessary volumes on the host system
   - Build all Docker images
   - Start all services in detached mode

### Available Make Commands

- `make all` - Build and start all services
- `make build` - Build Docker images only
- `make up` - Start all services in detached mode
- `make down` - Stop and remove all containers
- `make restart` - Restart all services
- `make clean` - Stop all services (alias for down)
- `make fclean` - Complete cleanup: remove containers, volumes, networks, and host data
- `make re` - Complete rebuild: clean, then build and start

### Accessing the Services

- **Website**: Access via HTTPS at your configured domain
- **WordPress Admin**: Access via `/wp-admin` path on your domain
- **Database**: Accessible only from within the Docker network

## Resources

### Documentation and References
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [WordPress Codex](https://codex.wordpress.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)
- [Nginx Documentation](https://nginx.org/en/docs/)

### Articles and Tutorials
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [WordPress Docker Setup Guide](https://wordpress.org/support/article/installing-wordpress-on-docker/)
- [Nginx SSL Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)

### AI Usage

AI tools were utilized in this project for:

1. **Documentation Generation**: Assisted in creating comprehensive README and documentation files following 42 curriculum standards
2. **Code Review and Optimization**: Helped identify potential improvements in Docker configurations and security practices
3. **Troubleshooting Guidance**: Provided solutions for common Docker networking and volume management issues
4. **Best Practices Research**: Assisted in researching industry standards for container security and deployment strategies

AI was used as a supplementary tool to enhance project quality and ensure adherence to best practices, while all core implementation and architectural decisions were made independently.

## Project Design Choices

### Docker Usage

This project leverages Docker's containerization capabilities to create isolated, reproducible environments for each service. Each component (Nginx, MariaDB, WordPress) runs in its own container with minimal dependencies, ensuring security and maintainability.

### Sources Included

- **Custom Dockerfiles** for each service, optimized for security and performance
- **Configuration files** for Nginx, MariaDB, and PHP-FPM
- **Shell scripts** for automated container initialization
- **SSL/TLS certificates** for secure HTTPS communication
- **Docker Compose** orchestration file for service management

### Technology Comparisons

#### Virtual Machines vs Docker

**Virtual Machines (VMs):**
- **Pros**: Complete OS isolation, stronger security boundaries, can run different OS kernels
- **Cons**: Higher resource usage, slower startup times, larger disk footprint
- **Use Case**: Running applications requiring different OS kernels or maximum isolation

**Docker Containers:**
- **Pros**: Lightweight, fast startup, efficient resource usage, easier scaling
- **Cons**: Shared host kernel, potentially weaker isolation
- **Choice for Project**: Docker was selected for its efficiency, portability, and ease of management in this web hosting scenario

#### Secrets vs Environment Variables

**Environment Variables:**
- **Pros**: Simple to implement, widely supported
- **Cons**: Visible in container inspection, stored in plain text, limited security
- **Risk**: Credentials can be exposed through logs or container inspection

**Docker Secrets:**
- **Pros**: Encrypted at rest, only available to authorized services, not stored in container images
- **Cons**: More complex setup, only available in swarm mode (but can be implemented with files)
- **Choice for Project**: Docker secrets implemented via files provide superior security for sensitive data like database passwords

#### Docker Network vs Host Network

**Host Network:**
- **Pros**: Better performance, no network overhead
- **Cons**: Port conflicts, reduced isolation, security risks
- **Risk**: All services compete for the same ports

**Docker Network (Bridge):**
- **Pros**: Service isolation, automatic DNS resolution, enhanced security
- **Cons**: Slight performance overhead, additional configuration
- **Choice for Project**: Custom bridge network provides secure, isolated communication between services while maintaining external access only through Nginx

#### Docker Volumes vs Bind Mounts

**Bind Mounts:**
- **Pros**: Simple to set up, direct host filesystem access
- **Cons**: Host-dependent, potential permission issues, less portable
- **Risk**: Host filesystem structure dependencies

**Docker Volumes:**
- **Pros**: Docker-managed, portable, backup-friendly, better performance
- **Cons**: Less direct host access, requires Docker commands for management
- **Choice for Project**: Named volumes with local driver provide the best balance of data persistence, portability, and backup capabilities

### Security Considerations

- **Minimal base images** to reduce attack surface
- **Non-root user execution** where possible
- **Encrypted communication** via SSL/TLS
- **Secret management** through Docker secrets
- **Network isolation** through custom bridge networks
- **Health checks** for service monitoring
- **Restart policies** for high availability

## Features

- **Automated SSL/TLS setup** with self-signed certificates
- **Database initialization** with secure root and user accounts
- **WordPress auto-configuration** with custom settings
- **Health monitoring** for all services
- **Persistent data storage** across container restarts
- **Secure credential management** using Docker secrets
- **Optimized performance** through custom configurations
- **Easy deployment** through Makefile automation