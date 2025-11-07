# BookBuddy Backend API - Replit Setup

## Project Overview
BookBuddy is a comprehensive hotel management system backend API built with Node.js, Express, and PostgreSQL/SQLite. This is a backend-only API project with no frontend component.

## Current Status
- ✅ Backend API server running on port 3000
- ✅ SQLite database configured (default)
- ✅ All route stubs created
- ⚠️ Routes return placeholder responses - full implementation needed
- ⚠️ Database models not yet implemented
- ⚠️ Authentication and authorization middleware not implemented

## Project Structure
```
.
├── config/
│   └── database.js          # Database configuration (SQLite/PostgreSQL)
├── middleware/
│   └── errorHandler.js      # Error handling middleware
├── models/
│   └── index.js            # Database models (empty - needs implementation)
├── routes/
│   ├── admin.js            # Admin endpoints
│   ├── auth.js             # Authentication endpoints
│   ├── bookings.js         # Booking management
│   ├── food.js             # Food menu management
│   ├── hotels.js           # Hotel management
│   ├── payments.js         # Payment processing
│   ├── staff.js            # Staff management
│   └── users.js            # User management
├── scripts/                # Database seeding scripts (to be created)
├── server.js               # Main application entry point
└── package.json            # Project dependencies
```

## Technology Stack
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: SQLite (default) or PostgreSQL (with DATABASE_URL)
- **ORM**: Sequelize
- **Authentication**: JWT (not yet implemented)
- **Security**: Helmet, CORS, Rate limiting
- **File Upload**: Multer + Cloudinary (not yet configured)
- **Payments**: Razorpay & Stripe (not yet configured)

## Environment Configuration

### Required Secrets (use Replit Secrets UI)
The application reads configuration from environment variables. For local development, you can create a `.env` file, but in Replit, use the Secrets tab to configure:

**Basic Configuration:**
- `NODE_ENV` - Set to 'development' or 'production'
- `PORT` - Server port (defaults to 3000, auto-set by Replit)

**Database Configuration (PostgreSQL - optional):**
- `DATABASE_URL` - Full PostgreSQL connection string (if not set, uses SQLite)
- `DB_SSL` - Set to 'true' for SSL connections

**JWT Configuration (when implementing auth):**
- `JWT_SECRET` - Secret key for JWT tokens
- `JWT_EXPIRE` - Token expiration time (e.g., '7d')
- `JWT_REFRESH_SECRET` - Secret for refresh tokens
- `JWT_REFRESH_EXPIRE` - Refresh token expiration (e.g., '30d')

**Email Configuration (when implementing notifications):**
- `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_USER`, `EMAIL_PASS`, `EMAIL_FROM`

**Payment Gateways (when implementing payments):**
- Razorpay: `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET`
- Stripe: `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, `STRIPE_WEBHOOK_SECRET`

**Cloudinary (when implementing file uploads):**
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`

## Database Setup

### SQLite (Current Default)
The application uses SQLite by default with a local `database.sqlite` file. No additional setup required.

### PostgreSQL (Optional)
To use PostgreSQL instead:
1. Set the `DATABASE_URL` environment variable to your PostgreSQL connection string
2. Format: `postgresql://username:password@host:port/database`
3. The application automatically detects and switches to PostgreSQL

## API Endpoints

Base URL: `http://localhost:3000/api/v1`

### Health Check
- `GET /health` - Returns server status and database connection

### Authentication (Stub)
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `GET /api/v1/auth/me` - Get current user
- `PUT /api/v1/auth/profile` - Update profile
- `POST /api/v1/auth/forgot-password` - Request password reset
- `POST /api/v1/auth/reset-password/:token` - Reset password

### Hotels (Stub)
- `GET /api/v1/hotels` - Get all hotels
- `GET /api/v1/hotels/:id` - Get single hotel
- `POST /api/v1/hotels` - Create hotel
- `PUT /api/v1/hotels/:id` - Update hotel
- `DELETE /api/v1/hotels/:id` - Delete hotel
- `POST /api/v1/hotels/:id/rooms/check-availability` - Check room availability

