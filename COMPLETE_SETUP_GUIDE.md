# 🚀 Complete Setup Guide - Classifieds Marketplace

This is the master guide to set up the entire Classifieds Marketplace system including Backend, Flutter App, and Admin Panel.

## 📦 System Components

1. **Backend** - Node.js + Express + MongoDB
2. **Flutter App** - Mobile application for users
3. **Admin Panel** - React web application for administrators

---

## 🔧 Prerequisites

Before you begin, ensure you have:

- ✅ Node.js (v16 or higher) - [Download](https://nodejs.org/)
- ✅ MongoDB - [Install Guide](https://docs.mongodb.com/manual/installation/)
- ✅ Flutter SDK (for mobile app) - [Install Guide](https://docs.flutter.dev/get-started/install)
- ✅ Git

---

## 📝 Part 1: Backend Setup

### Step 1: Configure Environment

Create a `.env` file in the `server` directory:

```bash
cd server
cat > .env << 'EOF'
# Server Configuration
PORT=5000
NODE_ENV=development

# Database
MONGO_URI=mongodb://localhost:27017/classifieds-marketplace

# JWT Secret (change this!)
JWT_SECRET=your_super_secret_jwt_key_change_me_in_production

# JWT Expiration
JWT_EXPIRE=30d

# Frontend URLs (for CORS)
FRONTEND_URL=http://localhost:5173

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-specific-password
EMAIL_FROM=noreply@classifieds.com
EOF
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Start MongoDB

```bash
# On macOS (with Homebrew)
brew services start mongodb-community

# On Linux (systemd)
sudo systemctl start mongod

# On Windows
# Start MongoDB from Services or use:
net start MongoDB
```

### Step 4: Seed the Database

```bash
# Create test user and sample posts
npm run seed

# Create admin user
npm run seed:admin
```

**Default Admin Credentials:**
- Email: `admin@classifieds.com`
- Password: `Admin@123456`

**Default Test User:**
- Email: `test@example.com`
- Password: `password123`

### Step 5: Start Backend Server

```bash
npm run dev
```

✅ Backend running at: `http://localhost:5000`

Test it: Open `http://localhost:5000/api/health`

---

## 📱 Part 2: Flutter App Setup

### Step 1: Configure API URL

Edit `flutter_app/lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  // Change this to your machine's IP for physical device testing
  static const String baseUrl = 'http://localhost:5000/api';
  
  // For Android Emulator, use: http://10.0.2.2:5000/api
  // For iOS Simulator, use: http://localhost:5000/api
  // For Physical Device, use: http://YOUR_IP:5000/api
}
```

### Step 2: Install Dependencies

```bash
cd flutter_app
flutter pub get
```

### Step 3: Run the App

```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run

# For specific device
flutter devices
flutter run -d <device-id>
```

**Test User Login:**
- Email: `test@example.com`
- Password: `password123`

---

## 🎨 Part 3: Admin Panel Setup

### Step 1: Install Dependencies

```bash
cd admin-panel
npm install
```

### Step 2: Configure Environment

```bash
cat > .env << 'EOF'
VITE_API_URL=http://localhost:5000/api
EOF
```

### Step 3: Start Admin Panel

```bash
npm run dev
```

✅ Admin Panel running at: `http://localhost:5173`

**Admin Login:**
- Email: `admin@classifieds.com`
- Password: `Admin@123456`

---

## 🎯 Quick Start Script

Run all three components with one script:

### Create a start script:

**On macOS/Linux:**

```bash
cat > start-all.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting Classifieds Marketplace..."

# Start MongoDB
echo "📦 Starting MongoDB..."
brew services start mongodb-community || sudo systemctl start mongod

# Start Backend
echo "🔧 Starting Backend Server..."
cd server
npm run dev &
BACKEND_PID=$!

# Wait for backend to start
sleep 5

# Start Admin Panel
echo "🎨 Starting Admin Panel..."
cd ../admin-panel
npm run dev &
ADMIN_PID=$!

# Start Flutter App (optional)
# echo "📱 Starting Flutter App..."
# cd ../flutter_app
# flutter run &
# FLUTTER_PID=$!

echo "✅ All services started!"
echo "Backend: http://localhost:5000"
echo "Admin Panel: http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for Ctrl+C
wait
EOF

chmod +x start-all.sh
./start-all.sh
```

---

## 📊 Testing the Complete System

### 1. Test Backend Health

```bash
curl http://localhost:5000/api/health
```

Expected response:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2025-10-31T..."
}
```

### 2. Test Admin Login (Admin Panel)

1. Open `http://localhost:5173`
2. Login with admin credentials
3. You should see the Dashboard

### 3. Test User App (Flutter)

1. Run Flutter app
2. Login with test user credentials
3. You should see the Home Feed

### 4. Test Ad Creation Flow

1. **Flutter App**: Create a new ad with images
2. **Admin Panel**: Go to "Ads Review"
3. **Admin Panel**: Approve the ad
4. **Flutter App**: Refresh Home Feed - ad should appear

---

## 🗂️ Complete Directory Structure

```
classifieds/
├── server/                    # Backend (Node.js + Express)
│   ├── src/
│   │   ├── controllers/      # Request handlers
│   │   ├── models/           # Database models
│   │   ├── routes/           # API routes
│   │   ├── middleware/       # Auth, validation, etc.
│   │   ├── utils/            # Helper functions
│   │   └── config/           # Configuration
│   ├── uploads/              # Uploaded images
│   ├── .env                  # Environment variables
│   └── package.json
│
├── flutter_app/              # Mobile App (Flutter)
│   ├── lib/
│   │   ├── core/            # Services, constants, themes
│   │   ├── providers/       # State management
│   │   ├── screens/         # UI screens
│   │   └── widgets/         # Reusable widgets
│   ├── android/             # Android config
│   ├── ios/                 # iOS config
│   └── pubspec.yaml         # Dependencies
│
└── admin-panel/              # Admin Panel (React)
    ├── src/
    │   ├── components/      # Reusable components
    │   ├── pages/           # Page components
    │   ├── layouts/         # Layout components
    │   ├── context/         # React context
    │   └── lib/             # Utilities
    ├── .env                 # Environment variables
    └── package.json
```

---

## 🔐 Security Checklist

Before going to production:

- [ ] Change `JWT_SECRET` to a strong random string
- [ ] Change admin password after first login
- [ ] Set up proper email service (Gmail, SendGrid, etc.)
- [ ] Configure MongoDB with authentication
- [ ] Set `NODE_ENV=production`
- [ ] Use HTTPS for all connections
- [ ] Set up proper CORS origins
- [ ] Enable MongoDB connection string encryption
- [ ] Use environment variables for all secrets
- [ ] Set up proper backup strategies

---

## 🐛 Common Issues & Solutions

### MongoDB Connection Error

**Problem**: `MongooseError: The uri parameter to openUri() must be a string`

**Solution**: Make sure `.env` file exists in `server/` with `MONGO_URI` set

### Flutter Can't Connect to Backend

**Problem**: Network error or connection refused

**Solutions**:
- **Android Emulator**: Use `http://10.0.2.2:5000/api`
- **iOS Simulator**: Use `http://localhost:5000/api`
- **Physical Device**: Use `http://YOUR_IP:5000/api` (find IP with `ipconfig` or `ifconfig`)
- Make sure backend is running
- Check firewall settings

### Admin Panel Can't Connect

**Problem**: API calls failing

**Solutions**:
- Verify backend is running: `curl http://localhost:5000/api/health`
- Check `.env` in admin-panel has correct `VITE_API_URL`
- Clear browser cache and reload

### Image Upload Fails

**Problem**: "Only image files are allowed"

**Solutions**:
- Already fixed in the codebase
- Make sure `uploads/` directory exists in `server/`
- Check file permissions

---

## 📈 Next Steps

After setup:

1. **Customize Design**
   - Update color schemes in Flutter app and Admin Panel
   - Add your logo and branding

2. **Add Features**
   - User messaging system
   - Payment integration
   - Advanced search filters
   - User ratings and reviews

3. **Deploy**
   - Backend: Deploy to Heroku, AWS, or DigitalOcean
   - Admin Panel: Deploy to Vercel or Netlify
   - Flutter App: Publish to Google Play and App Store

---

## 📚 Documentation

- [Backend API Documentation](./server/README.md)
- [Flutter App Setup](./flutter_app/README.md)
- [Admin Panel Guide](./admin-panel/README.md)
- [Admin Panel Setup](./ADMIN_PANEL_SETUP.md)

---

## 🤝 Support

Need help?
- Check the troubleshooting section above
- Review the README files in each directory
- Open an issue on GitHub

---

## 📄 License

MIT License

---

**Built with ❤️ using Node.js, Flutter, and React**

