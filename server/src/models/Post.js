const mongoose = require('mongoose');

const postSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Please provide a title'],
      trim: true,
      maxlength: [100, 'Title cannot exceed 100 characters'],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [2000, 'Description cannot exceed 2000 characters'],
    },
    price: {
      type: Number,
      required: [true, 'Please provide a price'],
      min: [0, 'Price cannot be negative'],
    },
    images: {
      type: [String],
      default: [],
      validate: {
        validator: function(v) {
          return v.length <= 10;
        },
        message: 'Cannot upload more than 10 images',
      },
    },
    category: {
      type: String,
      required: [true, 'Please provide a category'],
      enum: [
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
      ],
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        required: true,
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        required: true,
      },
      address: {
        type: String,
        trim: true,
      },
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected', 'sold', 'inactive'],
      default: 'pending',
    },
    views: {
      type: Number,
      default: 0,
    },
    favorites: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Create 2dsphere index for geospatial queries
postSchema.index({ location: '2dsphere' });

// Index for efficient queries
postSchema.index({ status: 1, createdAt: -1 });
postSchema.index({ category: 1, status: 1 });
postSchema.index({ createdBy: 1, status: 1 });

// Text index for search functionality
postSchema.index({ title: 'text', description: 'text' });

// Method to increment views
postSchema.methods.incrementViews = async function() {
  this.views += 1;
  await this.save();
};

// Static method to get nearby posts with search, category filters, and sorting
postSchema.statics.getNearby = async function(
  latitude,
  longitude,
  radiusInKm = 10,
  limit = 20,
  search = null,
  category = null,
  sort = 'newest'
) {
  const radiusInMeters = radiusInKm * 1000;
  
  // Build the base query
  const query = { status: 'approved' };
  
  // Add category filter if provided
  if (category) {
    query.category = category;
  }
  
  // Build aggregation pipeline
  const pipeline = [
    {
      $geoNear: {
        near: {
          type: 'Point',
          coordinates: [parseFloat(longitude), parseFloat(latitude)],
        },
        distanceField: 'distance',
        maxDistance: radiusInMeters,
        spherical: true,
        query: query,
      },
    },
  ];
  
  // Add text search if provided
  if (search) {
    pipeline.push({
      $match: {
        $or: [
          { title: { $regex: search, $options: 'i' } },
          { description: { $regex: search, $options: 'i' } },
        ],
      },
    });
  }
  
  // Determine sort order based on sort parameter
  let sortStage = {};
  switch (sort) {
    case 'price_asc':
      sortStage = { price: 1, createdAt: -1 };
      break;
    case 'price_desc':
      sortStage = { price: -1, createdAt: -1 };
      break;
    case 'nearest':
      sortStage = { distance: 1, createdAt: -1 };
      break;
    case 'newest':
    default:
      sortStage = { createdAt: -1, distance: 1 };
      break;
  }
  
  // Add sorting, limit, and joins
  pipeline.push(
    {
      $sort: sortStage,
    },
    {
      $limit: limit,
    },
    {
      $lookup: {
        from: 'users',
        localField: 'createdBy',
        foreignField: '_id',
        as: 'createdBy',
      },
    },
    {
      $unwind: '$createdBy',
    },
    {
      $project: {
        title: 1,
        description: 1,
        price: 1,
        images: 1,
        category: 1,
        location: 1,
        status: 1,
        views: 1,
        favorites: 1,
        createdAt: 1,
        distance: { $round: [{ $divide: ['$distance', 1000] }, 2] },
        'createdBy._id': 1,
        'createdBy.name': 1,
        'createdBy.location': 1,
      },
    }
  );
  
  return this.aggregate(pipeline);
};

module.exports = mongoose.model('Post', postSchema);