### Food (Stub)
- `GET /api/v1/food` - Get all food items
- `GET /api/v1/food/:id` - Get single food item
- `POST /api/v1/food` - Create food item
- `PUT /api/v1/food/:id` - Update food item
- `DELETE /api/v1/food/:id` - Delete food item

### Bookings (Stub)
- `GET /api/v1/bookings` - Get all bookings
- `POST /api/v1/bookings` - Create booking
- `PUT /api/v1/bookings/:id/cancel` - Cancel booking

### Staff (Stub)
- `GET /api/v1/staff` - Get all staff
- `POST /api/v1/staff` - Create staff member
- `POST /api/v1/staff/:id/tasks` - Assign task

### Payments (Stub)
- `POST /api/v1/payments/razorpay/create-order` - Create Razorpay order
- `POST /api/v1/payments/stripe/create-intent` - Create Stripe payment intent

### Users (Stub)
- `GET /api/v1/users` - Get all users
- `GET /api/v1/users/:id` - Get single user

### Admin (Stub)
- `GET /api/v1/admin/dashboard` - Get dashboard statistics
- `GET /api/v1/admin/analytics` - Get analytics data

## Running the Project

The project is configured to run automatically in Replit using the "Backend API Server" workflow, which executes:
```bash
npm run dev
```

This starts the server with nodemon for auto-reload on file changes.

## Development Workflow

1. **Server runs automatically** when you open the Repl
2. **Check logs** in the Console tab to verify server started successfully
3. **Test endpoints** using the health check: `curl http://localhost:3000/health`
4. **Make changes** to code - server auto-restarts with nodemon
5. **Test API** using tools like Postman, curl, or Thunder Client

## Next Steps for Full Implementation

1. **Implement Database Models** in `models/` directory:
   - User, Hotel, Room, Booking, FoodItem, Staff, Task, Payment, Review models
   - Define relationships between models
   - Add validation and constraints

2. **Implement Authentication**:
   - JWT token generation and validation
   - Password hashing with bcrypt
   - Auth middleware for protected routes
   - Role-based access control (Customer, Staff, Manager, Admin)

3. **Implement Route Controllers**:
   - Replace placeholder responses with actual business logic
   - Add input validation using express-validator
   - Implement error handling
   - Add pagination, filtering, and sorting

4. **Database Seeding**:
   - Create seed scripts for sample data
   - Add sample hotels, rooms, food items, users

5. **File Upload Integration**:
   - Configure Cloudinary for image uploads
   - Implement multer middleware
   - Add upload endpoints for hotel images

6. **Payment Integration**:
   - Implement Razorpay payment flow
   - Implement Stripe payment flow
   - Add webhook handlers for payment confirmations

7. **Email Notifications**:
   - Configure nodemailer
   - Implement booking confirmation emails
   - Add password reset email functionality

8. **Testing**:
   - Write unit tests with Jest
   - Write integration tests with Supertest
   - Add test coverage

## Security Notes

- CORS is currently open (allows all origins) for development
- In production, configure CORS to allow only your frontend domain
- Never commit `.env` file or secrets to version control
- Use Replit Secrets for all sensitive configuration
- All secrets should be configured through the Replit Secrets UI

## Troubleshooting

**Server won't start:**
- Check logs for error messages
- Verify all required dependencies are installed
- Ensure no port conflicts

**Database errors:**
- If using PostgreSQL, verify DATABASE_URL is correct
- Check database connection settings
- Try deleting `database.sqlite` to reset SQLite database

**API returns 404:**
- Verify the endpoint path is correct (includes `/api/v1/` prefix)
- Check server logs for routing errors

## Recent Changes
- 2025-10-25: Initial Replit setup completed
  - Created minimal project structure for all routes
  - Configured SQLite as default database
  - Set up environment variable handling for Replit
  - Configured CORS for open access (development)
  - Changed server to run on port 3000 with 0.0.0.0 binding
  - All routes return stub responses pending full implementation
*