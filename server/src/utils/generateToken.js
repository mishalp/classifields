const jwt = require('jsonwebtoken');
const crypto = require('crypto');

// Generate JWT token
const generateJWT = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || '7d',
  });
};

// Generate random token for email verification and password reset
const generateRandomToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

// Get token expiration time
const getTokenExpiration = (duration) => {
  const hours = duration === '24h' ? 24 : 1;
  return new Date(Date.now() + hours * 60 * 60 * 1000);
};

module.exports = {
  generateJWT,
  generateRandomToken,
  getTokenExpiration,
};

