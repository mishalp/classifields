# Classifieds Marketplace - Flutter App

A modern, feature-rich mobile application for buying and selling items locally, built with Flutter.

## 🎯 Features

### Authentication Module (Current)
- ✅ Beautiful welcome screen with gradient design
- ✅ User registration with email verification
- ✅ Email verification system
- ✅ Secure login with JWT tokens
- ✅ "Remember Me" functionality
- ✅ Password reset via email
- ✅ Real-time password strength validation
- ✅ Form validation with helpful error messages
- ✅ Material 3 design with custom theme
- ✅ Responsive UI for all screen sizes

## 📱 Screenshots

The app includes the following screens:
- **Welcome Screen**: Attractive landing page with app branding
- **Sign Up Screen**: Complete registration with password strength meter
- **Login Screen**: Secure authentication with remember me option
- **Email Verification Screen**: Instructions and resend functionality
- **Forgot Password Screen**: Password reset request
- **Reset Password Screen**: Create new password
- **Home Screen**: User dashboard after successful login

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development
- A running backend server (see server folder)

### Installation

1. **Navigate to the Flutter app directory:**
```bash
cd flutter_app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure API endpoint:**

Edit `lib/core/constants/api_constants.dart` and update the `baseUrl`:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL:5000/api';
```

For local development:
- Android Emulator: `http://10.0.2.2:5000/api`
- iOS Simulator: `http://localhost:5000/api`
- Physical Device: `http://YOUR_COMPUTER_IP:5000/api`

4. **Run the app:**
```bash
flutter run
```

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/
│   │   ├── api_constants.dart        # API endpoints
│   │   └── storage_constants.dart    # Storage keys
│   ├── services/
│   │   ├── api_service.dart          # HTTP client with Dio
│   │   ├── auth_service.dart         # Authentication API calls
│   │   └── storage_service.dart      # Local storage management
│   ├── theme/
│   │   ├── app_colors.dart           # Color palette
│   │   └── app_theme.dart            # Material theme config
│   └── utils/
│       └── validators.dart            # Form validators
├── data/
│   └── models/
│       └── user_model.dart            # User data model
├── providers/
│   └── auth_provider.dart             # State management
├── screens/
│   ├── auth/
│   │   ├── welcome_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── login_screen.dart
│   │   ├── email_verification_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── reset_password_screen.dart
│   └── home_screen.dart
└── widgets/
    ├── custom_button.dart             # Reusable button widget
    ├── custom_text_field.dart         # Reusable input field
    ├── password_strength_meter.dart   # Password validation UI
    └── loading_overlay.dart           # Loading indicator
```

## 🎨 Design System

### Colors
- **Primary**: Purple gradient (#667EEA - #764BA2)
- **Secondary**: Teal (#06D6A0)
- **Success**: Green (#10B981)
- **Error**: Red (#EF4444)
- **Warning**: Orange (#F59E0B)

### Typography
- Font Family: Inter (via Google Fonts)
- Material 3 typography scale

### Components
- Rounded corners (12px default)
- Card elevation with subtle shadows
- Gradient buttons and headers
- Smooth animations and transitions

## 🔐 Security Features

- Passwords are never stored locally
- JWT tokens stored in secure storage (`flutter_secure_storage`)
- Password strength validation (uppercase, lowercase, numbers, special chars)
- Automatic token refresh on API errors
- Protected routes require authentication

## 📦 Dependencies

### Core
- `flutter`: SDK
- `provider: ^6.1.1`: State management
- `dio: ^5.4.0`: HTTP client

### Storage
- `flutter_secure_storage: ^9.0.0`: Secure token storage
- `shared_preferences: ^2.2.2`: App preferences

### Form & Validation
- `flutter_form_builder: ^9.1.1`: Form building
- `form_builder_validators: ^9.1.0`: Validation helpers

### UI
- `google_fonts: ^6.1.0`: Custom fonts
- `flutter_svg: ^2.0.9`: SVG support
- `intl: ^0.19.0`: Internationalization

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 🔧 Configuration

### API Configuration

Update API settings in `lib/core/constants/api_constants.dart`:
- Base URL
- Timeout durations
- Endpoints

### Storage Configuration

Manage storage keys in `lib/core/constants/storage_constants.dart`.

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- 🔄 Web (Coming soon)
- 🔄 Desktop (Coming soon)

## 🎯 Future Features

- [ ] Profile management
- [ ] Browse and search listings
- [ ] Post new ads with images
- [ ] Real-time chat with sellers/buyers
- [ ] Favorites and saved searches
- [ ] User ratings and reviews
- [ ] Push notifications
- [ ] In-app payments
- [ ] Social media integration

## 🐛 Troubleshooting

### Common Issues

**1. Can't connect to backend:**
- Check if backend server is running
- Verify the API base URL is correct
- For Android emulator, use `10.0.2.2` instead of `localhost`

**2. Dependencies error:**
```bash
flutter clean
flutter pub get
```

**3. Build errors:**
```bash
cd android && ./gradlew clean
cd ios && pod install --repo-update
```

**4. Secure storage issues on Android:**
- Ensure minimum SDK version is 21+
- Check AndroidManifest.xml permissions

## 📄 License

MIT License

## 👨‍💻 Author

Built as part of the Classifieds Marketplace project.

## 🤝 Contributing

This is a demo project. Feel free to fork and customize for your needs.

## 📞 Support

For issues and questions:
1. Check the troubleshooting section
2. Review backend logs
3. Verify API endpoints are accessible

---

**Happy Coding!** 🚀

