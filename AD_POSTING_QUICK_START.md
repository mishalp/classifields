# ⚡ Ad Posting - Quick Start

Get ad posting with multi-image upload running in 5 minutes!

## 🚀 Quick Setup

### 1. Install Backend Dependencies (1 min)

```bash
cd server
npm install
```

New packages: `multer`, `uuid`

### 2. Install Flutter Dependencies (1 min)

```bash
cd flutter_app
flutter pub get
```

New packages: `image_picker`, `flutter_image_compress`, `http`

### 3. Re-Seed Database (1 min)

```bash
cd server
npm run seed
```

This updates existing posts to `approved` status so they appear in feed.

### 4. Run Everything (2 min)

**Terminal 1 - Backend:**
```bash
cd server
npm run dev
```

**Terminal 2 - Flutter:**
```bash
cd flutter_app
flutter run
```

## 📱 Test Flow (2 minutes)

1. **Login** → Sign in with your account
2. **Home Feed** → See existing approved posts
3. **Tap "Sell" FAB** → Opens Create Post screen
4. **Add Photos** → Select 2-3 images from gallery
5. **Fill Form:**
   - Title: "Test Item"
   - Category: Electronics
   - Price: 5000
   - Description: "Test description"
6. **Submit** → Wait for upload & creation
7. **Success Dialog** → Post submitted for review
8. **Check "My Posts"** → Should see pending post

## 🎯 What You Get

### Backend Features
- ✅ Multi-image upload API (up to 10 images)
- ✅ Image storage in `/uploads` directory
- ✅ File validation (size, type)
- ✅ Pending/Approved status workflow
- ✅ Only approved posts in feed

### Flutter Features
- ✅ Create Post screen with form
- ✅ Image picker (multi-select)
- ✅ Image compression
- ✅ Grid preview with remove option
- ✅ Form validation
- ✅ Upload progress
- ✅ Success/Error handling
- ✅ Location auto-detection

## 📸 Permissions

Already configured in:
- `android/app/src/main/AndroidManifest.xml` (Camera, Storage)
- `ios/Runner/Info.plist` (Camera, Photo Library)

Just grant permission when app requests!

## 🔌 New API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/posts/upload-images` | POST | Upload multiple images |
| `/api/posts/create` | POST | Create post (status: pending) |
| `/api/posts/nearby` | GET | Get approved posts only |

## 🎨 UI Flow

```
Home Feed → Tap "Sell" FAB
              ↓
   Create Post Screen
              ↓
    Select Images (1-10)
              ↓
    Fill Form (Title, Price, etc.)
              ↓
    Submit for Review
              ↓
    Uploading Images... (with progress)
              ↓
    Creating Post...
              ↓
    Success Dialog! 🎉
              ↓
    Back to Home Feed
```

## 📂 Key Files Created

### Backend
```
server/src/middleware/uploadMiddleware.js  # Multer config
server/src/controllers/postController.js   # Upload endpoint
server/uploads/                            # Image storage
```

### Flutter
```
flutter_app/lib/screens/posting/create_post_screen.dart  # UI
flutter_app/lib/core/services/post_service.dart          # Upload API
```

## ⚠️ Important Notes

### Post Status Flow
1. User creates post → **pending**
2. Admin reviews post → **approved** or **rejected**
3. Approved posts → **visible in feed**
4. Pending posts → **visible in "My Posts" only**

### Image Storage
- Development: Local `/uploads` folder
- Production: Use AWS S3 or Cloudinary

### Approval Process
- Manual approval required (admin dashboard coming soon)
- For testing: Manually update post status in MongoDB
```javascript
db.posts.updateOne(
  { _id: ObjectId("YOUR_POST_ID") },
  { $set: { status: "approved" } }
)
```

## 🧪 Testing Tips

**Test Image Upload:**
```bash
# From terminal (requires curl and test image)
curl -X POST http://localhost:5000/api/posts/upload-images \
  -H "Authorization: Bearer YOUR_JWT" \
  -F "images=@test.jpg"
```

**Check Uploaded Images:**
```bash
ls -la server/uploads/
```

**View Image in Browser:**
```
http://localhost:5000/uploads/filename.jpg
```

## 🐛 Quick Fixes

**Can't select images?**
- Check permissions granted
- Try physical device (not just emulator)
- Verify `image_picker` installed

**Upload fails?**
- Check backend is running
- Verify JWT token valid
- Ensure images < 5MB each

**Images not compressing?**
- Check `flutter_image_compress` installed
- Verify file path accessible

**Posts not in feed?**
- Check post status is `approved`
- Re-run seed script: `npm run seed`
- Verify nearby query filters

## 📊 Status Values

| Status | Description | Visible in Feed? |
|--------|-------------|------------------|
| pending | Just created | ❌ No |
| approved | Admin approved | ✅ Yes |
| rejected | Admin rejected | ❌ No |
| sold | Marked as sold | ❌ No |
| inactive | User deactivated | ❌ No |

## ✅ Verification Checklist

After setup, verify:

- [ ] Can open Create Post screen
- [ ] Can select multiple images
- [ ] Images show in grid preview
- [ ] Can remove selected images
- [ ] Form validation works
- [ ] Location detected
- [ ] Submit button uploads images
- [ ] Success dialog appears
- [ ] Post created with pending status
- [ ] Can see post in "My Posts"

## 🎯 Next Actions

1. **Test Create Post** → Submit a test ad
2. **Approve Manually** → Update status in MongoDB
3. **Check Feed** → Verify approved post appears
4. **Build Admin Panel** → Next feature to implement

## 📚 Full Documentation

- [AD_POSTING_GUIDE.md](AD_POSTING_GUIDE.md) - Complete guide
- [HOME_FEED_GUIDE.md](HOME_FEED_GUIDE.md) - Feed documentation
- [README.md](README.md) - Project overview

## 🎊 You're Ready!

The ad posting system is fully functional! Users can create posts with multiple images that go through approval before appearing in the feed.

**Happy Selling! 🚀**

