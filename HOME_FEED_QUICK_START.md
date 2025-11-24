# ⚡ Home Feed - Quick Start

Get the location-based home feed running in 5 minutes!

## 🚀 Quick Setup

### 1. Install Dependencies (2 min)

**Backend** (if not already done):
```bash
cd server
npm install
```

**Flutter**:
```bash
cd flutter_app
flutter pub get
```

### 2. Seed Sample Posts (1 min)

```bash
cd server

# First, create a test user via the app or API:
# Email: test@example.com
# Password: Test123!@#

# Then seed posts:
npm run seed
```

You'll see:
```
✅ Created 15 sample posts
📊 Sample Posts Summary:
1. iPhone 13 Pro Max 256GB - ₹65000 (Electronics)
2. Royal Enfield Classic 350 - ₹125000 (Vehicles)
...
```

### 3. Run Everything (2 min)

**Terminal 1 - Backend**:
```bash
cd server
npm run dev
```

**Terminal 2 - Flutter**:
```bash
cd flutter_app
flutter run
```

## 📱 Test Flow

1. **Sign In** with your test account
2. **Grant Location Permission** when prompted
3. **View Posts** - You'll see 15 sample posts
4. **Pull Down** to refresh
5. **Tap a Post** (details screen coming soon)
6. **Bottom Nav** - Try Profile and Chats tabs

## 🎯 What You Get

### Backend API
- ✅ 6 new POST endpoints
- ✅ GeoJSON location support
- ✅ Geospatial queries (MongoDB)
- ✅ Distance calculation
- ✅ Sample data script

### Flutter App
- ✅ Home Feed screen
- ✅ Location services
- ✅ Post cards with distance
- ✅ Bottom navigation
- ✅ Profile screen
- ✅ Empty & error states
- ✅ Pull to refresh

## 🔧 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/posts/nearby` | GET | Get posts near location |
| `/api/posts/create` | POST | Create new post |
| `/api/posts/:id` | GET | Get post details |
| `/api/posts/my-posts` | GET | Get user's posts |
| `/api/posts/:id` | PUT | Update post |
| `/api/posts/:id` | DELETE | Delete post |

## 📊 Sample Data

15 posts created around **Bangalore, India**:
- 📱 Electronics (iPhone, Laptop, TV, Camera, PS5)
- 🚗 Vehicles (Royal Enfield, Mountain Bike)
- 🛋️ Furniture (Table, Sofa, Study Desk)
- 🏘️ Real Estate (2 BHK Apartment)
- 👕 Fashion (Nike Shoes)
- 📚 Books (Harry Potter Set)
- ⚾ Sports (Cricket Kit)
- 🧸 Toys

## 🎨 Features Showcase

### Post Card
```
┌──────────────────────┐
│   [Product Image]    │
├──────────────────────┤
│ iPhone 13 Pro Max    │
│ ₹65K  📍 2.5 km away│
│ Electronics • 2h ago │
│ 👤 John Doe          │
└──────────────────────┘
```

### Location States
1. **Loading** → Spinner while fetching
2. **Loaded** → Posts displayed
3. **Empty** → "No posts nearby" message
4. **Error** → Retry button
5. **Permission Denied** → Enable location CTA

## 🐛 Quick Fixes

### No Posts Showing?
```bash
# Seed again
cd server && npm run seed
```

### Location Not Working?
1. Check GPS is ON
2. Grant permission in app
3. Try "Open Settings" button

### Can't Connect to Backend?
**Android Emulator**: Use `http://10.0.2.2:5000/api`  
**iOS Simulator**: Use `http://localhost:5000/api`  
**Physical Device**: Use `http://YOUR_COMPUTER_IP:5000/api`

## 📱 Permissions

**Android** - Already configured in:
- `android/app/src/main/AndroidManifest.xml`

**iOS** - Already configured in:
- `ios/Runner/Info.plist`

Just grant permission when app requests!

## ✅ Verification Checklist

After setup, verify:

- [ ] Backend running on port 5000
- [ ] Sample posts in database (`npm run seed`)
- [ ] Flutter app launches
- [ ] Login redirects to Home Feed
- [ ] Location permission requested
- [ ] Posts display with distances
- [ ] Pull-to-refresh works
- [ ] Bottom navigation switches tabs

## 🎯 Next Features to Build

- Post Details Screen
- Create Post Screen
- Search & Filters
- Chat with Sellers
- Favorites/Wishlist
- User Ratings
- Image Upload

## 📚 Full Documentation

- [HOME_FEED_GUIDE.md](HOME_FEED_GUIDE.md) - Complete documentation
- [README.md](README.md) - Project overview
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Detailed setup

## 🎉 You're Ready!

The home feed is live! Users can now discover nearby posts sorted by distance and time.

**Enjoy building your marketplace! 🚀**

