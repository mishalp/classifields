# 🏡 Home Feed - Location-Based Posts Guide

This guide explains the new Home Feed feature with location-based post discovery.

## 🎉 What's New

After successful login, users are now redirected to a **Home Feed** that shows nearby classified ads based on their GPS location. Posts are sorted by distance and recency.

## ✨ Features Implemented

### Backend (Node.js + MongoDB)

✅ **Post Model with GeoJSON**
- MongoDB schema with 2dsphere geospatial indexing
- Location stored as GeoJSON Point format
- Categories: Electronics, Furniture, Vehicles, Real Estate, Fashion, Books, Sports, Home & Garden, Toys & Games, Services, Other
- Fields: title, description, price, images, category, location, status, views, favorites

✅ **Location-Based API Endpoints**
- `GET /api/posts/nearby` - Fetch posts within radius (default 10km)
- `POST /api/posts/create` - Create new post with location
- `GET /api/posts/:id` - Get post details
- `GET /api/posts/my-posts` - Get user's posts
- `PUT /api/posts/:id` - Update post
- `DELETE /api/posts/:id` - Delete post

✅ **Geospatial Queries**
- MongoDB `$geoNear` aggregation for distance calculation
- Sorts by distance (nearest first) then by recency
- Returns distance in kilometers with each post

### Frontend (Flutter)

✅ **Location Services**
- GPS location access with permission handling
- Uses `geolocator` package for location
- Uses `permission_handler` for permissions
- Fallback to last known location

✅ **Home Feed Screen**
- Displays posts in scrollable list
- Pull-to-refresh functionality
- Loading states
- Empty state (no posts nearby)
- Error state with retry options
- Location permission denied state

✅ **Post Card Widget**
- Modern Material 3 design
- Displays: image, title, price, distance, category, time ago, seller name
- Price formatting (K for thousands, L for lakhs, Cr for crores)
- Distance display ("2.5 km away" or "500m away")
- Placeholder for posts without images

✅ **Bottom Navigation**
- Home (feed)
- Chats (placeholder for future)
- Profile (user info and settings)

✅ **Profile Screen**
- User information display
- Menu items for future features
- Logout functionality

## 🚀 Setup Instructions

### 1. Install Flutter Dependencies

```bash
cd flutter_app
flutter pub get
```

New packages added:
- `geolocator: ^10.1.0` - Location services
- `permission_handler: ^11.1.0` - Permission management
- `timeago: ^3.6.0` - Time formatting
- `cached_network_image: ^3.3.1` - Image caching

### 2. Configure Location Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to show nearby posts</string>
```

### 3. Seed Sample Posts (Backend)

```bash
cd server

# Make sure you have a test user created (sign up first)
# Email: test@example.com

