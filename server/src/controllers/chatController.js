const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const Post = require('../models/Post');
const User = require('../models/User');

// @desc    Start or get existing conversation
// @route   POST /api/chat/start
// @access  Private
const startConversation = async (req, res) => {
  try {
    const { postId, receiverId } = req.body;
    const senderId = req.user.id;

    // Validate input
    if (!postId || !receiverId) {
      return res.status(400).json({
        success: false,
        message: 'Please provide postId and receiverId',
      });
    }

    // Cannot chat with yourself
    if (senderId === receiverId) {
      return res.status(400).json({
        success: false,
        message: 'Cannot start conversation with yourself',
      });
    }

    // Check if post exists
    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }

    // Check if receiver exists
    const receiver = await User.findById(receiverId);
    if (!receiver) {
      return res.status(404).json({
        success: false,
        message: 'Receiver not found',
      });
    }

    // Find or create conversation
    const conversation = await Conversation.findOrCreate(senderId, receiverId, postId);

    // Populate conversation details
    await conversation.populate([
      {
        path: 'participants',
        select: '_id name email',
      },
      {
        path: 'post',
        select: '_id title price images status',
      },
      {
        path: 'lastMessageSender',
        select: '_id name',
      },
    ]);

    // Convert to plain object for JSON serialization
    const conversationObj = conversation.toObject();

    res.status(200).json({
      success: true,
      data: {
        conversation: conversationObj,
      },
    });
  } catch (error) {
    console.error('Start conversation error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while starting conversation',
      error: error.message,
    });
  }
};

// @desc    Get all conversations for logged-in user
// @route   GET /api/chat/conversations
// @access  Private
const getConversations = async (req, res) => {
  try {
    const userId = req.user.id;

    const conversations = await Conversation.find({
      participants: userId,
    })
      .populate({
        path: 'participants',
        select: 'name email',
      })
      .populate({
        path: 'post',
        select: 'title price images status',
      })
      .populate({
        path: 'lastMessageSender',
        select: 'name',
      })
      .sort({ lastMessageTime: -1 });

    // Get unread count for each conversation
    const conversationsWithUnread = await Promise.all(
      conversations.map(async (conv) => {
        const unreadCount = await Message.countDocuments({
          conversation: conv._id,
          receiver: userId,
          isRead: false,
        });

        // Get the other participant (not the logged-in user)
        const otherParticipant = conv.participants.find(
          (p) => p._id.toString() !== userId
        );

        return {
          ...conv.toObject(),
          unreadCount,
          otherParticipant,
        };
      })
    );

    res.status(200).json({
      success: true,
      count: conversationsWithUnread.length,
      data: {
        conversations: conversationsWithUnread,
      },
    });
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching conversations',
      error: error.message,
    });
  }
};

// @desc    Get messages for a conversation
// @route   GET /api/chat/:conversationId/messages
// @access  Private
const getMessages = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user.id;
    const { page = 1, limit = 50 } = req.query;

    // Check if conversation exists and user is participant
    const conversation = await Conversation.findById(conversationId);
    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found',
      });
    }

    if (!conversation.isParticipant(userId)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this conversation',
      });
    }

    // Get messages with pagination
    const skip = (page - 1) * limit;
    const messages = await Message.find({ conversation: conversationId })
      .sort({ createdAt: 1 }) // Oldest first for chat display
      .skip(skip)
      .limit(parseInt(limit))
      .populate('sender', '_id name email')
      .populate('receiver', '_id name email');

    const totalMessages = await Message.countDocuments({ conversation: conversationId });

    // Mark messages as read
    await Message.markConversationAsRead(conversationId, userId);

    res.status(200).json({
      success: true,
      count: messages.length,
      total: totalMessages,
      page: parseInt(page),
      pages: Math.ceil(totalMessages / limit),
      data: {
        messages,
      },
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching messages',
      error: error.message,
    });
  }
};

// @desc    Send a message (backup for Socket.io)
// @route   POST /api/chat/:conversationId/message
// @access  Private
const sendMessage = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { message } = req.body;
    const senderId = req.user.id;

    // Validate input
    if (!message || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Message content is required',
      });
    }

    // Check if conversation exists and user is participant
    const conversation = await Conversation.findById(conversationId);
    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found',
      });
    }

    if (!conversation.isParticipant(senderId)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to send message in this conversation',
      });
    }

    // Get receiver ID (the other participant)
    const receiverId = conversation.participants.find(
      (id) => id.toString() !== senderId
    );

    // Create message
    const newMessage = await Message.create({
      conversation: conversationId,
      sender: senderId,
      receiver: receiverId,
      message: message.trim(),
    });

    // Update conversation's last message
    conversation.lastMessage = message.trim();
    conversation.lastMessageTime = new Date();
    conversation.lastMessageSender = senderId;
    await conversation.save();

    // Populate message details
    await newMessage.populate([
      { path: 'sender', select: '_id name email' },
      { path: 'receiver', select: '_id name email' },
    ]);

    res.status(201).json({
      success: true,
      data: {
        message: newMessage,
      },
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while sending message',
      error: error.message,
    });
  }
};

// @desc    Get unread messages count
// @route   GET /api/chat/unread-count
// @access  Private
const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.id;
    const unreadCount = await Message.getUnreadCount(userId);

    res.status(200).json({
      success: true,
      data: {
        unreadCount,
      },
    });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching unread count',
      error: error.message,
    });
  }
};

// @desc    Mark messages as read in a conversation
// @route   PATCH /api/chat/:conversationId/mark-read
// @access  Private
const markMessagesAsRead = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user.id;

    // Check if conversation exists and user is participant
    const conversation = await Conversation.findById(conversationId);
    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found',
      });
    }

    if (!conversation.isParticipant(userId)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this conversation',
      });
    }

    // Mark all messages in this conversation as read for this user
    const result = await Message.markConversationAsRead(conversationId, userId);

    res.status(200).json({
      success: true,
      data: {
        markedCount: result.modifiedCount || 0,
      },
    });
  } catch (error) {
    console.error('Mark messages as read error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while marking messages as read',
      error: error.message,
    });
  }
};

module.exports = {
  startConversation,
  getConversations,
  getMessages,
  sendMessage,
  getUnreadCount,
  markMessagesAsRead,
};

