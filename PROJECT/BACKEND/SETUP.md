# BookBuddy Backend Setup Guide

This guide will help you set up the complete BookBuddy backend API system.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ installed
- MongoDB 4.4+ running
- Git installed

### 1. Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd backend

# Install dependencies
npm install

# Copy environment file
cp env.example .env
```

### 2. Environment Configuration

Edit the `.env` file with your configuration:

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/bookbuddy

# JWT Secrets (Generate strong secrets)
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRE=7d
JWT_REFRESH_SECRET=your-refresh-secret-key-here
JWT_REFRESH_EXPIRE=30d

# Email Configuration (Gmail example)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
EMAIL_FROM=BookBuddy <noreply@bookbuddy.com>

# Payment Gateways
RAZORPAY_KEY_ID=your-razorpay-key-id
RAZORPAY_KEY_SECRET=your-razorpay-key-secret
STRIPE_SECRET_KEY=your-stripe-secret-key
STRIPE_PUBLISHABLE_KEY=your-stripe-publishable-key

# Cloudinary (for image uploads)
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

### 3. Database Setup

```bash
# Start MongoDB (if not running)
mongod

# Seed the database with sample data
npm run seed
```

### 4. Start the Application

```bash
# Development mode
npm run dev

# Production mode
npm start
```

The API will be available at `http://localhost:5000`

## 🔧 Advanced Setup

### Using Docker

```bash
# Build and run with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f api
```

### Using PM2 (Production)

```bash
# Install PM2 globally
npm install -g pm2

# Start with PM2
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save
pm2 startup
```

## 📊 Database Seeding

The seed script creates:

- **Admin User**: admin@bookbuddy.com / admin123
- **Manager Users**: rajesh@bookbuddy.com / manager123
- **Customer Users**: amit@example.com / customer123
- **Sample Hotels**: Taj Coromandel, ITC Grand Chola
- **Food Items**: Various breakfast, lunch, dinner items
- **Staff Members**: Sample staff with different roles

## 🔐 Default Login Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@bookbuddy.com | admin123 |
| Manager | rajesh@bookbuddy.com | manager123 |
| Customer | amit@example.com | customer123 |

## 🛠️ API Testing

### Using Postman

1. Import the API collection (if available)
2. Set base URL: `http://localhost:5000/api/v1`
3. Test authentication endpoints first
4. Use the returned JWT token for protected routes

### Using cURL

```bash
# Register a new user
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "password": "password123",
    "phone": "9876543210"
  }'

# Login
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

## 🔧 Configuration Options

### Rate Limiting
- API routes: 10 requests/second
- Auth routes: 5 requests/second
- Configurable in `server.js`

### File Upload
- Max file size: 5MB
- Allowed types: Images (JPEG, PNG, WebP)
- Storage: Local filesystem or Cloudinary

### Email Templates
- Welcome emails
- Password reset
- Booking confirmations
- Customizable in `routes/auth.js`

## 🚀 Deployment Options

### 1. Traditional Server Deployment

```bash
# On your server
git clone <your-repo>
cd backend
npm install
npm run build
pm2 start ecosystem.config.js --env production
```

### 2. Docker Deployment

```bash
# Build image
docker build -t bookbuddy-api .

# Run container
docker run -p 5000:5000 \
  -e MONGODB_URI=mongodb://your-db-url \
  -e JWT_SECRET=your-secret \
  bookbuddy-api
```

### 3. Docker Compose (Full Stack)

```bash
# Start all services
docker-compose up -d

# Services included:
# - MongoDB
# - Redis
# - API
# - Nginx (reverse proxy)
```

## 📈 Monitoring & Logs

### Health Check
```bash
curl http://localhost:5000/health
```

### PM2 Monitoring
```bash
# View status
pm2 status

# View logs
pm2 logs bookbuddy-api

# Monitor resources
pm2 monit
```

### Docker Logs
```bash
# View API logs
docker-compose logs -f api

# View all logs
docker-compose logs -f
```

## 🔒 Security Checklist

- [ ] Change default JWT secrets
- [ ] Use strong database passwords
- [ ] Enable HTTPS in production
- [ ] Configure CORS properly
- [ ] Set up rate limiting
- [ ] Use environment variables for secrets
- [ ] Enable database authentication
- [ ] Set up proper file permissions

## 🐛 Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   ```bash
   # Check if MongoDB is running
   mongosh
   # Or
   mongo
   ```

2. **Port Already in Use**
   ```bash
   # Find process using port 5000
   lsof -i :5000
   # Kill the process
   kill -9 <PID>
   ```

3. **Permission Denied (Docker)**
   ```bash
   # Fix file permissions
   sudo chown -R $USER:$USER .
   ```

4. **Email Not Sending**
   - Check Gmail app password
   - Verify SMTP settings
   - Check firewall settings

### Debug Mode

```bash
# Enable debug logging
DEBUG=* npm run dev

# Or specific modules
DEBUG=express:* npm run dev
```

## 📚 API Documentation

Once the server is running, you can access:

- **Health Check**: `GET /health`
- **API Base**: `GET /api/v1`
- **Authentication**: `POST /api/v1/auth/login`
- **Hotels**: `GET /api/v1/hotels`
- **Food**: `GET /api/v1/food`

## 🔄 Updates & Maintenance

### Database Migrations
```bash
# Backup database
mongodump --db bookbuddy --out backup/

# Restore database
mongorestore --db bookbuddy backup/bookbuddy/
```

### Application Updates
```bash
# Pull latest changes
git pull origin main

# Install new dependencies
npm install

# Restart application
pm2 restart bookbuddy-api
```

## 📞 Support

If you encounter any issues:

1. Check the logs: `pm2 logs` or `docker-compose logs`
2. Verify environment variables
3. Ensure MongoDB is running
4. Check network connectivity
5. Review the troubleshooting section above

For additional help, create an issue in the repository or contact the development team.
