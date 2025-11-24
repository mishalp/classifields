# 📝 Ad Posting with Multi-Image Upload - Complete Guide

Comprehensive guide for the Ad Posting feature with multi-image upload, price tagging, and location detection.

## 🎉 What's Implemented

Users can now create and submit classified ads with:
- ✅ Multi-image upload (up to 10 images)
- ✅ Image compression for faster uploads
- ✅ Title, description, category, and price
- ✅ Automatic GPS location tagging
- ✅ Manual address entry
- ✅ Pending/Approved status workflow
- ✅ Admin approval required before posts appear in feed

## ✨ Features Overview

### Backend (Node.js + Express + MongoDB)

#### 1. **Multi-Image Upload with Multer**
- Accepts up to 10 images per post
- File size limit: 5MB per image
- Supported formats: JPEG, JPG, PNG, GIF, WEBP
- Images stored in `/uploads` directory
- Unique filenames using UUID + timestamp

#### 2. **Post Status Workflow**
- **Pending**: Newly created posts (default)
- **Approved**: Posts approved by admin (visible in feed)
- **Rejected**: Posts rejected by admin
- **Sold**: Items marked as sold
- **Inactive**: Posts deactivated by user

#### 3. **API Endpoints**
- `POST /api/posts/upload-images` - Upload multiple images
- `POST /api/posts/create` - Create new post (status: pending)
- `GET /api/posts/nearby` - Only returns approved posts
- `GET /api/posts/my-posts` - User's posts (all statuses)

### Frontend (Flutter)

#### 1. **Create Post Screen**
- Modern Material 3 design
- Form with validation
- Image picker with grid preview
- Category dropdown
- Price input with validation
- Auto GPS location detection
- Submit for review button

#### 2. **Image Handling**
- Pick multiple images from gallery
- Image compression before upload
- Grid preview with remove option
- Upload progress indicator
- Maximum 10 images limit

#### 3. **Form Validation**
- Required fields: Title, Price, Category, Images
- Price must be positive number
- At least 1 image required
- Location required (auto-detected)

## 🚀 Setup & Usage

### Backend Setup

**1. Install Dependencies**
```bash
cd server
npm install
```

New packages added:
- `multer: ^1.4.5-lts.1` - File uploads
- `uuid: ^9.0.1` - Unique filenames

**2. Create Uploads Directory**
The directory is created automatically, but you can also:
```bash
mkdir -p server/uploads
```

**3. Start Backend**
```bash
npm run dev
```

### Flutter Setup

**1. Install Dependencies**
```bash
cd flutter_app
flutter pub get
```

New packages added:
- `image_picker: ^1.0.7` - Pick images from gallery/camera
- `flutter_image_compress: ^2.1.0` - Compress images
- `http: ^1.2.0` - HTTP multipart requests

**2. Platform Permissions Already Configured**

**Android** (`AndroidManifest.xml`):
- Camera permission
- Read/Write external storage
- Read media images (Android 13+)

**iOS** (`Info.plist`):
- Camera usage description
- Photo library access
- Photo library add usage

**3. Run the App**
```bash
flutter run
```

## 📱 User Flow

### Creating a Post

1. **Navigate to Create Post**
   - From Home Feed → Tap "Sell" FAB button
   - Opens Create Post screen

2. **Add Photos** (Required)
   - Tap "Add Photos" button
   - Select up to 10 images from gallery
   - Images are automatically compressed
   - Preview in 3-column grid
   - Tap X to remove image

3. **Fill Form Fields**
   - **Title** *: e.g., "iPhone 13 Pro Max"
   - **Description**: Detailed item description
   - **Category** *: Select from dropdown
   - **Price** *: Enter amount in ₹
   - **Address**: Auto-detected + manual entry

4. **Submit**
   - Tap "Submit for Review"
   - Images upload first (with progress)
   - Post created with pending status
   - Success dialog shown
   - Redirects back to Home Feed

5. **Approval**
   - Post goes to admin for review
   - Appears in feed after approval
   - User can see in "My Posts" immediately

## 🎨 UI/UX Design

### Create Post Screen Layout

