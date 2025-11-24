const jwt = require('jsonwebtoken');
const Admin = require('../models/Admin');

// Protect admin routes - verify JWT token
const protectAdmin = async (req, res, next) => {
  let token;

  // Check for token in Authorization header
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      // Get token from header
      token = req.headers.authorization.split(' ')[1];

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Get admin from token (excluding password)
      req.admin = await Admin.findById(decoded.id).select('-password');

      if (!req.admin) {
        return res.status(401).json({
          success: false,
          message: 'Admin not found',
        });
      }

      // Check if admin is active
      if (!req.admin.isActive) {
        return res.status(403).json({
          success: false,
          message: 'Admin account is deactivated',
        });
      }

      next();
    } catch (error) {
      console.error('Admin auth middleware error:', error);

      if (error.name === 'TokenExpiredError') {
        return res.status(401).json({
          success: false,
          message: 'Token expired',
        });
      }

      return res.status(401).json({
        success: false,
        message: 'Not authorized to access this route',
      });
    }
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized, no token provided',
    });
  }
};

// Check if admin has super-admin role
const requireSuperAdmin = async (req, res, next) => {
  if (req.admin && req.admin.role === 'super-admin') {
    next();
  } else {
    return res.status(403).json({
      success: false,
      message: 'Access denied. Super admin privileges required.',
    });
  }
};

module.exports = { protectAdmin, requireSuperAdmin };

