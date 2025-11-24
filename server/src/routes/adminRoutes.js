const express = require('express');
const router = express.Router();
const {
  adminLogin,
  getAdminProfile,
  getDashboardOverview,
  getPosts,
  getPendingPosts,
  approvePost,
  rejectPost,
  getAllUsers,
} = require('../controllers/adminController');
const { protectAdmin } = require('../middleware/adminMiddleware');

// Public routes
router.post('/login', adminLogin);

// Protected routes (require admin authentication)
router.get('/me', protectAdmin, getAdminProfile);
router.get('/overview', protectAdmin, getDashboardOverview);
router.get('/posts', protectAdmin, getPosts); // New: Get posts with optional status filter
router.get('/posts/pending', protectAdmin, getPendingPosts); // Backward compatibility
router.patch('/posts/:id/approve', protectAdmin, approvePost);
router.patch('/posts/:id/reject', protectAdmin, rejectPost);
router.get('/users', protectAdmin, getAllUsers);

module.exports = router;

