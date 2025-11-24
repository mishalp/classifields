const express = require('express');
const { body, param, query } = require('express-validator');
const {
  getNearbyPosts,
  createPost,
  uploadImages,
  getPostById,
  getMyPosts,
  updatePost,
  deletePost,
} = require('../controllers/postController');
const { protect } = require('../middleware/authMiddleware');
const { validate } = require('../middleware/validationMiddleware');
const { uploadImages: uploadMiddleware, handleUploadError } = require('../middleware/uploadMiddleware');

const router = express.Router();

// Validation rules
const createPostValidation = [
  body('title')
    .trim()
    .notEmpty()
    .withMessage('Title is required')
    .isLength({ max: 100 })
    .withMessage('Title cannot exceed 100 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 2000 })
    .withMessage('Description cannot exceed 2000 characters'),
  body('price')
    .notEmpty()
    .withMessage('Price is required')
    .isFloat({ min: 0 })
    .withMessage('Price must be a positive number'),
  body('category')
    .notEmpty()
    .withMessage('Category is required')
    .isIn([
      'Electronics',
      'Furniture',
      'Vehicles',
      'Real Estate',
      'Fashion',
      'Books',
      'Sports',
      'Home & Garden',
      'Toys & Games',
      'Services',
      'Other',
    ])
    .withMessage('Invalid category'),
  body('lat')
    .notEmpty()
    .withMessage('Latitude is required')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Invalid latitude'),
  body('lng')
    .notEmpty()
    .withMessage('Longitude is required')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Invalid longitude'),
  body('address').optional().trim(),
  body('images')
    .optional()
    .isArray()
    .withMessage('Images must be an array')
    .custom((value) => value.length <= 10)
    .withMessage('Cannot upload more than 10 images'),
];

const updatePostValidation = [
  param('id').isMongoId().withMessage('Invalid post ID'),
  body('title')
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage('Title cannot exceed 100 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 2000 })
    .withMessage('Description cannot exceed 2000 characters'),
  body('price')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Price must be a positive number'),
  body('category')
    .optional()
    .isIn([
      'Electronics',
      'Furniture',
      'Vehicles',
      'Real Estate',
      'Fashion',
      'Books',
      'Sports',
      'Home & Garden',
      'Toys & Games',
      'Services',
      'Other',
    ])
    .withMessage('Invalid category'),
  body('status')
    .optional()
    .isIn(['active', 'sold', 'inactive'])
    .withMessage('Invalid status'),
  body('images')
    .optional()
    .isArray()
    .withMessage('Images must be an array'),
];

const nearbyPostsValidation = [
  query('lat')
    .notEmpty()
    .withMessage('Latitude is required')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Invalid latitude'),
  query('lng')
    .notEmpty()
    .withMessage('Longitude is required')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Invalid longitude'),
  query('radius')
    .optional()
    .isFloat({ min: 0.1, max: 100 })
    .withMessage('Radius must be between 0.1 and 100 km'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
];

const postIdValidation = [
  param('id').isMongoId().withMessage('Invalid post ID'),
];

// Routes
router.get('/nearby', protect, nearbyPostsValidation, validate, getNearbyPosts);
router.post('/upload-images', protect, uploadMiddleware, handleUploadError, uploadImages);
router.post('/create', protect, createPostValidation, validate, createPost);
router.get('/my-posts', protect, getMyPosts);
router.get('/:id', protect, postIdValidation, validate, getPostById);
router.put('/:id', protect, updatePostValidation, validate, updatePost);
router.delete('/:id', protect, postIdValidation, validate, deletePost);

module.exports = router;

