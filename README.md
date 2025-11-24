# 🏪 Classifieds Marketplace

A complete, modern classifieds marketplace platform with mobile app and admin panel.

## 📦 Components

### 1. Backend API (Node.js + Express + MongoDB)
- RESTful API with JWT authentication
- User authentication with email verification
- Location-based ad posting and discovery
- Admin panel APIs
- Image upload with Multer
- MongoDB with GeoJSON for location queries

### 2. Mobile App (Flutter)
- Material 3 design
- User authentication (signup, login, password reset)
- Location-based home feed
- Ad posting with multi-image upload
- Real-time location services
- Beautiful, responsive UI

### 3. Admin Panel (React + Vite)
- Modern web dashboard
- Admin authentication
- KPI dashboard with statistics
- Ads review system (approve/reject)
- TanStack Table with search & pagination
- Light/Dark mode
- Fully responsive

---

## 🚀 Quick Start

### Prerequisites
- Node.js (v16+)
- MongoDB
- Flutter SDK (for mobile app)

### 1. Start Backend

```bash
cd server

# Create .env file (copy from .env.example)
cp .env.example .env

# Edit .env with your MongoDB URI and other configs
nano .env

# Install dependencies
npm install

# Seed database with test data and admin user
npm run seed
npm run seed:admin

# Start server
npm run dev
```

Backend runs at: `http://localhost:5000`

### 2. Start Admin Panel

```bash
cd admin-panel

# Install dependencies
npm install

# Create .env file
echo "VITE_API_URL=http://localhost:5000/api" > .env

# Start dev server
npm run dev
```

Admin panel at: `http://localhost:5173`

**Login**: admin@classifieds.com / Admin@123456

### 3. Run Flutter App

```bash
cd flutter_app

# Install dependencies
flutter pub get

# Run app
flutter run
```

**Test user**: test@example.com / password123

---

## 📚 Documentation

- **[Complete Setup Guide](./COMPLETE_SETUP_GUIDE.md)** - Detailed setup instructions
- **[Admin Panel Setup](./ADMIN_PANEL_SETUP.md)** - Admin panel specific guide
- **[Search & Filter Feature](./SEARCH_FILTER_FEATURE.md)** - 🔍 Search and category filters guide
- **[Search Filter Quick Start](./SEARCH_FILTER_QUICK_START.md)** - ⚡ Quick guide to test search
- **[Sorting Feature](./SORTING_FEATURE.md)** - 🔄 Complete sorting documentation
- **[Sorting Quick Start](./SORTING_QUICK_START.md)** - ⚡ Quick guide to test sorting
- **[Chat Feature Implementation](./CHAT_FEATURE_IMPLEMENTATION.md)** - 💬 Complete chat guide
- **[Chat Feature Status](./CHAT_FEATURE_STATUS.md)** - 💬 Implementation progress
- **[Chat UX Improvements](./CHAT_UX_IMPROVEMENTS.md)** - ✨ Modern UI & read state fixes
- **[Chat Improvements Quick Guide](./CHAT_IMPROVEMENTS_QUICK_GUIDE.md)** - ⚡ Quick reference
- **[Backend README](./server/README.md)** - API documentation
- **[Admin Panel README](./admin-panel/README.md)** - Admin panel docs
- **[Quick Start Guide](./QUICK_START.md)** - Original quick start

---

## 🎯 Features

### For Users (Mobile App)
✅ Sign up with email verification
✅ Secure login and password reset
✅ Location-based ad discovery
✅ **Search ads by keywords** 🔍
✅ **Filter by category** 📂
✅ **Sort by: Newest, Nearest, Price** 🔄
✅ Post ads with multiple images
✅ Real-time location services
✅ Beautiful Material 3 UI
✅ Dark/Light mode

### For Admins (Web Panel)
✅ Secure admin authentication
✅ Dashboard with KPIs
✅ Review and approve/reject ads
✅ Search and filter functionality
✅ User management (coming soon)
✅ Analytics (coming soon)

### Backend APIs
✅ User authentication (JWT)
✅ Email verification
✅ Password reset
✅ Location-based queries (GeoJSON)
✅ Multi-image upload
✅ Admin authentication
✅ Ad moderation APIs

---

## 🗂️ Project Structure

```
classifieds/
├── server/                 # Backend (Node.js + Express + MongoDB)
│   ├── src/
│   │   ├── controllers/   # Business logic
│   │   ├── models/        # MongoDB models
│   │   ├── routes/        # API routes
│   │   ├── middleware/    # Auth, validation, uploads
│   │   ├── utils/         # Helpers and seeds
│   │   └── config/        # DB and email config
│   ├── uploads/           # User-uploaded images
│   └── .env              # Environment variables
│
├── flutter_app/           # Mobile App (Flutter)
│   ├── lib/
│   │   ├── core/         # Services, themes, constants
│   │   ├── providers/    # State management
│   │   ├── screens/      # UI screens
│   │   └── widgets/      # Reusable widgets
│   └── pubspec.yaml
│
├── admin-panel/           # Admin Panel (React + Vite)
│   ├── src/
│   │   ├── components/   # UI components
│   │   ├── pages/        # Page components
│   │   ├── layouts/      # Layout components
│   │   ├── context/      # Auth context
│   │   └── lib/          # Axios, utilities
│   └── .env
│
└── README.md             # This file
```

---

## 🔐 Default Credentials

### Admin Panel
- Email: `admin@classifieds.com`
- Password: `Admin@123456`

### Test User (Mobile App)
- Email: `test@example.com`
- Password: `password123`

**⚠️ Change these in production!**

---

## 🛠️ Tech Stack

### Backend
- Node.js + Express.js
- MongoDB + Mongoose
- JWT authentication
- Multer (file uploads)
- Nodemailer (emails)
- bcryptjs (password hashing)

