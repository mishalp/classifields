# Classifieds Admin Panel

Modern, responsive admin panel for the Classifieds Marketplace built with React, Vite, Tailwind CSS, and shadcn/ui.

## 🚀 Features

- ✅ **Admin Authentication** - Secure login with JWT
- ✅ **Dashboard** - KPIs and statistics overview
- ✅ **Ads Review** - Approve/reject pending advertisements with TanStack Table
- ✅ **Modern UI** - Built with Tailwind CSS & shadcn/ui components
- ✅ **Dark Mode** - Toggle between light and dark themes
- ✅ **Responsive Design** - Mobile-first approach
- ✅ **Smooth Animations** - Framer Motion animations
- ✅ **Protected Routes** - Role-based access control

## 🛠️ Tech Stack

- **Framework**: React 18 + Vite
- **Styling**: Tailwind CSS
- **Components**: shadcn/ui
- **Routing**: React Router DOM v6
- **State Management**: TanStack Query (React Query)
- **Forms**: React Hook Form + Zod
- **HTTP Client**: Axios
- **Icons**: Lucide React
- **Animations**: Framer Motion

## 📦 Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Create environment file:**
   ```bash
   cp .env.example .env
   ```

3. **Configure the API URL in `.env`:**
   ```env
   VITE_API_URL=http://localhost:5000/api
   ```

## 🚀 Running the App

### Development Mode
```bash
npm run dev
```

The app will be available at `http://localhost:5173`

### Build for Production
```bash
npm run build
```

### Preview Production Build
```bash
npm run preview
```

## 🔑 Default Admin Credentials

For testing purposes, use these default credentials:

- **Email**: `admin@classifieds.com`
- **Password**: `Admin@123456`

> ⚠️ **Important**: Change the default password after first login in production!

## 🗂️ Project Structure

```
admin-panel/
├── src/
│   ├── components/
│   │   ├── ui/              # shadcn/ui components
│   │   └── ProtectedRoute.jsx
│   ├── context/
│   │   └── AuthContext.jsx  # Authentication context
│   ├── layouts/
│   │   └── AdminLayout.jsx  # Main admin layout with sidebar
│   ├── lib/
│   │   ├── axios.js         # Axios instance with interceptors
│   │   └── utils.js         # Utility functions
│   ├── pages/
│   │   ├── Login.jsx        # Login page
│   │   ├── Dashboard.jsx    # Dashboard with KPIs
│   │   └── AdsReview.jsx    # Ads review with table
│   ├── App.jsx              # Main app with routing
│   ├── main.jsx             # Entry point
│   └── index.css            # Global styles
├── .env                     # Environment variables
├── tailwind.config.js       # Tailwind configuration
├── vite.config.js           # Vite configuration
└── package.json
```

## 🎨 Features Breakdown

### 1. Authentication
- JWT-based authentication
- Token stored in localStorage
- Automatic token verification on app load
- Protected routes with redirect to login

### 2. Dashboard
- Real-time statistics:
  - Total users
  - Pending ads
  - Approved ads
  - Rejected ads
  - New users this week
  - New posts this week
- Quick action links
- Responsive card layout

### 3. Ads Review
- View all pending advertisements
- Search and filter functionality
- Approve/Reject actions
- Image thumbnails
- User information
- Location and pricing details
- Pagination
- Real-time updates with React Query

### 4. UI/UX
- Clean, modern design inspired by Vercel and Linear
- Smooth page transitions
- Hover effects and animations
- Responsive sidebar
- Mobile-friendly
- Light/Dark mode toggle

## 🔌 API Endpoints Used

### Admin Authentication
- `POST /api/admin/login` - Admin login
- `GET /api/admin/me` - Get current admin

### Dashboard
- `GET /api/admin/overview` - Get dashboard statistics

### Ads Management
- `GET /api/admin/posts/pending` - Get pending posts
- `PATCH /api/admin/posts/:id/approve` - Approve a post
- `PATCH /api/admin/posts/:id/reject` - Reject a post

## 🎯 Future Features (Placeholders Ready)

The following features have placeholder pages ready for implementation:

- 👥 **Users Management** - View, edit, and manage users
- 📊 **Analytics** - Detailed analytics and reports
- ⚙️ **Settings** - Admin panel settings

## 🔧 Backend Setup

Make sure the backend server is running:

```bash
cd ../server
npm run seed:admin    # Create admin user (one-time)
npm run dev           # Start server
```

## 🎨 Customization

### Colors
Edit theme colors in `tailwind.config.js` and `src/index.css`

### Components
All UI components are in `src/components/ui/` and can be customized

### Layout
Modify sidebar items in `src/layouts/AdminLayout.jsx`

## 📱 Responsive Breakpoints

- Mobile: < 640px
- Tablet: 640px - 1024px
- Desktop: > 1024px

## 🐛 Troubleshooting

### API Connection Issues
- Ensure backend server is running on `http://localhost:5000`
- Check `.env` file has correct `VITE_API_URL`
- Verify CORS is enabled on the backend

### Build Errors
```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Port Already in Use
```bash
# Vite will automatically try the next available port
# Or specify a custom port:
npm run dev -- --port 3000
```

## 📄 License

MIT

## 👨‍💻 Development Notes

- Uses React 18 with the latest features
- Follows modern React patterns (hooks, context, etc.)
- Tailwind CSS for utility-first styling
- shadcn/ui for consistent, accessible components
- TanStack Query for server state management
- React Hook Form for efficient form handling
