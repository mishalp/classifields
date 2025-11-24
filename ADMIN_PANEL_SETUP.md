# 🎯 Admin Panel - Complete Setup Guide

This guide will help you set up and run the Admin Panel for the Classifieds Marketplace.

## 📋 Prerequisites

- Node.js (v16 or higher)
- MongoDB running
- Backend server configured

## 🚀 Quick Start

### Step 1: Create Admin User (First Time Only)

```bash
cd server
npm run seed:admin
```

This will create a default admin user:
- **Email**: `admin@classifieds.com`
- **Password**: `Admin@123456`

**⚠️ IMPORTANT**: Change this password after first login!

### Step 2: Start Backend Server

```bash
cd server
npm run dev
```

Backend will run on `http://localhost:5000`

### Step 3: Create Environment File

```bash
cd admin-panel
cat > .env << EOF
VITE_API_URL=http://localhost:5000/api
EOF
```

### Step 4: Start Admin Panel

```bash
cd admin-panel
npm run dev
```

Admin panel will open at `http://localhost:5173`

## 🎨 Usage

### Login

1. Open `http://localhost:5173`
2. You'll be redirected to the login page
3. Use the default credentials:
   - Email: `admin@classifieds.com`
   - Password: `Admin@123456`

### Dashboard

After login, you'll see:
- **Total Users**: Number of registered users
- **Pending Ads**: Ads awaiting approval
- **Approved Ads**: Live ads on the platform
- **Rejected Ads**: Rejected ads
- **New Users This Week**: Recent registrations
- **New Posts This Week**: Recent submissions

### Ads Review

Click "Ads Review" in the sidebar to:
- View all pending advertisements
- Search and filter ads
- See ad details (image, title, price, location, user)
- **Approve** ads to make them live
- **Reject** ads to remove them

### Features

✅ **Real-time Updates**: Changes reflect immediately
✅ **Search & Filter**: Find ads by title or category
✅ **Pagination**: Navigate through multiple pages
✅ **Dark Mode**: Toggle theme in the header
✅ **Responsive**: Works on mobile, tablet, and desktop

## 🔐 Security

### Token Management
- JWT tokens are stored in `localStorage`
- Tokens are automatically included in API requests
- Expired tokens trigger automatic logout

### Admin Roles
- **admin**: Can approve/reject ads, view stats
- **super-admin**: All admin permissions (future: manage other admins)

## 📊 API Endpoints

### Authentication
- `POST /api/admin/login` - Login with email/password
- `GET /api/admin/me` - Get current admin profile

### Dashboard
- `GET /api/admin/overview` - Dashboard statistics

### Ads Management
- `GET /api/admin/posts/pending?page=1&limit=10&search=` - Get pending posts
- `PATCH /api/admin/posts/:id/approve` - Approve a post
- `PATCH /api/admin/posts/:id/reject` - Reject a post

### Users (Coming Soon)
- `GET /api/admin/users` - Get all users

## 🎨 UI Components

Built with **shadcn/ui** components:
- `Button` - Various styles and sizes
- `Card` - Content containers
- `Input` - Form inputs
- `Badge` - Status indicators
- `Label` - Form labels

Styled with **Tailwind CSS** for modern, responsive design.

## 🔧 Development

### Project Structure

```
admin-panel/
├── src/
│   ├── components/         # Reusable components
│   │   ├── ui/            # shadcn/ui components
│   │   └── ProtectedRoute.jsx
│   ├── context/           # React context
│   │   └── AuthContext.jsx
│   ├── layouts/           # Layout components
│   │   └── AdminLayout.jsx
│   ├── lib/              # Utilities
│   │   ├── axios.js      # API client
│   │   └── utils.js      # Helper functions
│   ├── pages/            # Page components
│   │   ├── Login.jsx
│   │   ├── Dashboard.jsx
│   │   └── AdsReview.jsx
│   ├── App.jsx           # Main app with routing
│   └── main.jsx          # Entry point
```

### Adding New Routes

1. Create a new page in `src/pages/`
2. Add route in `src/App.jsx`:
   ```jsx
   <Route path="new-feature" element={<NewFeature />} />
   ```
3. Add to sidebar in `src/layouts/AdminLayout.jsx`:
   ```jsx
   { name: 'New Feature', path: '/new-feature', icon: Icon }
   ```

### Customizing Theme

Edit `src/index.css` and `tailwind.config.js` to change colors:

```css
:root {
  --primary: 221.2 83.2% 53.3%;  /* Blue */
  --destructive: 0 84.2% 60.2%;  /* Red */
  /* Add more colors... */
}
```

## 🐛 Troubleshooting

### Can't Login

**Problem**: "Invalid credentials" error

**Solutions**:
1. Ensure you ran `npm run seed:admin`
2. Check MongoDB is running
3. Verify backend is running on port 5000

### API Connection Failed

**Problem**: Network errors or 404s

**Solutions**:
1. Check backend server is running: `cd server && npm run dev`
2. Verify `.env` has correct API URL: `VITE_API_URL=http://localhost:5000/api`
3. Check CORS is enabled on backend

### Blank Dashboard

**Problem**: No data showing

**Solutions**:
1. Create test posts using Flutter app
2. Run seed script: `cd server && npm run seed`
3. Check browser console for errors

### Dark Mode Not Working

**Problem**: Theme doesn't change

**Solution**:
- Refresh the page
- Check browser console for errors

## 📱 Testing

### Manual Testing Checklist

- [ ] Login with correct credentials
- [ ] Login fails with wrong credentials
- [ ] Dashboard shows correct statistics
- [ ] Can view pending ads
- [ ] Can approve an ad
- [ ] Can reject an ad
- [ ] Search works in ads table
- [ ] Pagination works
- [ ] Dark mode toggle works
- [ ] Logout works
- [ ] Protected routes redirect to login
- [ ] Responsive on mobile

## 🎯 Next Steps

### Planned Features

1. **Users Management**
   - View all users
   - Ban/unban users
   - View user activity

2. **Analytics**
   - Charts and graphs
   - Revenue tracking
   - User growth metrics

3. **Settings**
   - Change password
   - Email notifications
   - Platform settings

4. **Bulk Actions**
   - Select multiple ads
   - Approve/reject in bulk
   - Export data

5. **Notifications**
   - Real-time notifications
   - Toast messages
   - Email alerts

## 💡 Tips

- Use `React Query DevTools` for debugging (uncomment in App.jsx)
- Check Network tab in browser DevTools for API calls
- Use Redux DevTools Extension for state inspection
- Enable React DevTools for component debugging

## 📚 Resources

- [React Documentation](https://react.dev/)
- [Tailwind CSS](https://tailwindcss.com/)
- [shadcn/ui](https://ui.shadcn.com/)
- [TanStack Query](https://tanstack.com/query/)
- [React Router](https://reactrouter.com/)
- [Framer Motion](https://www.framer.com/motion/)

## 🤝 Contributing

To contribute:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - See LICENSE file for details

---

**Need Help?** Check the troubleshooting section or open an issue on GitHub.

