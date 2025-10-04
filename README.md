# ELK Stack

A comprehensive logging and monitoring solution using the ELK Stack (Elasticsearch, Logstash, Kibana). This project provides real-time log analysis, data visualization, and automated data retention policies for microservices logging.

## 🏗️ Architecture Overview

The project consists of a fully containerized ELK stack integrated with three Node.js microservices (Game, Chat and User services) that generate structured logs for comprehensive monitoring and analytics.

### Core Components

- **Elasticsearch**: Search and analytics engine for storing and indexing log data
- **Logstash**: Data processing pipeline for collecting, transforming, and forwarding logs
- **Kibana**: Data visualization and dashboard platform
- **Game Service**: Fastify-based API for game-related events
- **User Service**: Fastify-based API for user authentication and social features
- **Chat Service**: Fastify-based API for chat-related events
- **Setup Service**: Automated configuration for certificates, users, and policies

> **Note**: The current backend services (Game, Chat and User) are example implementations demonstrating the logging capabilities. These will be removed later, leaving a clean, production-ready ELK stack that can be integrated with any application.

## 📁 Project Structure

```
elk-stack/
├── docker-compose.yml          # Main orchestration file
├── Makefile                   # Development shortcuts
├── package.json               # Root dependencies
├── logs/                      # Shared log directory
│   ├── game.log              # Game service logs
│   └── user.log              # User service logs
│   └── chat.log              # Chat service logs
├── elasticsearch/            # Elasticsearch configuration
│   ├── Dockerfile
│   ├── elasticsearch.yml     # Main ES config
│   └── setup-keystore.sh     # AWS S3 credentials setup
├── kibana/                   # Kibana configuration
│   ├── Dockerfile
│   └── kibana.yml            # Kibana settings
├── logstash/                 # Logstash configuration
│   ├── Dockerfile
│   ├── config/
│   │   └── logstash.yml      # Logstash settings
│   └── pipeline/
│       └── logstash.conf     # Log processing pipeline
├── setup/                    # Initial setup and configuration
│   ├── Dockerfile
│   ├── setup.sh              # Automated setup script
│   ├── dashboard.ndjson      # Pre-built Kibana dashboard
│   └── utils/
│       └── instances.yml     # SSL certificate configuration

```

## 🚀 Features

### Security & SSL
- **Full SSL/TLS encryption** between all ELK components
- **Certificate authority (CA)** for secure inter-service communication
- **Automatic certificate generation** for all services
- **User authentication** with role-based access control

### Logging & Monitoring
- **Structured JSON logging** from all microservices
- **Real-time log processing** through Logstash pipelines
- **Centralized log storage** in Elasticsearch
- **Interactive dashboards** in Kibana

### Data Management
- **Automated data retention** policies (30-day retention)
- **S3 backup integration** for long-term storage
- **Snapshot and restore** capabilities
- **Index lifecycle management (ILM)**

### Visualizations & Analytics
Pre-built Kibana dashboards include:
- 📊 **Login Success vs Failure Rate** - OAuth authentication monitoring
- 🥧 **Top OAuth Providers** - Provider usage distribution
- 📈 **Friend Requests Analytics** - Accept/reject patterns
- 🎮 **Game Play Statistics** - Game mode popularity
- 🚫 **User Blocking Analytics** - Most blocked users
- 🔍 **Log Volume by Service** - Microservice activity overview

## 🛠️ Prerequisites

- Docker & Docker Compose
- Make (optional, for convenience commands)
- 4GB+ RAM available for Elasticsearch
- AWS S3 credentials (for backup features)

## ⚙️ Environment Variables

Create a `.env` file in the project root:

```env
# Authentication
ELASTIC_PASSWORD=your_elastic_password
KIBANA_PASSWORD=your_kibana_password
LOGSTASH_PASSWORD=your_logstash_password
KIBANA_ENCRYPTION_KEY=your_32_character_encryption_key

# AWS S3 (for backups)
ACCESS_KEY_ID=your_aws_access_key
SECRET_ACCESS_KEY=your_aws_secret_key
```

## 🚀 Quick Start

### 1. Start the Stack

```bash
# Using Make (recommended)
make all

# Or using Docker Compose directly
docker compose up -d
```

### 2. Access Services

- **Kibana Dashboard**: https://localhost:5601
  - Username: `elastic`
  - Password: `${ELASTIC_PASSWORD}`

## 🔧 Development Commands

```bash
# Start all services
make all

# Stop all services
make down

# Access container shells
make e      # Elasticsearch
make k      # Kibana  
make l      # Logstash

# Clean up (remove containers, images, volumes)
make clean

# Complete cleanup (includes Docker system prune)
make super_clean

# Restart everything
make re
```

## 📈 Log Event Schema

### Game Events
```json
{
  "service": "game",
  "event": "game_play",
  "mode": "remote|local|tournament",
  "time": "2025-01-01T00:00:00.000Z"
}
```

### User Events
```json
{
  "service": "user", 
  "event": "user_login",
  "result": "success|failure",
  "provider": "google|intra|local",
  "time": "2025-01-01T00:00:00.000Z"
}

{
  "service": "user",
  "event": "friend_request", 
  "action": "accept|reject",
  "time": "2025-01-01T00:00:00.000Z"
}

{
  "service": "user",
  "event": "user_block",
  "blocked_user": "username",
  "time": "2025-01-01T00:00:00.000Z"
}
```

## 🗄️ Data Retention & Backup

### Index Lifecycle Management (ILM)
- **Hot phase**: New data actively written and queried
- **Delete phase**: Automatic deletion after 30 day
- **Priority**: Hot indices have priority 100

### Snapshot & Restore
- **Repository**: S3-based (`s3_repo`)
- **Schedule**: Daily snapshots at 23:50
- **Retention**: Managed through S3 lifecycle policies
- **Location**: `s3://trans-elasticsearch/`

## 🔒 Security Features

### SSL/TLS Configuration
- **Certificate Authority**: Self-signed CA for internal communication
- **Service Certificates**: Individual certificates for each service
- **Encrypted Transport**: All inter-service communication encrypted
- **Certificate Management**: Automatic generation and distribution

### User Management
- **Built-in Users**: `elastic`, `kibana_system`, `logstash_author`
- **Custom Roles**: `logstash_writer` with specific index permissions
- **Access Control**: Role-based permissions for different services

## 🐛 Troubleshooting

### Common Issues

**1. Services not starting**
```bash
# Check logs
docker compose logs elasticsearch
docker compose logs kibana
docker compose logs logstash
```

**2. Certificate issues**
```bash
# Restart setup service
docker compose restart setup
```

**3. Memory issues**
```bash
# Increase Docker memory limit to 4GB+
# Or reduce Elasticsearch heap size in elasticsearch/Dockerfile
```

**4. Log files not appearing**
```bash
# Check log directory permissions
ls -la logs/
# Ensure services can write to logs directory
```

### Health Checks
```bash
# Elasticsearch cluster health
curl -k -u elastic:${ELASTIC_PASSWORD} https://localhost:9200/_cluster/health

# Check indices
curl -k -u elastic:${ELASTIC_PASSWORD} https://localhost:9200/_cat/indices

# Kibana status
curl -k -u elastic:${ELASTIC_PASSWORD} https://localhost:5601/api/status
```

## 📚 Additional Resources

- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Logstash Documentation](https://www.elastic.co/guide/en/logstash/current/index.html)
- [Kibana Documentation](https://www.elastic.co/guide/en/kibana/current/index.html)
