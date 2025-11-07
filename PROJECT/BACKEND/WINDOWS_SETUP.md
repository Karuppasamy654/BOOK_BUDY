# BookBuddy Backend - Windows Setup Guide

This guide will help you set up the BookBuddy backend on Windows with PostgreSQL.

## 🚀 Prerequisites

### 1. Install Node.js
1. Download Node.js from [https://nodejs.org/](https://nodejs.org/)
2. Choose the LTS version (18.x or higher)
3. Run the installer and follow the setup wizard
4. Verify installation:
   ```cmd
   node --version
   npm --version
   ```

### 2. Install PostgreSQL
1. Download PostgreSQL from [https://www.postgresql.org/download/windows/](https://www.postgresql.org/download/windows/)
2. Run the installer
3. During installation:
   - Set a password for the `postgres` user (remember this!)
   - Choose port 5432 (default)
   - Select components: PostgreSQL Server, pgAdmin 4, Stack Builder
4. Complete the installation

### 3. Install Git (Optional but recommended)
1. Download Git from [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Run the installer with default settings

## 🗄️ Database Setup

### 1. Start PostgreSQL Service
1. Open **Services** (Win + R, type `services.msc`)
2. Find **postgresql-x64-15** (or similar)
3. Right-click and select **Start** (if not already running)

### 2. Create Database using pgAdmin
1. Open **pgAdmin 4** from Start Menu
2. Connect to PostgreSQL server:
   - Host: localhost
   - Port: 5432
   - Username: postgres
   - Password: (the password you set during installation)
3. Right-click on **Databases** → **Create** → **Database**
4. Create two databases:
   - Name: `bookbuddy_dev`
   - Name: `bookbuddy_test`

### 3. Alternative: Create Database using Command Line
1. Open **Command Prompt** as Administrator
2. Navigate to PostgreSQL bin directory:
   ```cmd
   cd "C:\Program Files\PostgreSQL\15\bin"
   ```
3. Create databases:
   ```cmd
   createdb -U postgres bookbuddy_dev
   createdb -U postgres bookbuddy_test
   ```

## 🔧 Project Setup

### 1. Navigate to Project Directory
```cmd
cd "C:\Users\bsaru\OneDrive\Documents\db project\backend"
```

### 2. Install Dependencies
```cmd
npm install
```

### 3. Environment Configuration
1. Copy the environment file:
   ```cmd
   copy env.example .env
   ```
2. Edit `.env` file with your settings:
   ```env
   # Server Configuration
   PORT=5000
   NODE_ENV=development
   FRONTEND_URL=http://localhost:3000

   # PostgreSQL Database Configuration
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=bookbuddy_dev
   DB_USER=postgres
   DB_PASSWORD=your-postgres-password
   DB_SSL=false

   # JWT Configuration
   JWT_SECRET=your-super-secret-jwt-key-here
   JWT_EXPIRE=7d
   JWT_REFRESH_SECRET=your-refresh-secret-key-here
   JWT_REFRESH_EXPIRE=30d

   # Email Configuration
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASS=your-app-password
   EMAIL_FROM=BookBuddy <noreply@bookbuddy.com>

   # Payment Gateway Configuration
   RAZORPAY_KEY_ID=your-razorpay-key-id
   RAZORPAY_KEY_SECRET=your-razorpay-key-secret
   STRIPE_SECRET_KEY=your-stripe-secret-key

   # Cloudinary Configuration
   CLOUDINARY_CLOUD_NAME=your-cloud-name
   CLOUDINARY_API_KEY=your-api-key
   CLOUDINARY_API_SECRET=your-api-secret
   ```

### 4. Seed the Database
```cmd
npm run seed
```

### 5. Start the Server
```cmd
# Development mode
npm run dev

# Production mode
npm start
```

## 🐳 Docker Setup (Alternative)

### 1. Install Docker Desktop
1. Download Docker Desktop from [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
2. Install and restart your computer
3. Start Docker Desktop

### 2. Run with Docker Compose
```cmd
# Navigate to backend directory
cd "C:\Users\bsaru\OneDrive\Documents\db project\backend"

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f api
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. PostgreSQL Connection Error
**Error**: `ECONNREFUSED` or `password authentication failed`

**Solutions**:
- Check if PostgreSQL service is running:
  ```cmd
  # Open Services (Win + R, type services.msc)
  # Find postgresql service and start it
  ```
- Verify password in `.env` file
- Check if PostgreSQL is listening on port 5432:
  ```cmd
  netstat -an | findstr 5432
  ```

#### 2. Node.js Module Not Found
**Error**: `Cannot find module 'sequelize'`

**Solutions**:
```cmd
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rmdir /s node_modules
del package-lock.json
npm install
```

#### 3. Permission Denied Errors
**Error**: `EACCES: permission denied`

**Solutions**:
- Run Command Prompt as Administrator
- Check file permissions
- Ensure antivirus isn't blocking the process

#### 4. Port Already in Use
**Error**: `EADDRINUSE: address already in use :::5000`

**Solutions**:
```cmd
# Find process using port 5000
netstat -ano | findstr :5000

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or change port in .env file
PORT=5001
```

#### 5. Database Connection Timeout
**Error**: `Connection timeout`

**Solutions**:
- Check PostgreSQL configuration in `postgresql.conf`
- Verify firewall settings
- Ensure PostgreSQL is accepting connections

### Windows-Specific Commands

#### Check PostgreSQL Status
```cmd
# Check if PostgreSQL is running
sc query postgresql-x64-15

# Start PostgreSQL service
net start postgresql-x64-15

# Stop PostgreSQL service
net stop postgresql-x64-15
```

#### Check Port Usage
```cmd
# Check if port 5000 is in use
netstat -ano | findstr :5000

# Check if port 5432 is in use
netstat -ano | findstr :5432
```

#### Environment Variables
```cmd
# Set environment variable temporarily
set NODE_ENV=development

# Check environment variables
echo %NODE_ENV%
```

## 🚀 Development Workflow

### 1. Start Development Server
```cmd
npm run dev
```

### 2. View Logs
```cmd
# If using PM2
pm2 logs bookbuddy-api

# If using Docker
docker-compose logs -f api
```

### 3. Database Operations
```cmd
# Connect to PostgreSQL
psql -U postgres -d bookbuddy_dev

# Run SQL commands
\dt  # List tables
\q   # Quit
```

### 4. Reset Database
```cmd
# Drop and recreate database
npm run db:reset

# Or manually
psql -U postgres -c "DROP DATABASE IF EXISTS bookbuddy_dev;"
psql -U postgres -c "CREATE DATABASE bookbuddy_dev;"
npm run seed
```

## 📊 Monitoring

### 1. Health Check
```cmd
# Test API health
curl http://localhost:5000/health

# Or use PowerShell
Invoke-RestMethod -Uri "http://localhost:5000/health"
```

### 2. Database Monitoring
```cmd
# Connect to database
psql -U postgres -d bookbuddy_dev

# Check table sizes
SELECT schemaname,tablename,pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables WHERE schemaname='public';

# Check active connections
SELECT * FROM pg_stat_activity;
```

## 🔒 Security Considerations

### 1. Firewall Configuration
- Allow port 5000 for API access
- Allow port 5432 for PostgreSQL (if needed externally)
- Configure Windows Firewall rules

### 2. Database Security
- Change default PostgreSQL password
- Create specific database users (not just postgres)
- Enable SSL for production

### 3. Environment Security
- Never commit `.env` file to version control
- Use strong passwords and secrets
- Regularly update dependencies

## 📝 Useful Commands

### Package Management
```cmd
# Install dependencies
npm install

# Install specific package
npm install express

# Update dependencies
npm update

# Check for vulnerabilities
npm audit
```

### Database Commands
```cmd
# Backup database
pg_dump -U postgres bookbuddy_dev > backup.sql

# Restore database
psql -U postgres bookbuddy_dev < backup.sql

# List databases
psql -U postgres -l
```

### Git Commands (if using Git)
```cmd
# Initialize repository
git init

# Add files
git add .

# Commit changes
git commit -m "Initial commit"

# Check status
git status
```

## 🆘 Getting Help

### 1. Check Logs
```cmd
# Application logs
npm run dev

# Database logs (in PostgreSQL data directory)
# Usually: C:\Program Files\PostgreSQL\15\data\log\
```

### 2. Common Resources
- [PostgreSQL Windows Documentation](https://www.postgresql.org/docs/current/install-windows.html)
- [Node.js Windows Installation](https://nodejs.org/en/download/)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/)

### 3. Support
- Check the main README.md for general setup
- Review error messages carefully
- Ensure all prerequisites are installed
- Verify environment variables are correct

## ✅ Verification

After setup, verify everything is working:

1. **Database Connection**: Check if tables are created
2. **API Health**: Visit `http://localhost:5000/health`
3. **Authentication**: Test login endpoint
4. **Database Seeding**: Verify sample data is created

Your BookBuddy backend should now be running successfully on Windows! 🎉
