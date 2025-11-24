# ⚡ Quick Start Guide

Get up and running in 5 minutes!

## 🎯 What You've Got

A complete authentication system with:
- ✅ Node.js + Express + MongoDB backend
- ✅ Flutter mobile app (Android & iOS)
- ✅ Email verification
- ✅ Password reset
- ✅ Beautiful Material 3 UI

## 🚀 Quick Setup (5 Minutes)

### 1. Start Backend (2 minutes)

```bash
# Terminal 1: Backend
cd server
npm install
cp .env.example .env

# Edit .env with your email credentials (see below)
# Then start the server
npm run dev
```

**Important**: Update `.env` with your Gmail credentials:
```env
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=your_16_char_app_password
```

[How to get Gmail App Password →](https://support.google.com/accounts/answer/185833)

### 2. Start Flutter App (3 minutes)

```bash
# Terminal 2: Flutter App
cd flutter_app
flutter pub get

# Update API URL in lib/core/constants/api_constants.dart
# Then run
flutter run
```

**API URL Configuration:**
- Android Emulator: `http://10.0.2.2:5000/api`
- iOS Simulator: `http://localhost:5000/api`
- Physical Device: `http://YOUR_COMPUTER_IP:5000/api`

## 🧪 Test It Out

1. **Create Account** → Tap "Create Account"
2. **Check Email** → Click verification link
3. **Sign In** → Use your credentials
4. **Success!** → You're in! 🎉

## 📁 Project Structure

```
classifieds/
├── server/              # Backend API
│   ├── src/
│   └── package.json
├── flutter_app/         # Mobile App
│   ├── lib/
│   └── pubspec.yaml
└── README.md           # Full documentation
```

## 🔧 Key Files to Configure

### Backend
- `server/.env` - Environment variables
  - MongoDB connection
  - Email credentials
  - JWT secret

### Frontend
- `flutter_app/lib/core/constants/api_constants.dart` - API URL

## 💡 Common Issues

**Backend not starting?**
- Install MongoDB: `brew install mongodb-community`
- Start MongoDB: `brew services start mongodb-community`

**Can't send emails?**
- Enable 2FA on Google account
- Generate App Password (not regular password)
- Use 16-character app password in .env

**Flutter can't connect?**
- Check backend is running on port 5000
- Use correct IP for your setup (see above)
- Ensure devices on same network (physical devices)

## 📚 Full Documentation

For detailed setup, troubleshooting, and API docs:
- **Complete Setup**: [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Full README**: [README.md](README.md)
- **Backend Docs**: [server/README.md](server/README.md)
- **Flutter Docs**: [flutter_app/README.md](flutter_app/README.md)

## 🎨 Features Built

### Backend Features
- User registration with validation
- Email verification system
- JWT authentication
- Password reset flow
- Protected routes
- Rate limiting
- Beautiful email templates

### Frontend Features
- Welcome screen
- Sign up with password strength meter
- Email verification screen
- Login with "Remember Me"
- Forgot password flow
- Reset password
- Home screen with user info
- Material 3 design
- Provider state management

## 🔐 Default Test Credentials

Create your own test account using:
- **Email**: Any valid email you can access
- **Password**: Must include:
  - 8+ characters
  - Uppercase letter
  - Lowercase letter
  - Number
  - Special character
  - Example: `Test123!@#`

## 📊 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/signup` | POST | Register new user |
| `/api/auth/verify-email` | GET | Verify email |
| `/api/auth/login` | POST | Login user |
| `/api/auth/forgot-password` | POST | Request reset |
| `/api/auth/reset-password` | POST | Reset password |
| `/api/auth/me` | GET | Get user (protected) |
| `/api/health` | GET | Health check |

## 🛠️ Tech Stack

**Backend**: Node.js, Express, MongoDB, JWT, Nodemailer  
**Frontend**: Flutter, Provider, Dio, Material 3

## 🎯 Next Steps

1. ✅ Get it running (you're here!)
2. 📝 Test all features
3. 🎨 Customize the design
4. 🚀 Add marketplace features:
   - Item listings
   - Search functionality
   - Real-time chat
   - Image uploads
   - Payment integration

## 💻 Development Commands

### Backend
```bash
npm run dev    # Development with auto-reload
npm start      # Production mode
```

### Flutter
```bash
flutter run              # Run app
flutter clean            # Clean build
flutter pub get          # Install dependencies
flutter build apk        # Build Android APK
flutter build ios        # Build iOS
```

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- 🔄 Web (ready to add)
- 🔄 Desktop (ready to add)

## 🎉 You're All Set!

The authentication system is complete and production-ready. You can now:
- Add more features to the marketplace
- Customize the UI/UX
- Deploy to production
- Scale as needed

**Need Help?** Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed troubleshooting.

---

**Happy Building! 🚀**

