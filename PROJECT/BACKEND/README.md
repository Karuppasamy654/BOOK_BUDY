# BookBuddy Backend API

A comprehensive backend API for the BookBuddy hotel management system built with Node.js, Express, and PostgreSQL.

## 🚀 Features

- **User Management**: Registration, authentication, profile management
- **Hotel Management**: CRUD operations, room availability, pricing
- **Food Menu**: Menu management, categories, ratings
- **Booking System**: Reservations, payments, cancellations
- **Staff Management**: Task assignment, attendance tracking
- **Payment Integration**: Razorpay and Stripe support
- **File Upload**: Image upload with Cloudinary
- **Email Notifications**: Automated email sending
- **Admin Dashboard**: Analytics and system management

## 🛠️ Tech Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: PostgreSQL with Sequelize ORM
- **Authentication**: JWT with refresh tokens
- **File Upload**: Multer with Cloudinary
- **Payment**: Razorpay & Stripe
- **Email**: Nodemailer
- **Security**: Helmet, CORS, Rate limiting
- **Validation**: Express-validator

## 📋 Prerequisites

- Node.js 18 or higher
- PostgreSQL 12 or higher
- npm or yarn package manager

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Configuration**
   ```bash
   cp env.example .env
   ```
   
   Update the `.env` file with your configuration:
   ```env
   # Server Configuration
   PORT=5000
   NODE_ENV=development
   
   # PostgreSQL Database Configuration
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=bookbuddy_dev
   DB_USER=postgres
   DB_PASSWORD=your-password
   
   # JWT Configuration
   JWT_SECRET=your-super-secret-jwt-key-here
   JWT_EXPIRE=7d
   
   # Email Configuration
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASS=your-app-password
   
   # Payment Configuration
   RAZORPAY_KEY_ID=your-razorpay-key-id
   RAZORPAY_KEY_SECRET=your-razorpay-key-secret
   STRIPE_SECRET_KEY=your-stripe-secret-key
   
   # Cloudinary Configuration
   CLOUDINARY_CLOUD_NAME=your-cloud-name
   CLOUDINARY_API_KEY=your-api-key
   CLOUDINARY_API_SECRET=your-api-secret
   ```

4. **Start the application**
   ```bash
   # Development mode
   npm run dev
   
   # Production mode
   npm start
   ```

## 🗄️ Database Setup

