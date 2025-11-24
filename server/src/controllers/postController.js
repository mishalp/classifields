const Post = require('../models/Post');
const User = require('../models/User');
const path = require('path');

// @desc    Get post by ID (Ad Details)
// @route   GET /api/posts/:id
// @access  Private
const getPostById = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id)
      .populate('createdBy', 'name email location createdAt');

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    // Calculate if this is user's own post
    const isOwnPost = post.createdBy._id.toString() === req.user.id;

    res.status(200).json({
      success: true,
      data: {
        post,
        isOwnPost,
      },
    });
  } catch (error) {
    console.error('Get post by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching post',
      error: error.message,
    });
  }
};

// @desc    Get user's own posts
// @route   GET /api/posts/my-posts?status=<status>
// @access  Private
const getMyPosts = async (req, res) => {
  try {
    const { status } = req.query;

    const query = { createdBy: req.user.id };

    // Add status filter if provided
    if (status && status !== 'all') {
      query.status = status;
    }

    const posts = await Post.find(query)
      .sort({ createdAt: -1 })
      .populate('createdBy', 'name email');

    // Get status counts
    const statusCounts = await Post.aggregate([
      { $match: { createdBy: req.user._id } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
        },
      },
    ]);

    const counts = {
      all: 0,
      pending: 0,
      approved: 0,
      rejected: 0,
    };

    statusCounts.forEach(({ _id, count }) => {
      counts[_id] = count;
      counts.all += count;
    });

    res.status(200).json({
      success: true,
      count: posts.length,
      data: {
        posts,
        statusCounts: counts,
      },
    });
  } catch (error) {
    console.error('Get my posts error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching user posts',
      error: error.message,
    });
  }
};

// @desc    Get nearby posts with search, category filters, and sorting
// @route   GET /api/posts/nearby?lat=<latitude>&lng=<longitude>&radius=<km>&limit=<number>&search=<text>&category=<category>&sort=<sort>
// @access  Private
const getNearbyPosts = async (req, res) => {
  try {
    const { lat, lng, radius = 10, limit = 20, search, category, sort = 'newest' } = req.query;

    // Validate coordinates
    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Please provide latitude and longitude',
      });
    }

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    if (
      isNaN(latitude) ||
      isNaN(longitude) ||
      latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180
    ) {
      return res.status(400).json({
        success: false,
        message: 'Invalid coordinates',
      });
    }

    const radiusInKm = parseFloat(radius);
    const limitNum = parseInt(limit);

    // Validate sort parameter
    const validSortOptions = ['newest', 'price_asc', 'price_desc', 'nearest'];
    const sortOption = validSortOptions.includes(sort) ? sort : 'newest';

    // Get nearby posts with optional search, category filters, and sorting
    const posts = await Post.getNearby(
      latitude,
      longitude,
      radiusInKm,
      limitNum,
      search || null,
      category || null,
      sortOption
    );

    res.status(200).json({
      success: true,
      count: posts.length,
      data: {
        posts,
        filters: {
          search: search || null,
          category: category || null,
          sort: sortOption,
        },
      },
    });
  } catch (error) {
    console.error('Get nearby posts error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching posts',
      error: error.message,
    });
  }
};

// @desc    Upload images
// @route   POST /api/posts/upload-images
// @access  Private
const uploadImages = async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No images uploaded',
      });
    }

    // Generate URLs for uploaded files
    const imageUrls = req.files.map(file => {
      // Return relative path that can be served by Express static middleware
      return `/uploads/${file.filename}`;
    });

    res.status(200).json({
      success: true,
      message: `${req.files.length} image(s) uploaded successfully`,
      data: {
        images: imageUrls,
      },
    });
  } catch (error) {
    console.error('Upload images error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while uploading images',
      error: error.message,
    });
  }
};

// @desc    Create a new post
// @route   POST /api/posts/create
// @access  Private
const createPost = async (req, res) => {
  try {
    const { title, description, price, category, lat, lng, address, images } = req.body;

    // Validate required fields
    if (!title || !price || !category || !lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Please provide title, price, category, latitude, and longitude',
      });
    }

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    if (
      isNaN(latitude) ||
      isNaN(longitude) ||
      latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180
    ) {
      return res.status(400).json({
        success: false,
        message: 'Invalid coordinates',
      });
    }

    // Create post with pending status
    const post = await Post.create({
      title,
      description: description || '',
      price: parseFloat(price),
      category,
      location: {
        type: 'Point',
        coordinates: [longitude, latitude],
        address: address || '',
      },
      images: images || [],
      createdBy: req.user.id,
      status: 'pending', // Set to pending for admin approval
    });

    // Populate creator info
    await post.populate('createdBy', 'name email location');

    res.status(201).json({
      success: true,
      message: 'Your ad has been submitted for review and will appear once approved.',
      data: {
        post,
      },
    });
  } catch (error) {
    console.error('Create post error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating post',
      error: error.message,
    });
  }
};

// @desc    Update post
// @route   PUT /api/posts/:id
// @access  Private
const updatePost = async (req, res) => {
  try {
    let post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    // Check if user owns the post
    if (post.createdBy.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this post',
      });
    }

    const { title, description, price, category, status, images } = req.body;

    // Update fields
    if (title) post.title = title;
    if (description !== undefined) post.description = description;
    if (price) post.price = price;
    if (category) post.category = category;
    if (status) post.status = status;
    if (images) post.images = images;

    await post.save();
    await post.populate('createdBy', 'name email location');

    res.status(200).json({
      success: true,
      message: 'Post updated successfully',
      data: {
        post,
      },
    });
  } catch (error) {
    console.error('Update post error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating post',
      error: error.message,
    });
  }
};

// @desc    Delete post
// @route   DELETE /api/posts/:id
// @access  Private
const deletePost = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    // Check if user owns the post
    if (post.createdBy.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this post',
      });
    }

    await post.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Post deleted successfully',
    });
  } catch (error) {
    console.error('Delete post error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting post',
      error: error.message,
    });
  }
};

module.exports = {
  getNearbyPosts,
  createPost,
  uploadImages,
  getPostById,
  getMyPosts,
  updatePost,
  deletePost,
};