# Run seed script
npm run seed
```

This creates 15 sample posts around Bangalore, India with various categories.

### 4. Run the App

**Backend:**
```bash
cd server
npm run dev
```

**Flutter:**
```bash
cd flutter_app
flutter run
```

## 📱 User Flow

1. **Login** → User enters credentials
2. **Redirect** → Automatically navigates to Home Feed
3. **Location Permission** → App requests location access
4. **Grant Permission** → User allows location
5. **Fetch Posts** → App fetches nearby posts from API
6. **Display Feed** → Posts shown in scrollable list
7. **Pull to Refresh** → User can refresh the feed
8. **Tap Post** → Navigate to post details (future feature)

## 🎨 UI/UX Highlights

### Material 3 Design
- Rounded cards with elevation
- Gradient accent colors
- Smooth animations
- Professional typography (Inter font)

### Post Card Layout
```
┌─────────────────────────┐
│      [Image/Placeholder] │
├─────────────────────────┤
│ Title                   │
│ ₹ Price  📍 2.5 km away │
│ [Category] • 2h ago     │
│ 👤 Seller Name          │
└─────────────────────────┘
```

### Empty States
- **No Posts**: Friendly message with "Create Post" CTA
- **Location Denied**: Clear explanation with permission buttons
- **Network Error**: Retry button with helpful message

### Bottom Navigation
- **Home**: Active feed
- **Chats**: Coming soon placeholder
- **Profile**: User account and settings

## 🔌 API Usage Examples

### Get Nearby Posts

**Request:**
```http
GET /api/posts/nearby?lat=12.9716&lng=77.5946&radius=10&limit=20
Authorization: Bearer <JWT_TOKEN>
```

**Response:**
```json
{
  "success": true,
  "count": 15,
  "data": {
    "posts": [
      {
        "_id": "...",
        "title": "iPhone 13 Pro Max 256GB",
        "description": "Excellent condition...",
        "price": 65000,
        "category": "Electronics",
        "distance": 0.5,
        "createdAt": "2025-10-31T...",
        "createdBy": {
          "_id": "...",
          "name": "John Doe"
        }
      }
    ]
  }
}
```

### Create Post

**Request:**
```http
POST /api/posts/create
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "title": "iPhone 13 Pro Max",
  "description": "Excellent condition",
  "price": 65000,
  "category": "Electronics",
  "lat": 12.9716,
  "lng": 77.5946,
  "address": "MG Road, Bangalore"
}
```

## 🧪 Testing the Feature

### 1. Create Test Account
```bash
# Sign up with:
Email: test@example.com
Password: Test123!@#
```

### 2. Seed Database
```bash
cd server
npm run seed
```

### 3. Test Scenarios

**Scenario 1: Normal Flow**
1. Login with test account
2. Grant location permission
3. See 15 sample posts
4. Pull to refresh
5. View post cards

**Scenario 2: Location Denied**
1. Login
2. Deny location permission
3. See error state
4. Tap "Enable Location"
5. Grant permission
6. Posts load

**Scenario 3: No Posts**
1. Use location far from Bangalore
2. See "No Posts Nearby" message
3. Increase radius or create posts

## 📊 Database Structure

### Post Document
```javascript
{
  _id: ObjectId,
  title: "iPhone 13 Pro Max",
  description: "Excellent condition...",
  price: 65000,
  images: [],
  category: "Electronics",
  location: {
    type: "Point",
    coordinates: [77.5946, 12.9716], // [lng, lat]
    address: "MG Road, Bangalore"
  },
  createdBy: ObjectId (User reference),
  status: "active",
  views: 0,
  favorites: 0,
  createdAt: ISODate,
  updatedAt: ISODate
}
```

### Geospatial Index
```javascript
db.posts.createIndex({ location: "2dsphere" });
```

## 🎯 Future Enhancements

The following features are placeholders for future implementation:

- [ ] Post Details Screen
- [ ] Create/Edit Post Screen
- [ ] Image upload for posts
- [ ] Favorites/Wishlist
- [ ] Search and filters
- [ ] Category browsing
- [ ] Chat with sellers
- [ ] Push notifications
- [ ] User ratings and reviews
- [ ] Price negotiation
- [ ] Report post
- [ ] Share post

## 🔍 Troubleshooting

### Location Not Working

**Issue**: Posts not loading
**Solution**:
1. Check location permission granted
2. Ensure GPS is enabled
3. Check API URL configuration
4. Verify backend is running

**Issue**: "Location services disabled"
**Solution**:
1. Enable GPS on device
2. Tap "Open Settings" in app
3. Turn on location services

### No Posts Showing

**Issue**: Empty feed despite permission
**Solution**:
1. Run seed script: `npm run seed`
2. Check if backend has posts in database
3. Verify your location is within radius
4. Try increasing radius in API call

### Permission Errors (Android)

**Issue**: Permission not requesting
**Solution**:
1. Check `AndroidManifest.xml` has location permissions
2. Uninstall and reinstall app
3. Grant permission manually in settings

### Permission Errors (iOS)

**Issue**: Permission dialog not showing
**Solution**:
1. Check `Info.plist` has usage descriptions
2. Reset simulator: Device → Erase All Content and Settings
3. For physical device: Settings → Privacy → Location Services

## 📸 Screenshots

### Home Feed
- Shows posts in cards
- Distance and price prominently displayed
- Category badges
- Seller information

### Empty State
- Friendly illustration
- Clear message
- Call-to-action button

### Location Permission
- Permission rationale
- Easy access to settings
- Retry functionality

## 🎨 Design Tokens

### Colors
- Primary: `#667EEA` (Purple)
- Secondary: `#06D6A0` (Teal)
- Success: `#10B981` (Green)
- Error: `#EF4444` (Red)
- Warning: `#F59E0B` (Orange)

### Typography
- Font: Inter (Google Fonts)
- Headings: Bold, 20-32px
- Body: Regular, 14-16px
- Captions: Light, 12px

### Spacing
- Card padding: 12px
- Section margins: 16px
- Element spacing: 8px

## 📦 File Structure

### Backend
```
server/src/
├── models/Post.js           # Post schema with geospatial
├── controllers/postController.js  # Post logic
├── routes/postRoutes.js     # Post endpoints
└── utils/seedPosts.js       # Sample data script
```

### Frontend
```
flutter_app/lib/
├── data/models/post_model.dart
├── core/services/
│   ├── location_service.dart
│   └── post_service.dart
├── providers/post_provider.dart
├── screens/
│   ├── main_screen.dart     # Bottom navigation
│   ├── home/home_feed_screen.dart
│   └── profile/profile_screen.dart
└── widgets/post_card.dart
```

## ✅ Checklist

Before using the Home Feed feature:

- [ ] Backend server running
- [ ] MongoDB connected
- [ ] Test user created
- [ ] Sample posts seeded
- [ ] Flutter dependencies installed
- [ ] Location permissions configured
- [ ] API URL updated in app
- [ ] App installed on device/emulator

## 🎊 Success!

You now have a fully functional location-based Home Feed! Users can discover posts near them, and the system automatically sorts by proximity and recency.

**Next Steps**: Implement post creation, chat, and search features to complete the marketplace experience!

---

**Built with ❤️ using Flutter, Node.js, Express, and MongoDB**