```
┌─────────────────────────────┐
│      Create Ad (AppBar)     │
├─────────────────────────────┤
│ Post Your Ad                │
│ Fill in the details...      │
│                             │
│ Photos * (0/10)             │
│ ┌───┬───┬───┐              │
│ │ + │   │   │   Add Photos  │
│ └───┴───┴───┘              │
│                             │
│ Title *                     │
│ [                        ]  │
│                             │
│ Description                 │
│ [                        ]  │
│ [                        ]  │
│                             │
│ Category *                  │
│ [  Electronics      ▼   ]  │
│                             │
│ Price (₹) *                │
│ [                        ]  │
│                             │
│ Address                     │
│ [                        ]  │
│ ✓ Location detected         │
│                             │
│ [ Submit for Review ]       │
│                             │
│ ℹ️ Your ad will be reviewed│
│    within 24 hours          │
└─────────────────────────────┘
```

### Image Grid

```
┌─────┬─────┬─────┐
│  X  │  X  │  +  │  3x3 Grid
│ IMG │ IMG │ Add │  Remove: Tap X
│     │     │ More│  Add: Tap +
└─────┴─────┴─────┘
```

### Design Features
- **Color Scheme**: Purple gradient primary (#667EEA)
- **Typography**: Inter font (Google Fonts)
- **Form Fields**: Rounded corners (12px), labeled inputs
- **Buttons**: Gradient backgrounds, loading states
- **Icons**: Material Icons for visual clarity
- **Validation**: Inline error messages

## 📡 API Documentation

### Upload Images

**Endpoint:** `POST /api/posts/upload-images`

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data
```

**Body:**
- Field name: `images`
- Multiple files allowed
- Max 10 files
- Max 5MB per file

**Response:**
```json
{
  "success": true,
  "message": "5 image(s) uploaded successfully",
  "data": {
    "images": [
      "/uploads/uuid-123456.jpg",
      "/uploads/uuid-123457.jpg"
    ]
  }
}
```

### Create Post

**Endpoint:** `POST /api/posts/create`

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Body:**
```json
{
  "title": "iPhone 13 Pro Max",
  "description": "Excellent condition, 256GB",
  "category": "Electronics",
  "price": 65000,
  "lat": 12.9716,
  "lng": 77.5946,
  "address": "MG Road, Bangalore",
  "images": [
    "/uploads/uuid-123456.jpg",
    "/uploads/uuid-123457.jpg"
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Your ad has been submitted for review and will appear once approved.",
  "data": {
    "post": {
      "_id": "...",
      "title": "iPhone 13 Pro Max",
      "price": 65000,
      "status": "pending",
      "createdAt": "2025-10-31T...",
      ...
    }
  }
}
```

## 🔒 Validation Rules

### Backend Validation

**Image Upload:**
- File types: JPEG, JPG, PNG, GIF, WEBP
- Max size: 5MB per file
- Max files: 10 images
- Required: At least 1 file

**Create Post:**
- **Title**: Required, max 100 characters
- **Description**: Optional, max 2000 characters
- **Category**: Required, must be from allowed list
- **Price**: Required, must be ≥ 0
- **Latitude**: Required, must be valid (-90 to 90)
- **Longitude**: Required, must be valid (-180 to 180)
- **Images**: Optional array of strings

### Frontend Validation

- **Title**: Cannot be empty
- **Price**: Must be positive number
- **Category**: Must select one
- **Images**: At least 1 required
- **Location**: Must be detected/available

## 🗂️ File Structure

### Backend Files

```
server/
├── src/
│   ├── middleware/
│   │   └── uploadMiddleware.js      # Multer config
│   ├── controllers/
│   │   └── postController.js        # Upload & create handlers
│   ├── routes/
│   │   └── postRoutes.js            # Upload route
│   ├── models/
│   │   └── Post.js                  # Updated with status field
│   └── app.js                       # Serve static files
├── uploads/                         # Uploaded images (gitignored)
└── package.json                     # Updated dependencies
```

### Frontend Files

```
flutter_app/lib/
├── screens/
│   └── posting/
│       └── create_post_screen.dart  # Main create post UI
├── core/services/
│   └── post_service.dart            # Updated with upload method
├── providers/
│   └── post_provider.dart           # Create post logic
└── main.dart                        # Added route
```

## 🧪 Testing

### Backend Testing

**1. Test Image Upload**
```bash
curl -X POST http://localhost:5000/api/posts/upload-images \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "images=@image1.jpg" \
  -F "images=@image2.jpg"
```

**2. Test Create Post**
```bash
curl -X POST http://localhost:5000/api/posts/create \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Item",
    "description": "Test description",
    "category": "Electronics",
    "price": 5000,
    "lat": 12.9716,
    "lng": 77.5946,
    "images": ["/uploads/test.jpg"]
  }'
```

### Frontend Testing

**1. Test Image Selection**
- Open create post screen
- Tap "Add Photos"
- Select multiple images
- Verify grid preview
- Test remove functionality

**2. Test Form Validation**
- Try submitting empty form → Should show errors
- Fill only title → Should require price/images
- Enter negative price → Should show error

**3. Test Full Flow**
1. Add 2-3 images
2. Fill all fields
3. Submit post
4. Verify success dialog
5. Check "My Posts" for pending post
6. Admin approves → Check feed

## 📊 Database Schema

### Updated Post Model

```javascript
{
  _id: ObjectId,
  title: String (required, max 100),
  description: String (max 2000),
  price: Number (required, ≥ 0),
  category: String (required, enum),
  images: [String] (max 10),
  location: {
    type: "Point",
    coordinates: [Number, Number],
    address: String
  },
  createdBy: ObjectId (User),
  status: String (enum: pending/approved/rejected/sold/inactive),
  views: Number,
  favorites: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### Status Workflow

```
User Creates Post
      ↓
  [pending]
      ↓
 Admin Reviews
   ↙     ↘
[approved] [rejected]
      ↓
 Visible in Feed
      ↓
User Marks as Sold
      ↓
    [sold]
```

## ⚠️ Important Notes

### Image Storage

**Current Setup** (Development):
- Images stored locally in `/server/uploads/`
- Served as static files via Express
- URLs: `http://localhost:5000/uploads/filename.jpg`

**Production Recommendation**:
- Use cloud storage (AWS S3, Cloudinary, Firebase Storage)
- CDN for faster image delivery
- Image optimization pipeline
- Automatic backup

### Admin Approval

**Current Implementation**:
- New posts have `status: "pending"`
- Feed only shows `status: "approved"`
- Manual admin approval required

**Future Enhancement**:
- Build admin dashboard
- Approve/Reject interface
- Bulk actions
- Auto-approval based on user reputation

### Performance Considerations

- ✅ Image compression (70% quality, max 1024x1024)
- ✅ MongoDB indexing on status field
- ✅ Geospatial queries optimized
- ⏳ Consider lazy loading for image grids
- ⏳ Implement pagination for large datasets

## 🐛 Troubleshooting

### Backend Issues

**Images not uploading:**
1. Check `uploads/` directory exists
2. Verify file permissions
3. Check file size < 5MB
4. Ensure correct file types

**Error: "LIMIT_FILE_SIZE":**
- File exceeds 5MB limit
- Compress images before upload

**Error: "Only image files are allowed":**
- Check file extension
- Ensure mimetype is image/*

### Frontend Issues

**Image picker not working:**
1. Check platform permissions granted
2. Verify `image_picker` package installed
3. Test on physical device (not just simulator)

**Upload fails:**
1. Check JWT token is valid
2. Verify backend is running
3. Check network connectivity
4. Ensure API URL correct

**Images not compressing:**
1. Verify `flutter_image_compress` installed
2. Check file path is valid
3. Try without compression first

## 📈 Future Enhancements

Planned features:
- [ ] Admin Dashboard for post approval
- [ ] Edit existing posts
- [ ] Delete posts
- [ ] Mark as sold
- [ ] Share posts
- [ ] Report inappropriate content
- [ ] Post expiry dates
- [ ] Featured/Promoted posts
- [ ] Image cropping tool
- [ ] Video upload support
- [ ] Draft posts
- [ ] Post analytics (views, favorites)

## ✅ Checklist

Before using Ad Posting feature:

- [ ] Backend dependencies installed (`npm install`)
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] Permissions configured (camera, storage)
- [ ] Location services working
- [ ] Backend running on port 5000
- [ ] Test user logged in
- [ ] Sample posts seeded (with approved status)

## 🎊 Success!

You now have a complete Ad Posting system with:
- Multi-image upload with compression
- Admin approval workflow
- Form validation
- Location tagging
- Professional UI/UX

Users can create beautiful classified ads that go through review before appearing in the feed!

---

**Next Steps**: Build admin dashboard for post approval and management.

**Happy Posting! 🚀**

