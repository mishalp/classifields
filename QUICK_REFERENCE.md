# ⚡ Quick Reference Card

## 🚀 Start Everything (3 Commands)

### Terminal 1: Backend
```bash
cd server
npm run dev
```

### Terminal 2: Admin Panel
```bash
cd admin-panel
npm run dev
```

### Terminal 3: Flutter App
```bash
cd flutter_app
flutter run
```

---

## 🔑 Default Credentials

### Admin Panel
```
URL: http://localhost:5173
Email: admin@classifieds.com
Password: Admin@123456
```

### Flutter App (Test User)
```
Email: test@example.com
Password: password123
```

---

## 📡 API Endpoints

### Base URL
```
http://localhost:5000/api
```

### Quick Test
```bash
curl http://localhost:5000/api/health
```

---

## 🎯 Common Commands

### Backend
```bash
npm run dev          # Start server
npm run seed         # Create test data
npm run seed:admin   # Create admin user
```

### Admin Panel
```bash
npm run dev          # Start dev server
npm run build        # Build for production
npm run preview      # Preview build
```

### Flutter App
```bash
flutter run          # Run app
flutter pub get      # Get dependencies
flutter clean        # Clean build
```

---

## 🗂️ Project Locations

```
classifieds/
├── server/          # Backend
├── admin-panel/     # Admin web app
└── flutter_app/     # Mobile app
```

---

## 📚 Documentation

| File | Description |
|------|-------------|
| `ADMIN_PANEL_COMPLETE.md` | **START HERE** - Complete overview |
| `COMPLETE_SETUP_GUIDE.md` | Full system setup |
| `ADMIN_PANEL_SETUP.md` | Admin panel specific |
| `admin-panel/README.md` | Technical docs |
| `admin-panel/QUICK_START.md` | 3-minute start |
| `admin-panel/FEATURES.md` | Feature details |

---

## 🔧 Environment Files

### server/.env
```env
MONGO_URI=mongodb://localhost:27017/classifieds-marketplace
JWT_SECRET=your_secret_key
PORT=5000
```

### admin-panel/.env
```env
VITE_API_URL=http://localhost:5000/api
```

---

## 🎯 Admin Panel Features

✅ Login/Logout
✅ Dashboard with KPIs
✅ Ads Review (Approve/Reject)
✅ Search & Filter
✅ Pagination
✅ Dark Mode
✅ Responsive Design

---

## 🐛 Quick Fixes

### Backend won't start?
```bash
# Check MongoDB is running
brew services start mongodb-community  # macOS
sudo systemctl start mongod            # Linux

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### Admin panel won't start?
```bash
# Reinstall dependencies
cd admin-panel
rm -rf node_modules package-lock.json
npm install
```

### Can't login?
```bash
# Recreate admin user
cd server
npm run seed:admin
```

---

## 📱 URLs

| Service | URL |
|---------|-----|
| Backend | http://localhost:5000 |
| API Docs | http://localhost:5000/api/health |
| Admin Panel | http://localhost:5173 |

---

## 🎨 Key Technologies

- **Backend**: Node.js + Express + MongoDB
- **Admin Panel**: React + Vite + Tailwind
- **Mobile**: Flutter + Dart
- **Auth**: JWT tokens
- **State**: TanStack Query
- **Styling**: Tailwind CSS + shadcn/ui

---

## ⚡ First-Time Setup

1. **Create .env files** (see Environment Files above)
2. **Install dependencies**:
   ```bash
   cd server && npm install
   cd ../admin-panel && npm install
   cd ../flutter_app && flutter pub get
   ```
3. **Start MongoDB**
4. **Seed database**:
   ```bash
   cd server
   npm run seed
   npm run seed:admin
   ```
5. **Start services** (see Start Everything above)

---

## 🎯 Next Actions

1. ✅ Read `ADMIN_PANEL_COMPLETE.md`
2. ✅ Create `.env` files
3. ✅ Run `npm run seed:admin`
4. ✅ Start backend and admin panel
5. ✅ Login and test features
6. ✅ Customize as needed

---

**Need detailed help? Check `ADMIN_PANEL_COMPLETE.md`**

