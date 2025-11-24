# 🚀 Search & Category Filter - Quick Start Guide

## ⚡ Quick Setup & Test

### **1. Start Backend Server**
```bash
cd /Users/mohammedmishal/repo/classifieds/server
npm start
```

### **2. Start Flutter App**
```bash
cd /Users/mohammedmishal/repo/classifieds/flutter_app
flutter run
```

---

## 🧪 Test the Features

### **Test 1: Search Functionality**
1. Open the app → Home Feed
2. Tap the search bar at the top
3. Type "chair" or any keyword
4. Wait 500ms → Results update automatically
5. Tap the **X** button to clear search

**Expected Result:** 
- ✅ Only posts matching "chair" appear
- ✅ Search is case-insensitive
- ✅ Searches both title and description

---

### **Test 2: Category Filter**
1. Open the app → Home Feed
2. Scroll through category chips (All, Electronics, Furniture, etc.)
3. Tap **"Electronics"**
4. Results update immediately

**Expected Result:**
- ✅ Only electronics posts appear
- ✅ "Electronics" chip is highlighted
- ✅ Location-based sorting still works

---

### **Test 3: Combined Filters**
1. Type **"laptop"** in search bar
2. Select **"Electronics"** category
3. Both filters are active

**Expected Result:**
- ✅ Only laptop posts in Electronics category
- ✅ "Clear Filters" button appears (if active)
- ✅ Results sorted by distance

---

### **Test 4: Clear Filters**
1. Apply search + category filters
2. Tap the **"Clear Filters"** button (🗑️ icon next to search)
3. OR tap **"All"** in category chips

**Expected Result:**
- ✅ Search bar clears
- ✅ Category resets to "All"
- ✅ Full nearby feed loads

---

### **Test 5: Empty State**
1. Search for something that doesn't exist (e.g., "xyzabc123")
2. See "No Results Found" message
3. Tap **"Clear Filters"** button

**Expected Result:**
- ✅ Shows appropriate empty state
- ✅ Different message for filtered vs. unfiltered
- ✅ Clear button works

---

## 📡 Test API Directly

### **Using cURL:**

```bash
# Get your auth token first (login)
TOKEN="your_jwt_token_here"

# Test 1: Search only
curl -X GET "http://localhost:5000/api/posts/nearby?lat=10.1&lng=76.2&search=laptop" \
  -H "Authorization: Bearer $TOKEN"

# Test 2: Category only
curl -X GET "http://localhost:5000/api/posts/nearby?lat=10.1&lng=76.2&category=Electronics" \
  -H "Authorization: Bearer $TOKEN"

# Test 3: Combined
curl -X GET "http://localhost:5000/api/posts/nearby?lat=10.1&lng=76.2&search=iphone&category=Electronics" \
  -H "Authorization: Bearer $TOKEN"

# Test 4: All nearby (no filters)
curl -X GET "http://localhost:5000/api/posts/nearby?lat=10.1&lng=76.2" \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🎯 Quick Reference

### **Available Categories:**
```
1. All (shows everything)
2. Electronics
3. Furniture
4. Vehicles
5. Real Estate
6. Fashion
7. Books
8. Sports
9. Home & Garden
10. Toys & Games
11. Services
12. Other
```

### **API Query Parameters:**
| Parameter  | Type   | Required | Example                  |
|------------|--------|----------|--------------------------|
| `lat`      | float  | ✅ Yes   | `10.1234`                |
| `lng`      | float  | ✅ Yes   | `76.5678`                |
| `search`   | string | ❌ No    | `laptop`                 |
| `category` | string | ❌ No    | `Electronics`            |
| `radius`   | number | ❌ No    | `50` (default: 10 km)    |
| `limit`    | number | ❌ No    | `20` (default: 20)       |

---

## 🔍 Search Tips for Users

### **What You Can Search:**
- ✅ Product names (e.g., "iPhone 13")
- ✅ Keywords (e.g., "gaming laptop")
- ✅ Brands (e.g., "Samsung")
- ✅ Descriptions (e.g., "excellent condition")

### **Search Best Practices:**
- Use specific keywords
- Try different variations (e.g., "bike" vs "bicycle")
- Combine with category filters for better results
- Use clear button to reset and try again

---

## 🐛 Troubleshooting

### **Problem: Search returns no results**
**Solution:**
- Check if posts exist in database
- Try broader search terms
- Clear filters and try again
- Ensure posts are approved (status: 'approved')

### **Problem: Category filter not working**
**Solution:**
- Check category spelling matches backend enum
- Ensure posts have category assigned
- Verify API response in network inspector

### **Problem: Debounce not working**
**Solution:**
- Wait at least 500ms after typing
- Check console for errors
- Verify Timer is not cancelled prematurely

---

## ✅ Verification Checklist

Before marking complete, verify:

**UI Elements:**
- ✅ Search bar appears at top
- ✅ Category chips scroll horizontally
- ✅ Selected chip is highlighted
- ✅ Clear button appears when filters active

**Functionality:**
- ✅ Search updates after 500ms delay
- ✅ Category filter updates immediately
- ✅ Combined filters work together
- ✅ Clear filters resets everything
- ✅ Empty states show correctly

**Performance:**
- ✅ No lag while typing
- ✅ API calls are debounced
- ✅ Results load quickly
- ✅ Smooth scrolling in feed

---

## 📱 User Experience Flow

```
User Opens App
    ↓
Home Feed Loads (Location-based)
    ↓
User Types "laptop" in Search Bar
    ↓
500ms Debounce Delay
    ↓
API Call: GET /api/posts/nearby?search=laptop
    ↓
Results Update (Only laptops shown)
    ↓
User Selects "Electronics" Category
    ↓
API Call: GET /api/posts/nearby?search=laptop&category=Electronics
    ↓
Results Update (Only laptop electronics)
    ↓
User Taps "Clear Filters" Button
    ↓
Both Filters Clear
    ↓
Full Feed Reloads
```

---

## 🎓 Code Examples

### **Search from Provider:**
```dart
// In your widget
final postProvider = context.read<PostProvider>();

// Set search query
await postProvider.setSearchQuery('laptop');

// Set category
await postProvider.setCategory('Electronics');

// Clear all filters
await postProvider.clearFilters();
```

### **Get Current Filters:**
```dart
final postProvider = context.watch<PostProvider>();

print('Search: ${postProvider.searchQuery}');
print('Category: ${postProvider.selectedCategory}');
```

---

## 🎉 Success Indicators

**You've successfully implemented search & filters when:**

1. ✅ User can search and see relevant results
2. ✅ User can filter by category
3. ✅ User can combine search + category
4. ✅ User can clear filters easily
5. ✅ Empty states show appropriate messages
6. ✅ No lag or performance issues
7. ✅ Debouncing prevents excessive API calls
8. ✅ Location-based sorting still works

---

## 🚀 Next: Test It Now!

**Run the app and try these steps:**

1. Search for "car" → Should show only car-related posts
2. Select "Vehicles" category → Should show only vehicles
3. Do both together → Should show only cars in vehicles
4. Tap clear → Should reset to full feed
5. Search for nonsense → Should show "No Results Found"

**If all 5 steps work → Feature is complete! 🎉**

---

## 📚 Full Documentation

For detailed technical documentation, see:
- **Full Guide**: `SEARCH_FILTER_FEATURE.md`
- **Architecture**: Backend + Frontend implementation details
- **API Reference**: Complete endpoint documentation

---

**Happy Testing! 🔍✨**

