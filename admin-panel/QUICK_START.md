# ⚡ Admin Panel - Quick Start

Get the admin panel running in 3 minutes!

## 🚀 Prerequisites

✅ Backend server must be running
✅ MongoDB must be running
✅ Admin user must exist in database

## 📝 Step-by-Step

### 1️⃣ Create Admin User (First Time Only)

```bash
cd ../server
npm run seed:admin
```

Output:
```
✅ Admin user created successfully
Email: admin@classifieds.com
Password: Admin@123456
```

### 2️⃣ Create Environment File

```bash
# In admin-panel directory
echo "VITE_API_URL=http://localhost:5000/api" > .env
```

### 3️⃣ Install & Run

```bash
# Install dependencies (first time only)
npm install

# Start dev server
npm run dev
```

## 🎉 Done!

Open your browser:
```
http://localhost:5173
```

Login with:
- **Email**: admin@classifieds.com
- **Password**: Admin@123456

---

## 🎯 What You Can Do

### Dashboard
- View total users, ads, and statistics
- See weekly growth metrics
- Access quick actions

### Ads Review
- View all pending advertisements
- Search and filter ads
- Approve or reject ads
- See user information and ad details

### Theme Toggle
Click the moon/sun icon in the header to switch between light and dark mode

---

## ⚙️ Configuration

### Change API URL

Edit `.env`:
```env
VITE_API_URL=http://your-api-url.com/api
```

### Change Port

```bash
npm run dev -- --port 3000
```

---

## 🐛 Troubleshooting

### Can't Login?

1. Make sure backend is running:
   ```bash
   curl http://localhost:5000/api/health
   ```

2. Verify admin user exists:
   ```bash
   cd ../server
   npm run seed:admin
   ```

### API Connection Error?

Check `.env` file has correct URL:
```bash
cat .env
# Should show: VITE_API_URL=http://localhost:5000/api
```

### Blank Page?

1. Clear browser cache
2. Check browser console for errors (F12)
3. Verify backend is running

---

## 📱 Features

✨ **Authentication**
- Secure JWT-based login
- Auto-logout on token expiry
- Protected routes

✨ **Dashboard**
- Real-time KPIs
- Beautiful card layouts
- Quick action links

✨ **Ads Review**
- TanStack Table with pagination
- Search and filter
- Image thumbnails
- One-click approve/reject
- Real-time updates

✨ **UI/UX**
- Modern design (Vercel/Linear inspired)
- Dark mode support
- Smooth animations
- Fully responsive
- Mobile-friendly sidebar

---

## 🎨 Tech Stack

- **Framework**: React 18 + Vite
- **Styling**: Tailwind CSS
- **Components**: shadcn/ui
- **Routing**: React Router v6
- **State**: TanStack Query
- **Forms**: React Hook Form
- **Animations**: Framer Motion
- **Icons**: Lucide React

---

## 📚 Learn More

- [Full Documentation](./README.md)
- [Setup Guide](../ADMIN_PANEL_SETUP.md)
- [Complete Setup](../COMPLETE_SETUP_GUIDE.md)

---

**Need Help?** Check the troubleshooting section or open an issue!

