# 🚀 Complete Setup Guide - Classifieds Marketplace

This guide will walk you through setting up the entire authentication system from scratch.

## 📋 Prerequisites

Before you begin, make sure you have the following installed:

### Backend Requirements
- **Node.js** (v14 or higher) - [Download](https://nodejs.org/)
- **MongoDB** - [Download](https://www.mongodb.com/try/download/community) or use [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- **npm** (comes with Node.js)

### Frontend Requirements
- **Flutter SDK** (3.0.0+) - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, Mac only)
- **VS Code** or **Android Studio** (recommended IDEs)

## 🔧 Step-by-Step Setup

### Phase 1: Backend Setup

#### 1. Setup MongoDB

**Option A: Local MongoDB**
```bash
# Install MongoDB
# macOS
brew tap mongodb/brew
brew install mongodb-community

# Start MongoDB
brew services start mongodb-community

# Verify it's running
mongosh
```

**Option B: MongoDB Atlas (Cloud)**
1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free account
3. Create a cluster
4. Get your connection string
5. Whitelist your IP address

#### 2. Configure Backend

```bash
# Navigate to server directory
cd server

# Install dependencies
npm install

# Copy environment file
cp .env.example .env
```

#### 3. Configure Email (Gmail)

1. **Enable 2-Factor Authentication:**
   - Go to [Google Account Security](https://myaccount.google.com/security)
   - Enable 2-Step Verification

2. **Generate App Password:**
   - Go to [App Passwords](https://myaccount.google.com/apppasswords)
   - Select "Mail" and your device
   - Copy the 16-character password

3. **Update .env file:**
```env
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=your_16_char_app_password
EMAIL_FROM="Classifieds Marketplace <your_gmail@gmail.com>"
```

#### 4. Update .env with Your Configuration

Edit `server/.env`:
```env
PORT=5000
NODE_ENV=development

# Local MongoDB
MONGODB_URI=mongodb://localhost:27017/classifieds_marketplace

# OR MongoDB Atlas
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/classifieds?retryWrites=true&w=majority

JWT_SECRET=your_super_secret_key_change_this_in_production_to_something_very_secure
JWT_EXPIRE=7d

EMAIL_SERVICE=gmail
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=your_app_password
EMAIL_FROM="Classifieds Marketplace <your_gmail@gmail.com>"

FRONTEND_URL=http://localhost:3000
```

#### 5. Start the Backend

```bash
# Development mode (with auto-reload)
npm run dev

# OR Production mode
npm start
```

You should see:
```
✅ MongoDB Connected: localhost
✅ Email server is ready to send messages
🚀 Server is running on port 5000
📍 Environment: development
🌐 Health check: http://localhost:5000/api/health
```

#### 6. Test the Backend

Open a new terminal and test the health endpoint:
```bash
curl http://localhost:5000/api/health
```

You should get:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2025-10-31T..."
}
```

### Phase 2: Flutter App Setup

#### 1. Install Flutter

Follow the official guide: [Flutter Installation](https://docs.flutter.dev/get-started/install)

Verify installation:
```bash
flutter doctor
```

Fix any issues shown by `flutter doctor`.

#### 2. Configure Flutter App

```bash
# Navigate to Flutter app directory
cd flutter_app

# Get dependencies
flutter pub get
```

#### 3. Update API URL

Edit `lib/core/constants/api_constants.dart`:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

**For Physical Device:**
```dart
// Replace with your computer's IP address
static const String baseUrl = 'http://192.168.1.100:5000/api';
```

To find your IP:
```bash
# macOS/Linux
ifconfig | grep inet

# Windows
ipconfig
```

#### 4. Run the Flutter App

**For Android:**
```bash
# Start Android emulator first (from Android Studio)
# OR connect a physical device

flutter run
```

**For iOS (Mac only):**
```bash
# Start iOS simulator
open -a Simulator

# Run the app
flutter run
```

### Phase 3: Testing the Complete System

#### 1. Test User Registration

1. **Launch the app**
2. **Tap "Create Account"**
3. **Fill in the form:**
   - Name: John Doe
   - Email: your_test_email@gmail.com
   - Password: Test123!@#
   - Confirm Password: Test123!@#
   - Location: New York (optional)
4. **Submit**

#### 2. Check Your Email

You should receive a verification email with a link. Click the link.

#### 3. Verify Email

The link will verify your email. You should see a success message.

#### 4. Test Login

1. **Go back to the app**
2. **Tap "Sign In"**
3. **Enter your credentials:**
   - Email: your_test_email@gmail.com
   - Password: Test123!@#
   - Check "Remember Me" (optional)
4. **Sign In**

You should be logged in and see the Home Screen!

#### 5. Test Password Reset

1. **On login screen, tap "Forgot Password?"**
2. **Enter your email**
3. **Check your email for reset link**
4. **Click link and create new password**
5. **Login with new password**

## 🧪 API Testing with Postman/Thunder Client

### 1. Sign Up
```http
POST http://localhost:5000/api/auth/signup
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "confirmPassword": "SecurePass123!",
  "location": "New York"
}
```

### 2. Verify Email
```http
GET http://localhost:5000/api/auth/verify-email?token=YOUR_TOKEN_FROM_EMAIL
```

### 3. Login
```http
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

### 4. Get Current User (Protected)
```http
GET http://localhost:5000/api/auth/me
Authorization: Bearer YOUR_JWT_TOKEN
```

## 🐛 Common Issues & Solutions

### Backend Issues

**1. MongoDB Connection Error**
```
Error: connect ECONNREFUSED 127.0.0.1:27017
```
**Solution:**
- Start MongoDB: `brew services start mongodb-community`
- Or use MongoDB Atlas connection string

**2. Email Not Sending**
```
Error: Invalid login: 535-5.7.8 Username and Password not accepted
```
**Solution:**
- Enable 2FA on Google account
- Generate App Password (not your regular password)
- Use the 16-character app password in .env

**3. Port Already in Use**
```
Error: listen EADDRINUSE: address already in use :::5000
```
**Solution:**
```bash
# Find and kill process
lsof -ti:5000 | xargs kill -9

# Or use a different port in .env
PORT=5001
```

### Flutter Issues

**1. Cannot Connect to Backend from Android Emulator**
```
DioException: Connection refused
```
**Solution:**
- Use `http://10.0.2.2:5000/api` instead of `http://localhost:5000/api`
- Make sure backend is running

**2. Cannot Connect from iOS Simulator**
```
Connection refused
```
**Solution:**
- Use `http://localhost:5000/api`
- Check backend is running
- Check firewall settings

**3. Cannot Connect from Physical Device**
```
Connection timeout
```
**Solution:**
- Use your computer's IP address (not localhost)
- Ensure both devices are on the same WiFi network
- Disable firewall temporarily for testing
- Use: `http://YOUR_COMPUTER_IP:5000/api`

**4. Dependencies Error**
```
Error: Could not resolve dependencies
```
**Solution:**
```bash
flutter clean
flutter pub get
```

**5. Build Errors**
```bash
# Android
cd android
./gradlew clean
cd ..
flutter run

# iOS
cd ios
pod install --repo-update
cd ..
flutter run
```

## 📱 Device-Specific Configuration

### Android Emulator
1. Open Android Studio
2. Tools → Device Manager
3. Create/Start Virtual Device
4. Use API URL: `http://10.0.2.2:5000/api`

### iOS Simulator
1. Open Xcode
2. Xcode → Open Developer Tool → Simulator
3. Use API URL: `http://localhost:5000/api`

### Physical Android Device
1. Enable Developer Options
2. Enable USB Debugging
3. Connect via USB
4. Use your computer's IP address in API URL
5. Ensure both on same network

### Physical iOS Device
1. Open Xcode
2. Trust developer certificate
3. Use your computer's IP address in API URL
4. Ensure both on same network

## 🔒 Security Checklist

Before deploying to production:

- [ ] Change JWT_SECRET to a strong random string
- [ ] Use MongoDB Atlas or secure MongoDB setup
- [ ] Use environment-specific .env files
- [ ] Enable HTTPS/SSL
- [ ] Set up proper CORS configuration
- [ ] Use a professional email service (SendGrid, Mailgun)
- [ ] Set up rate limiting
- [ ] Enable monitoring and logging
- [ ] Set up backup strategy
- [ ] Configure firewall rules
- [ ] Use secure password policies
- [ ] Implement session management
- [ ] Add request validation on all endpoints

## 📚 Next Steps

After setting up authentication:

1. **Profile Management** - Edit user information
2. **Item Listings** - CRUD operations for ads
3. **Search & Filters** - Find items by category, location
4. **Chat System** - Real-time messaging
5. **Payments** - Integrate payment gateway
6. **Notifications** - Push notifications
7. **Admin Panel** - Manage users and listings

## 🎓 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Express.js Guide](https://expressjs.com/)
- [MongoDB University](https://university.mongodb.com/)
- [JWT.io](https://jwt.io/)
- [Material Design](https://m3.material.io/)

## 💡 Tips for Development

1. **Use VS Code Extensions:**
   - Flutter
   - Dart
   - Thunder Client (API testing)
   - MongoDB for VS Code

2. **Keep Terminal Open:**
   - One for backend (`npm run dev`)
   - One for Flutter (`flutter run`)
   - One for testing/commands

3. **Use Git:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Complete auth system"
   ```

4. **Test Thoroughly:**
   - Test on different devices
   - Test edge cases
   - Test error scenarios
   - Test network issues

## 🆘 Getting Help

If you're stuck:

1. Check the error message carefully
2. Review the troubleshooting section
3. Check backend logs
4. Verify .env configuration
5. Test API endpoints with Postman
6. Check Flutter debug console

## ✅ Verification Checklist

- [ ] MongoDB is running
- [ ] Backend server is running (port 5000)
- [ ] Email configuration is working
- [ ] Flutter app is configured with correct API URL
- [ ] Can create a new account
- [ ] Receive verification email
- [ ] Can verify email
- [ ] Can login with verified account
- [ ] Can access protected routes
- [ ] Can reset password
- [ ] Home screen displays user data

## 🎉 Success!

Once everything is working:
- You have a complete authentication system
- Email verification is working
- JWT tokens are being generated
- The app can communicate with the backend
- You're ready to add more features!

---

**Happy Coding! 🚀**

Need help? Review the documentation or check the troubleshooting section.