1. **Install PostgreSQL**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install postgresql postgresql-contrib
   
   # macOS
   brew install postgresql
   
   # Windows
   # Download from https://www.postgresql.org/download/windows/
   ```

2. **Create Database**
   ```bash
   # Connect to PostgreSQL
   psql -U postgres
   
   # Create database
   CREATE DATABASE bookbuddy_dev;
   CREATE DATABASE bookbuddy_test;
   
   # Exit
   \q
   ```

3. **Seed the database**
   ```bash
   npm run seed
   ```

This will create:
- Admin user (admin@bookbuddy.com / admin123)
- Manager users
- Sample hotels
- Food items
- Staff members

## 📚 API Documentation

### Base URL
```
http://localhost:5000/api/v1
```

### Authentication Endpoints

| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| POST | `/auth/register` | Register new user | Public |
| POST | `/auth/login` | User login | Public |
| GET | `/auth/me` | Get current user | Private |
| PUT | `/auth/profile` | Update profile | Private |
| POST | `/auth/forgot-password` | Forgot password | Public |
| POST | `/auth/reset-password/:token` | Reset password | Public |

### Hotel Endpoints

| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | `/hotels` | Get all hotels | Public |
| GET | `/hotels/:id` | Get single hotel | Public |
| POST | `/hotels` | Create hotel | Manager/Admin |
| PUT | `/hotels/:id` | Update hotel | Manager/Admin |
| DELETE | `/hotels/:id` | Delete hotel | Admin |
| POST | `/hotels/:id/rooms/check-availability` | Check room availability | Public |

### Food Endpoints

| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | `/food` | Get all food items | Public |
| GET | `/food/:id` | Get single food item | Public |
| POST | `/food` | Create food item | Manager/Admin |
| PUT | `/food/:id` | Update food item | Manager/Admin |
| DELETE | `/food/:id` | Delete food item | Manager/Admin |
| GET | `/food/popular` | Get popular items | Public |
| GET | `/food/search` | Search food items | Public |

### Booking Endpoints

| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | `/bookings` | Get all bookings | Private |
| GET | `/bookings/:id` | Get single booking | Private |
| POST | `/bookings` | Create booking | Private |
| PUT | `/bookings/:id/status` | Update booking status | Manager/Admin |
| PUT | `/bookings/:id/cancel` | Cancel booking | Private |
| POST | `/bookings/:id/review` | Add review | Private |

### Payment Endpoints

| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| POST | `/payments/razorpay/create-order` | Create Razorpay order | Private |
| POST | `/payments/razorpay/verify` | Verify Razorpay payment | Private |
| POST | `/payments/stripe/create-intent` | Create Stripe intent | Private |
| POST | `/payments/stripe/confirm` | Confirm Stripe payment | Private |
| POST | `/payments/refund` | Process refund | Manager/Admin |

### Staff Endpoints

| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | `/staff` | Get all staff | Manager/Admin |
| GET | `/staff/:id` | Get single staff | Manager/Admin |
| POST | `/staff` | Create staff | Manager/Admin |
| PUT | `/staff/:id` | Update staff | Manager/Admin |
| DELETE | `/staff/:id` | Delete staff | Admin |
| POST | `/staff/:id/tasks` | Assign task | Manager/Admin |
| PUT | `/staff/:id/tasks/:taskId` | Update task | Manager/Admin |

## 🔐 Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```bash
Authorization: Bearer <your-jwt-token>
```

## 📊 Response Format

All API responses follow this format:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    // Response data
  }
}
```

Error responses:

```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    // Validation errors
  ]
}
```

## 🚀 Deployment

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

### Manual PostgreSQL Setup

```bash
# Create database
createdb bookbuddy

# Run migrations
npm run migrate

# Seed database
npm run seed
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage
```

## 📈 Monitoring

The API includes health check endpoint:

```bash
GET /health
```

Returns system status, uptime, and database connection status.

## 🔒 Security Features

- **Helmet**: Security headers
- **CORS**: Cross-origin resource sharing
- **Rate Limiting**: Request rate limiting
- **Input Validation**: Request validation
- **JWT Authentication**: Secure token-based auth
- **Password Hashing**: bcrypt password hashing
- **File Upload Security**: Secure file handling
- **SQL Injection Protection**: Sequelize ORM protection

## 📝 Database Schema

### Core Tables
- **users**: User accounts and profiles
- **hotels**: Hotel information and details
- **food_items**: Food menu items
- **bookings**: Hotel reservations
- **staff**: Staff members and positions
- **tasks**: Staff task assignments
- **attendance**: Staff attendance records
- **reviews**: Hotel and food reviews
- **payments**: Payment transactions

### Key Features
- UUID primary keys for all tables
- JSONB columns for flexible data storage
- Comprehensive indexing for performance
- Foreign key constraints for data integrity
- Timestamps for audit trails

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support, email support@bookbuddy.com or create an issue in the repository.

## 🔄 API Versioning

The API uses URL versioning: `/api/v1/`

## 📱 Frontend Integration

This backend is designed to work with the BookBuddy frontend. The frontend should make requests to the API endpoints and handle the responses according to the documented format.

## 🚀 Performance Optimization

- Database indexing for better query performance
- Image optimization with Cloudinary
- Caching strategies for frequently accessed data
- Rate limiting to prevent abuse
- Compression middleware for response optimization
- Connection pooling for database efficiency