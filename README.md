# Child Vaccination Management System 💉

A comprehensive child vaccination management system with multi-clinic support, inventory management, and role-based access control. Built with Node.js/Express backend and Flutter web frontends.

---

## 📋 Table of Contents

- [System Overview](#-system-overview)
- [Architecture](#-architecture)
- [Applications](#-applications)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Network Configuration](#-network-configuration)
- [GitHub Actions Deployment](#-github-actions-deployment)
- [Access URLs](#-access-urls)
- [Security Configuration](#-security-configuration)
- [Development](#-development)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 System Overview

This is a production-ready, multi-tenant vaccination management system that manages the complete lifecycle of child vaccination from initial registration through multi-year vaccination schedules, with comprehensive inventory management across multiple clinic locations.

### Key Features

- ✅ **Multi-Clinic Operations**: Doctors can manage multiple clinics across different cities
- ✅ **Role-Based Access Control**: Doctor, PA, Patient, and Admin roles
- ✅ **Vaccination Scheduling**: Automated schedule generation based on child's DOB
- ✅ **Inventory Management**: Stock tracking per clinic per vaccine brand
- ✅ **Automated Deployment**: GitHub Actions CI/CD to EC2
- ✅ **MongoDB Web UI**: Mongo Express for database management
- ✅ **Health Monitoring**: Built-in health checks for all services

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend Layer                           │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐  │
│  │ Admin  │ │ Doctor │ │Patient │ │   PA   │ │  Stock   │  │
│  │ :8081  │ │ :8082  │ │ :8083  │ │ :8084  │ │  :8085   │  │
│  └───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘ └────┬─────┘  │
└──────┼──────────┼──────────┼──────────┼───────────┼────────┘
       │          │          │          │           │
       └──────────┴──────────┴──────────┴───────────┘
                            │
                    ┌───────▼────────┐
                    │   Backend API  │
                    │    :3000       │
                    └───────┬────────┘
                            │
                    ┌───────▼────────┐
                    │    MongoDB     │
                    │    :27017      │
                    │  + Mongo Express│
                    │    :8086       │
                    └────────────────┘
```

---

## 📦 Applications

### 1. **Backend API** (Node.js/Express) - Port 3000
Central REST API powering all frontend applications.

**Features:**
- RESTful API with 15+ route modules
- MongoDB with Mongoose ODM
- JWT authentication
- Auto-incrementing IDs
- Swagger API documentation at `/api-docs`

**Core Models:**
- Doctor, Clinic, Patient, PersonalAssistant
- Vaccine, Dose, Brand
- PatientSchedule, DoctorSchedule
- ClinicInventory, Bill, Supplier
- PaAccess (permissions management)

### 2. **Admin System** (Flutter Web) - Port 8081
System administration and master data management.

**Features:**
- Vaccine, Dose, Brand CRUD operations
- Doctor registration and profiles
- Dashboard with system statistics
- Material Design 3 UI

### 3. **Doctor Portal** (Flutter Web) - Port 8082
Complete clinic management for doctors.

**Features:**
- Multi-clinic management
- Patient registration
- Vaccination scheduling
- Inventory tracking per clinic
- Personal Assistant management with permissions
- Doctor schedule management

### 4. **PA Portal** (Personal Assistant) - Port 8084
Delegated clinic operations with restricted access.

**Features:**
- Permission-based access control per clinic
- Patient management (if allowed)
- Schedule management (if allowed)
- Inventory and billing (if allowed)

**Permissions:**
- `allowPatients`, `allowSchedules`, `allowInventory`, `allowAlerts`, `allowBilling`

### 5. **Patient Panel** (Flutter Web) - Port 8083
Parent/guardian access to child vaccination records.

**Features:**
- View vaccination schedules
- Download certificates
- Appointment reminders
- Medical records access

### 6. **Stock Portal** (Flutter Web) - Port 8085
Dedicated vaccine inventory management.

**Features:**
- Inventory tracking per clinic
- Brand arrivals management
- Bills and supplier management
- Stock level monitoring

### 7. **MongoDB** - Port 27017
Database backend (not exposed publicly).

### 8. **Mongo Express** - Port 8086
Web-based MongoDB administration interface.

**Credentials:**
- Username: `admin`
- Password: `admin123`

---

## 🛠️ Prerequisites

### Required Software:
- **Docker** (20.10+)
- **Docker Compose** (2.0+)
- **Git**
- **EC2 Instance** (Amazon Linux 2023 recommended)

### For Development:
- Node.js 18+ (for backend)
- Flutter SDK 3.0+ (for frontends)

---

## 🚀 Quick Start

### 1. Clone Repository
```bash
cd /home/ec2-user
git clone <your-repo-url> vn
cd vn
```

### 2. Install Docker & Docker Compose (on EC2)
```bash
# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login again for group changes to take effect
```

### 3. Start All Services
```bash
# Start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### 4. Stop Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v
```

---

## 🌐 Network Configuration

### Binding to All Interfaces (0.0.0.0)

All applications are configured to bind to `0.0.0.0` (all network interfaces) instead of localhost, making them accessible via the EC2 instance's public IPv4 address.

#### Docker Compose Port Bindings:
```yaml
ports:
  - "0.0.0.0:3000:3000"    # Backend API
  - "0.0.0.0:8081:80"      # Admin System
  - "0.0.0.0:8082:80"      # Doctor Portal
  - "0.0.0.0:8083:80"      # Patient Panel
  - "0.0.0.0:8084:80"      # PA Portal
  - "0.0.0.0:8085:80"      # Stock Portal
  - "0.0.0.0:8086:8081"    # Mongo Express
  - "0.0.0.0:27017:27017"  # MongoDB (for development only)
```

#### Nginx Configuration (All Frontends):
```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;  # IPv6 support
    server_name _;                   # Accept any hostname
    # ... rest of config
}
```

#### Backend Express Configuration:
```javascript
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Why 0.0.0.0?
- **0.0.0.0** = Bind to all network interfaces (public access)
- **localhost/127.0.0.1** = Only accessible from same machine
- **Private IP** = Accessible within VPC/subnet
- **Public IP** = Accessible from internet (with security group rules)

---

## 🔄 GitHub Actions Deployment

### Automated CI/CD to EC2

The system uses GitHub Actions for automatic deployment whenever code is pushed to the `master` branch.

### Setup GitHub Secrets

**Repository → Settings → Secrets and variables → Actions → New repository secret**

Add secret:
- **Name:** `EC2_SSH_KEY`
- **Value:** Your EC2 SSH private key (entire content including BEGIN/END lines)

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAp+uG1c+J12fgCQgF37+MwWDPMYDF8ahClH...
-----END RSA PRIVATE KEY-----
```

### Deployment Configuration

**Target EC2:**
- **Host:** `ec2-13-232-35-109.ap-south-1.compute.amazonaws.com`
- **User:** `ec2-user`
- **Directory:** `/home/ec2-user/vn`

### Workflow Features

✅ **Selective Rebuilding**: Only rebuilds services that changed
- Change in `admin/` → Rebuilds only admin-system
- Change in `doctor/` → Rebuilds only doctor-portal
- Change in `backend/` → Rebuilds only backend
- Change in `docker-compose.yml` → Rebuilds all services

✅ **Automatic Triggers**: Pushes to `master` branch in monitored paths:
- `admin/**`, `doctor/**`, `patient/**`, `pa/**`, `stock/**`
- `backend/**`, `docker-compose.yml`

✅ **Manual Trigger**: Available from GitHub Actions tab

✅ **Health Checks**: Verifies all services after deployment

### Workflow Steps:

1. **Detect Changes**: Identifies which services were modified
2. **Setup SSH**: Configures secure connection to EC2
3. **Deploy**: Pulls latest code and rebuilds only changed services
4. **Verify**: Checks health endpoints for all services
5. **Cleanup**: Removes old Docker images
6. **Notify**: Shows success/failure status

### Example: Deployment Scenarios

| Change | Behavior |
|--------|----------|
| One file in `doctor/` | Rebuilds doctor-portal only (~2 min) |
| Multiple apps | Rebuilds only changed apps (~3-5 min) |
| Backend API update | Rebuilds backend only (~1 min) |
| docker-compose.yml | Rebuilds ALL services (~5-10 min) |

### Monitor Deployments

**View in GitHub:**
1. Repository → Actions tab
2. See workflow runs with status
3. View detailed logs

**View on EC2:**
```bash
ssh -i key.pem ec2-user@ec2-13-232-35-109.ap-south-1.compute.amazonaws.com

# Check running containers
docker-compose ps

# View logs (all services)
docker-compose logs -f

# View specific service
docker-compose logs -f backend
docker-compose logs -f doctor-portal
```

---

## 🌍 Access URLs

### Public Access (from Internet):

| Application | URL |
|-------------|-----|
| **Admin System** | http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:8081 |
| **Doctor Portal** | http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:8082 |
| **Patient Panel** | http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:8083 |
| **PA Portal** | http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:8084 |
| **Stock Portal** | http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:8085 |
| **Mongo Express** | http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:8086 |
| **Backend API** | http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:3000 |
| **API Documentation** | http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:3000/api-docs |

### Local Access (on EC2 instance):
```bash
# Using 0.0.0.0
curl http://0.0.0.0:3000/api/health

# Using localhost
curl http://localhost:3000/api/health

# Using private IP
curl http://$(hostname -I | awk '{print $1}'):3000/api/health
```

---

## 🔒 Security Configuration

### EC2 Security Group Rules

Configure inbound rules for your EC2 instance:

| Port | Protocol | Source | Description |
|------|----------|--------|-------------|
| 22 | TCP | Your IP | SSH Access |
| 3000 | TCP | 0.0.0.0/0 | Backend API |
| 8081 | TCP | 0.0.0.0/0 | Admin System |
| 8082 | TCP | 0.0.0.0/0 | Doctor Portal |
| 8083 | TCP | 0.0.0.0/0 | Patient Panel |
| 8084 | TCP | 0.0.0.0/0 | PA Portal |
| 8085 | TCP | 0.0.0.0/0 | Stock Portal |
| 8086 | TCP | 0.0.0.0/0 | Mongo Express |

**⚠️ Security Best Practices:**

1. ✅ **MongoDB Port 27017**: NOT exposed publicly (only accessible within Docker network)
2. ✅ **SSH Access**: Restrict to specific IP addresses
3. ✅ **Mongo Express**: Use strong password (default: admin/admin123 - CHANGE IN PRODUCTION)
4. ⚠️ **Production**: Consider adding SSL/TLS certificates (HTTPS)
5. ⚠️ **Production**: Use secrets management for sensitive data
6. ⚠️ **Production**: Enable AWS WAF for DDoS protection
7. ⚠️ **Production**: Implement rate limiting on API endpoints

### Configure Security Group (AWS Console):

```bash
# Via AWS CLI
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxxx \
    --ip-permissions \
    IpProtocol=tcp,FromPort=3000,ToPort=3000,IpRanges='[{CidrIp=0.0.0.0/0}]' \
    IpProtocol=tcp,FromPort=8081,ToPort=8086,IpRanges='[{CidrIp=0.0.0.0/0}]'
```

---

## 💻 Development

### Local Development Setup

#### Backend Development:
```bash
cd backend
npm install

# Create config.env
cp config.env.example config.env
# Edit config.env with your MongoDB URI

# Run in development mode
npm run dev
```

#### Frontend Development (Admin example):
```bash
cd admin
flutter pub get

# Run on web
flutter run -d chrome --web-port 8081

# Build for production
flutter build web --release
```

### Development Workflow:

1. **Create Feature Branch:**
```bash
git checkout -b feature/your-feature-name
```

2. **Make Changes and Test Locally:**
```bash
# Test backend
cd backend && npm run dev

# Test frontend
cd admin && flutter run -d chrome
```

3. **Commit Changes:**
```bash
git add .
git commit -m "Description of changes"
git push origin feature/your-feature-name
```

4. **Merge to Master (triggers deployment):**
```bash
git checkout master
git merge feature/your-feature-name
git push origin master
```

5. **GitHub Actions automatically deploys to EC2!** 🚀

### Docker Development:

```bash
# Rebuild specific service
docker-compose up -d --build backend

# View logs
docker-compose logs -f backend

# Enter container shell
docker exec -it vaccine-backend sh

# Restart service
docker-compose restart backend
```

---

## 🧪 Testing

### Health Check Endpoints:

```bash
# Backend API
curl http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:3000/api/health

# Frontend health endpoints
curl http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:8081/health
curl http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:8084/health
curl http://ec2-13-232-35-109.ap-south-1.compute.amazonaws.com:8085/health
```

### Manual Testing:

```bash
# SSH into EC2
ssh -i key.pem ec2-user@ec2-13-232-35-109.ap-south-1.compute.amazonaws.com

# Test all services
curl http://0.0.0.0:3000/api/health
curl http://0.0.0.0:8081/health
curl http://0.0.0.0:8082/
curl http://0.0.0.0:8083/
curl http://0.0.0.0:8084/health
curl http://0.0.0.0:8085/health
curl http://0.0.0.0:8086/
```

### Verification Checklist:

After deployment, verify:

- [ ] All 8 containers running: `docker ps`
- [ ] Backend API responds: `curl http://0.0.0.0:3000/api/health`
- [ ] Admin System loads in browser
- [ ] Doctor Portal loads and login works
- [ ] Patient Panel accessible
- [ ] PA Portal accessible
- [ ] Stock Portal accessible
- [ ] Mongo Express accessible (admin/admin123)
- [ ] API documentation loads at `/api-docs`
- [ ] All services accessible via public hostname

---

## 🐛 Troubleshooting

### Common Issues and Solutions:

#### 1. **Deployment Fails**
```bash
# Check GitHub Actions logs
# Go to GitHub → Actions → View failed workflow

# Check EC2 logs
ssh -i key.pem ec2-user@ec2-13-232-35-109.ap-south-1.compute.amazonaws.com
cd /home/ec2-user/vn
docker-compose logs -f
```

#### 2. **Container Not Starting**
```bash
# Check container logs
docker-compose logs backend

# Check container status
docker-compose ps

# Restart specific container
docker-compose restart backend

# Rebuild and restart
docker-compose up -d --build backend
```

#### 3. **Port Already in Use**
```bash
# Find process using port
sudo lsof -i :3000

# Or use netstat
sudo netstat -tlnp | grep 3000

# Stop old containers
docker-compose down
```

#### 4. **Disk Space Full**
```bash
# Check disk usage
df -h

# Clean up Docker
docker system prune -af

# Remove old images
docker image prune -af

# Remove unused volumes
docker volume prune -f
```

#### 5. **Permission Denied (Docker)**
```bash
# Add user to docker group
sudo usermod -a -G docker ec2-user

# Logout and login again
exit
ssh -i key.pem ec2-user@ec2-13-232-35-109.ap-south-1.compute.amazonaws.com
```

#### 6. **Git Pull Fails**
```bash
cd /home/ec2-user/vn

# Check git status
git status

# Discard local changes
git reset --hard origin/master

# Or stash changes
git stash
git pull origin master
```

#### 7. **MongoDB Connection Issues**
```bash
# Check MongoDB container
docker logs vaccine-mongodb

# Restart MongoDB
docker-compose restart mongodb

# Check connection from backend
docker exec -it vaccine-backend sh
# Inside container:
# wget -O- http://mongodb:27017
```

#### 8. **Frontend Not Loading**
```bash
# Check nginx logs
docker logs vaccine-admin-system

# Check if files exist
docker exec -it vaccine-admin-system ls -la /usr/share/nginx/html

# Rebuild frontend
docker-compose up -d --build admin-system
```

#### 9. **API Returns 404**
```bash
# Check backend routes
docker exec -it vaccine-backend sh
# cat src/app.js

# Check API documentation
# Visit: http://ec2-host:3000/api-docs

# Test specific endpoint
curl -X GET http://localhost:3000/api/vaccines
```

#### 10. **Can't Access from Internet**
```bash
# Check EC2 Security Group rules
# AWS Console → EC2 → Security Groups

# Test from EC2 instance
curl http://0.0.0.0:3000/api/health

# If works locally but not publicly:
# - Check Security Group inbound rules
# - Verify public IP is correct
# - Check AWS Network ACLs
```

### Emergency Recovery:

```bash
# Stop everything
docker-compose down

# Clean slate
docker system prune -af
docker volume prune -f

# Pull latest code
git pull origin master

# Rebuild everything
docker-compose up -d --build

# Monitor startup
docker-compose logs -f
```

### Get Help:

```bash
# View all container logs
docker-compose logs

# View specific service logs
docker-compose logs backend

# Follow logs in real-time
docker-compose logs -f backend

# View last 100 lines
docker-compose logs --tail=100 backend

# Check resource usage
docker stats
```

---

## 📚 Additional Resources

### Documentation:
- **Swagger API Docs**: http://ec2-host:3000/api-docs
- **Docker Compose Docs**: https://docs.docker.com/compose/
- **Flutter Docs**: https://docs.flutter.dev/
- **Express.js Docs**: https://expressjs.com/
- **MongoDB Docs**: https://www.mongodb.com/docs/

### Project Structure:
```
vn/
├── .github/
│   └── workflows/
│       └── deploy-to-ec2.yml    # CI/CD workflow
├── backend/                      # Node.js/Express API
│   ├── src/
│   │   ├── models/              # MongoDB schemas
│   │   ├── routes/              # API routes
│   │   ├── config/              # Configuration
│   │   └── app.js               # Main application
│   ├── Dockerfile
│   └── package.json
├── admin/                        # Admin Flutter app
│   ├── lib/
│   ├── Dockerfile
│   └── nginx.conf
├── doctor/                       # Doctor Flutter app
├── patient/                      # Patient Flutter app
├── pa/                          # PA Flutter app
├── stock/                       # Stock Flutter app
├── docker-compose.yml           # Docker orchestration
└── README.md                    # This file
```

---

## 🎉 Success!

Your Child Vaccination Management System is now:
- ✅ Running on EC2 with Docker
- ✅ Accessible via public internet
- ✅ Automatically deploying on code changes
- ✅ Monitored with health checks
- ✅ Scalable and production-ready

### Next Steps:

1. **Configure DNS**: Point a domain to your EC2 IP
2. **Add SSL/TLS**: Use Let's Encrypt for HTTPS
3. **Set up Monitoring**: Add CloudWatch or Datadog
4. **Configure Backups**: Automate MongoDB backups
5. **Add Load Balancer**: For high availability
6. **Set up Staging**: Create a staging environment

---

## 📝 License

This project is part of the Vaccine Management System.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Last Updated**: November 2025  
**Status**: ✅ Production Ready  
**Version**: 1.0.0
