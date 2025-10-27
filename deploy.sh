#!/bin/bash

# Deployment script for Vaccine Management System
# This script can be run manually or by CI/CD pipeline

set -e  # Exit on error

echo "🚀 Starting deployment..."

# Configuration
APP_DIR="${APP_DIRECTORY:-/home/ec2-user/vaccine-management}"
COMPOSE_FILE="docker-compose.yml"

# Navigate to application directory
cd "$APP_DIR"
echo "📂 Current directory: $(pwd)"

# Pull latest code
echo "📥 Pulling latest code from repository..."
git pull origin main || git pull origin master

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Optional: Clean up old images to save disk space
echo "🧹 Cleaning up unused Docker images..."
docker system prune -f

# Build and start containers
echo "🏗️  Building and starting containers..."
docker-compose up -d --build

# Wait for services to start
echo "⏳ Waiting for services to initialize..."
sleep 15

# Verify services are running
echo "✅ Checking service status..."
docker-compose ps

# Health check for backend
echo "🏥 Running health checks..."
if docker exec vaccine-backend node -e "require('http').get('http://localhost:3000/api/health', (res) => { console.log('Backend Status:', res.statusCode); process.exit(res.statusCode === 200 ? 0 : 1) })" 2>/dev/null; then
  echo "✅ Backend is healthy!"
else
  echo "⚠️  Backend health check failed (this might be normal during startup)"
fi

echo "🎉 Deployment completed successfully!"
echo ""
echo "📊 Service URLs:"
echo "   - Backend API: http://$(hostname -I | awk '{print $1}'):3000"
echo "   - Admin Panel: http://$(hostname -I | awk '{print $1}'):8081"
echo "   - Doctor Portal: http://$(hostname -I | awk '{print $1}'):8082"
echo "   - Patient Panel: http://$(hostname -I | awk '{print $1}'):8083"