### Mobile App
- Flutter (Dart)
- Provider (state management)
- Dio (HTTP client)
- Geolocator (location)
- Image Picker (photos)
- Material 3 design

### Admin Panel
- React 18 + Vite
- Tailwind CSS
- shadcn/ui components
- TanStack Query & Table
- React Router v6
- Framer Motion
- Axios

---

## 📊 API Endpoints

### User Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/verify-email/:token` - Verify email
- `POST /api/auth/forgot-password` - Request reset
- `POST /api/auth/reset-password/:token` - Reset password
- `GET /api/auth/me` - Get current user

### Posts/Ads
- `GET /api/posts/nearby?search=<text>&category=<category>&sort=<sort>` - Get nearby posts with filters & sorting
- `GET /api/posts/:id` - Get post details
- `GET /api/posts/my-posts` - Get user's own posts
- `POST /api/posts/create` - Create new post
- `POST /api/posts/upload-images` - Upload images
- `PUT /api/posts/:id` - Update post
- `DELETE /api/posts/:id` - Delete post

### Admin
- `POST /api/admin/login` - Admin login
- `GET /api/admin/me` - Get admin profile
- `GET /api/admin/overview` - Dashboard stats
- `GET /api/admin/posts/pending` - Pending ads
- `PATCH /api/admin/posts/:id/approve` - Approve ad
- `PATCH /api/admin/posts/:id/reject` - Reject ad
- `GET /api/admin/users` - Get all users

### Chat (Real-time) 💬
- `POST /api/chat/start` - Start or get conversation
- `GET /api/chat/conversations` - Get all conversations
- `GET /api/chat/:id/messages` - Get messages for conversation
- `POST /api/chat/:id/message` - Send message (REST fallback)
- `GET /api/chat/unread-count` - Get unread messages count

**Socket.io Events:**
- `join_conversation` - Join conversation room
- `leave_conversation` - Leave conversation room
- `send_message` - Send message in real-time
- `receive_message` - Receive message in real-time
- `typing` - Send typing indicator
- `user_typing` - Receive typing indicator

---

## 🧪 Testing

### Test Backend
```bash
curl http://localhost:5000/api/health
```

### Test Admin Login
```bash
curl -X POST http://localhost:5000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@classifieds.com","password":"Admin@123456"}'
```

### Test User Signup
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test2@example.com","password":"password123"}'
```

---

## 🔧 Development

### Backend
```bash
cd server
npm run dev     # Start with nodemon
npm run seed    # Seed test data
npm run seed:admin  # Create admin user
```

### Admin Panel
```bash
cd admin-panel
npm run dev     # Start dev server
npm run build   # Build for production
npm run preview # Preview production build
```

### Flutter App
```bash
cd flutter_app
flutter run                    # Run on connected device
flutter run -d chrome          # Run on web
flutter build apk              # Build Android APK
flutter build ios              # Build iOS app
```

---

## 🚢 Deployment

### Backend
- Deploy to Heroku, AWS, DigitalOcean, or Railway
- Use MongoDB Atlas for database
- Set environment variables
- Enable HTTPS

### Admin Panel
- Deploy to Vercel, Netlify, or AWS Amplify
- Set `VITE_API_URL` environment variable
- Configure build settings:
  - Build command: `npm run build`
  - Output directory: `dist`

### Mobile App
- **Android**: Build APK and upload to Google Play
- **iOS**: Build IPA and upload to App Store

---

## 🎯 Roadmap

### Phase 1 (Completed) ✅
- [x] User authentication system
- [x] Email verification
- [x] Location-based home feed
- [x] **Search & category filters** 🔍
- [x] **Sort by: Newest, Nearest, Price** 🔄
- [x] Ad posting with images
- [x] Ad details & My Posts pages
- [x] Admin panel with dashboard
- [x] Ad review system with filters
- [x] **Chat system (Backend 100% complete)** 💬

### Phase 2 (Upcoming)
- [ ] **Chat UI (Flutter frontend)** 💬🚧
- [ ] Favorites and saved ads
- [ ] User profiles with ratings
- [ ] Push notifications for chat/ads
- [ ] Payment integration
- [ ] Report/Block users

### Phase 3 (Future)
- [ ] Ratings and reviews
- [ ] Featured ads
- [ ] Analytics dashboard
- [ ] Multi-language support
- [ ] Mobile web version

---

## 🐛 Known Issues

- None currently reported

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

MIT License - See LICENSE file for details

---

## 📞 Support

For issues or questions:
- Check the documentation
- Review troubleshooting guides
- Open an issue on GitHub

---

**Built with ❤️ using Node.js, Flutter, and React**

---

## 🎉 Success Checklist

After setup, verify:

**Backend & Database:**
- [ ] Backend health endpoint returns 200
- [ ] MongoDB is connected
- [ ] Text search index is created

**Admin Panel:**
- [ ] Admin can login to web panel
- [ ] Dashboard shows statistics
- [ ] Can approve/reject ads
- [ ] Can filter ads by status

**Mobile App:**
- [ ] Test user can login to mobile app
- [ ] Can view nearby ads
- [ ] **Can search ads by keyword** 🔍
- [ ] **Can filter by category** 📂
- [ ] **Can sort by Newest, Nearest, Price** 🔄
- [ ] Can create new ad with images
- [ ] Images upload successfully
- [ ] Can view ad details
- [ ] Can see "My Posts" section

**Integration:**
- [ ] New ad appears in admin panel for review
- [ ] Approved ad appears in home feed
- [ ] Search returns relevant results
- [ ] Category filters work correctly
- [ ] Sorting changes order correctly
- [ ] All filters work together (search + category + sort)

All checked? **You're ready to go! 🚀**
