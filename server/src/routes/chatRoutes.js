const express = require('express');
const router = express.Router();
const {
  startConversation,
  getConversations,
  getMessages,
  sendMessage,
  getUnreadCount,
  markMessagesAsRead,
} = require('../controllers/chatController');
const { protect } = require('../middleware/authMiddleware');

// All routes require authentication
router.use(protect);

// Start or get existing conversation
router.post('/start', startConversation);

// Get all conversations
router.get('/conversations', getConversations);

// Get unread count
router.get('/unread-count', getUnreadCount);

// Get messages for a conversation
router.get('/:conversationId/messages', getMessages);

// Send a message
router.post('/:conversationId/message', sendMessage);

// Mark messages as read
router.patch('/:conversationId/mark-read', markMessagesAsRead);

module.exports = router;

