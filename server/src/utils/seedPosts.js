require('dotenv').config();
const mongoose = require('mongoose');
const Post = require('../models/Post');
const User = require('../models/User');

// Sample locations around a central point (e.g., Bangalore, India: 12.9716, 77.5946)
const sampleLocations = [
  { lat: 12.9716, lng: 77.5946, address: 'MG Road, Bangalore' },
  { lat: 12.9344, lng: 77.6269, address: 'Koramangala, Bangalore' },
  { lat: 13.0358, lng: 77.5970, address: 'Indiranagar, Bangalore' },
  { lat: 12.9698, lng: 77.7500, address: 'Whitefield, Bangalore' },
  { lat: 12.9599, lng: 77.6968, address: 'HSR Layout, Bangalore' },
  { lat: 13.0199, lng: 77.5643, address: 'Malleshwaram, Bangalore' },
  { lat: 12.9352, lng: 77.6245, address: 'BTM Layout, Bangalore' },
  { lat: 13.0475, lng: 77.5950, address: 'Hebbal, Bangalore' },
];

const samplePosts = [
  {
    title: 'iPhone 13 Pro Max 256GB',
    description: 'Excellent condition, barely used. Includes original box and accessories. Battery health 95%.',
    price: 65000,
    category: 'Electronics',
    images: [],
  },
  {
    title: 'Royal Enfield Classic 350',
    description: '2021 model, well maintained, first owner. All papers clear. Helmet included.',
    price: 125000,
    category: 'Vehicles',
    images: [],
  },
  {
    title: 'Wooden Study Table with Chair',
    description: 'Solid wood table in great condition. Perfect for home office or students.',
    price: 4500,
    category: 'Furniture',
    images: [],
  },
  {
    title: 'Sony PlayStation 5',
    description: 'PS5 with two controllers and 3 games. Barely used, like new condition.',
    price: 48000,
    category: 'Electronics',
    images: [],
  },
  {
    title: '2 BHK Apartment for Rent',
    description: 'Spacious 2 bedroom apartment with parking. Semi-furnished. Immediate possession.',
    price: 18000,
    category: 'Real Estate',
    images: [],
  },
  {
    title: 'Nike Air Max Shoes',
    description: 'Brand new, size 10 US. Never worn. Original packaging.',
    price: 8500,
    category: 'Fashion',
    images: [],
  },
  {
    title: 'Gaming Laptop HP Omen',
    description: 'RTX 3060, 16GB RAM, 512GB SSD. Perfect for gaming and work. 1 year warranty remaining.',
    price: 95000,
    category: 'Electronics',
    images: [],
  },
  {
    title: 'L-Shaped Sofa Set',
    description: 'Grey fabric sofa, 5 seater. Very comfortable and stylish. 2 years old.',
    price: 22000,
    category: 'Furniture',
    images: [],
  },
  {
    title: 'Cricket Kit with Bat',
    description: 'Complete cricket kit with MRF bat, pads, gloves, and helmet. Good condition.',
    price: 6000,
    category: 'Sports',
    images: [],
  },
  {
    title: 'Harry Potter Complete Book Set',
    description: 'All 7 books in excellent condition. Hardcover edition.',
    price: 2500,
    category: 'Books',
    images: [],
  },
  {
    title: 'Samsung 55" 4K Smart TV',
    description: 'Crystal UHD TV with HDR. 1 year old, works perfectly. Wall mount included.',
    price: 42000,
    category: 'Electronics',
    images: [],
  },
  {
    title: 'Mountain Bike - Firefox',
    description: '21-speed gear cycle in great condition. Perfect for daily commute or weekend rides.',
    price: 12000,
    category: 'Sports',
    images: [],
  },
  {
    title: 'Dining Table - 6 Seater',
    description: 'Beautiful wooden dining table with 6 chairs. Excellent condition.',
    price: 18000,
    category: 'Furniture',
    images: [],
  },
  {
    title: 'Canon EOS 1500D DSLR',
    description: 'Camera with 18-55mm lens and bag. Barely used, like new. Perfect for beginners.',
    price: 28000,
    category: 'Electronics',
    images: [],
  },
  {
    title: 'Kids Toy Collection',
    description: 'Various toys including cars, puzzles, and building blocks. All in good condition.',
    price: 1500,
    category: 'Toys & Games',
    images: [],
  },
];

async function seedPosts() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Find or create a test user
    let testUser = await User.findOne({ email: 'test@example.com' });
    
    if (!testUser) {
      console.log('⚠️  Test user not found. Creating one...');
      console.log('Please create a test user first by signing up with email: test@example.com');
      process.exit(1);
    }

    console.log(`✅ Using user: ${testUser.name} (${testUser.email})`);

    // Delete existing posts by test user
    await Post.deleteMany({ createdBy: testUser._id });
    console.log('🗑️  Cleared existing test posts');

    // Create posts (set as approved so they show in feed)
    const posts = samplePosts.map((post, index) => {
      const location = sampleLocations[index % sampleLocations.length];
      return {
        ...post,
        location: {
          type: 'Point',
          coordinates: [location.lng, location.lat],
          address: location.address,
        },
        createdBy: testUser._id,
        status: 'approved', // Set to approved so they appear in feed
      };
    });

    const createdPosts = await Post.insertMany(posts);
    console.log(`✅ Created ${createdPosts.length} sample posts`);

    // Display summary
    console.log('\n📊 Sample Posts Summary:');
    createdPosts.forEach((post, index) => {
      console.log(`${index + 1}. ${post.title} - ₹${post.price} (${post.category})`);
    });

    console.log('\n✨ Database seeded successfully!');
    console.log(`\nYou can now test the app with these ${createdPosts.length} posts.`);
    console.log('Location: Around Bangalore, India\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

// Run the seed function
seedPosts();

