# Classifieds Marketplace - Authentication Backend

Complete authentication system with email verification for a classifieds marketplace application.

## 🚀 Features

- ✅ User registration with email verification
- ✅ Email verification via Nodemailer
- ✅ Secure login with JWT tokens
- ✅ Password reset functionality
- ✅ Resend verification email
- ✅ Protected routes middleware
- ✅ Input validation with express-validator
- ✅ Rate limiting for security
- ✅ Password hashing with bcrypt
- ✅ Beautiful HTML email templates

## 📋 Prerequisites

- Node.js (v14 or higher)
- MongoDB (local or Atlas)
- Gmail account (or SMTP service) for sending emails

## 🛠️ Installation

1. **Install dependencies:**
```bash
cd server
npm install
```

2. **Configure environment variables:**

Copy `.env.example` to `.env` and update the values:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:
- Set your MongoDB connection string
- Configure email settings (Gmail or SMTP)
- Set a strong JWT secret
- Update the frontend URL

### Email Configuration (Gmail)

To use Gmail for sending emails:

1. Go to your Google Account settings
2. Enable 2-factor authentication
3. Generate an App Password:
   - Go to Security → 2-Step Verification → App passwords
   - Select "Mail" and your device
   - Copy the generated password
4. Use this app password in your `.env` file as `EMAIL_PASS`

## 🚦 Running the Server

**Development mode:**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

The server will run on `http://localhost:5000`

## 📡 API Endpoints

### Authentication Routes

| Method | Endpoint                        | Description                    | Auth Required |
|--------|---------------------------------|--------------------------------|---------------|
| POST   | `/api/auth/signup`              | Register new user              | No            |
| GET    | `/api/auth/verify-email`        | Verify email with token        | No            |
| POST   | `/api/auth/login`               | Login user                     | No            |
| POST   | `/api/auth/forgot-password`     | Request password reset         | No            |
| POST   | `/api/auth/reset-password`      | Reset password with token      | No            |
| POST   | `/api/auth/resend-verification` | Resend verification email      | No            |
| GET    | `/api/auth/me`                  | Get current user info          | Yes           |

### Health Check

| Method | Endpoint        | Description          |
|--------|-----------------|----------------------|
| GET    | `/api/health`   | Server health check  |

## 📝 API Usage Examples

### 1. User Signup

```bash
POST /api/auth/signup
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "confirmPassword": "SecurePass123!",
  "location": "New York"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful! Please check your email to verify your account.",
  "data": {
    "user": {
      "id": "...",
      "name": "John Doe",
      "email": "john@example.com",
      "verified": false
    }
  }
}
```

### 2. Verify Email

```bash
GET /api/auth/verify-email?token=<verification_token>
```

### 3. Login

```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "...",
      "name": "John Doe",
      "email": "john@example.com",
      "verified": true
    }
  }
}
```

### 4. Get Current User (Protected)

```bash
GET /api/auth/me
Authorization: Bearer <your_jwt_token>
```

### 5. Forgot Password

```bash
POST /api/auth/forgot-password
Content-Type: application/json

{
  "email": "john@example.com"
}
```

### 6. Reset Password

```bash
POST /api/auth/reset-password
Content-Type: application/json

{
  "token": "<reset_token>",
  "password": "NewSecurePass123!"
}
```

## 🔒 Security Features

- **Password Requirements:** Minimum 8 characters with uppercase, lowercase, number, and special character
- **JWT Authentication:** Secure token-based authentication
- **Password Hashing:** bcrypt with salt rounds
- **Rate Limiting:** Prevents brute force attacks
- **Email Verification:** Ensures valid email addresses
- **Token Expiration:** Email verification (24h), Password reset (1h)
- **Input Validation:** express-validator for all inputs

## 🗂️ Project Structure

```
server/
├── src/
│   ├── config/
│   │   ├── db.js              # MongoDB connection
│   │   └── email.js           # Nodemailer config & templates
│   ├── controllers/
│   │   └── authController.js  # Authentication logic
│   ├── middleware/
│   │   ├── authMiddleware.js  # JWT verification
│   │   └── validationMiddleware.js
│   ├── models/
│   │   └── User.js            # User schema
│   ├── routes/
│   │   └── authRoutes.js      # Route definitions
│   ├── utils/
│   │   └── generateToken.js   # Token utilities
│   └── app.js                 # Express app setup
├── .env                       # Environment variables
├── .env.example              # Example env file
├── package.json
├── server.js                 # Server entry point
└── README.md
```

## 🧪 Testing

You can test the API using:
- **Postman** or **Thunder Client**
- **cURL** commands
- Frontend application

## 🐛 Troubleshooting

### Email not sending
- Check your Gmail App Password is correct
- Verify 2FA is enabled on your Google account
- Check firewall/antivirus settings

### MongoDB connection issues
- Ensure MongoDB is running locally or Atlas URL is correct
- Check network connectivity
- Verify credentials

### Token errors
- Ensure JWT_SECRET is set in .env
- Check token expiration times
- Verify Authorization header format: `Bearer <token>`

## 📚 Dependencies

- **express** - Web framework
- **mongoose** - MongoDB ODM
- **bcryptjs** - Password hashing
- **jsonwebtoken** - JWT token generation
- **nodemailer** - Email sending
- **express-validator** - Input validation
- **express-rate-limit** - Rate limiting
- **cors** - CORS middleware
- **dotenv** - Environment variables

## 🔮 Future Enhancements

- Refresh token implementation
- OAuth integration (Google, Facebook)
- Two-factor authentication (2FA)
- Email templates customization
- Admin panel
- User roles and permissions

## 📄 License

MIT License

## 👨‍💻 Author

Built for the Classifieds Marketplace project.

