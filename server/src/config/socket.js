const jwt = require('jsonwebtoken');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');

// Store active socket connections
const userSockets = new Map();

const configureSocket = (io) => {
  // Middleware for authentication
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;

      if (!token) {
        return next(new Error('Authentication error: No token provided'));
      }

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.userId = decoded.id;

      next();
    } catch (error) {
      console.error('Socket authentication error:', error);
      next(new Error('Authentication error: Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`User connected: ${socket.userId} (Socket ID: ${socket.id})`);

    // CRITICAL: If user already has a socket connection, disconnect the old one
    const existingSocketId = userSockets.get(socket.userId);
    if (existingSocketId && existingSocketId !== socket.id) {
      console.log(`⚠️ User ${socket.userId} already has an active connection (${existingSocketId}). Disconnecting old connection...`);
      const oldSocket = io.sockets.sockets.get(existingSocketId);
      if (oldSocket) {
        oldSocket.disconnect(true); // Force disconnect
        userSockets.delete(socket.userId);
      }
    }

    // Store socket connection
    userSockets.set(socket.userId, socket.id);

    // Join user's personal room for notifications
    socket.join(`user_${socket.userId}`);

    // Event: Join a conversation
    socket.on('join_conversation', async (conversationId) => {
      try {
        // Verify user is participant
        const conversation = await Conversation.findById(conversationId);
        if (!conversation) {
          socket.emit('error', { message: 'Conversation not found' });
          return;
        }

        if (!conversation.isParticipant(socket.userId)) {
          socket.emit('error', { message: 'Not authorized to join this conversation' });
          return;
        }

        socket.join(`conversation_${conversationId}`);
        console.log(`User ${socket.userId} joined conversation ${conversationId}`);

        socket.emit('joined_conversation', {
          conversationId,
          success: true,
        });
      } catch (error) {
        console.error('Join conversation error:', error);
        socket.emit('error', { message: 'Failed to join conversation' });
      }
    });

    // Event: Leave a conversation
    socket.on('leave_conversation', (conversationId) => {
      socket.leave(`conversation_${conversationId}`);
      console.log(`User ${socket.userId} left conversation ${conversationId}`);
    });

    // Event: Send message
    socket.on('send_message', async (data) => {
      try {
        const { conversationId, message } = data;

        // Validate input
        if (!conversationId || !message || message.trim().length === 0) {
          socket.emit('error', { message: 'Invalid message data' });
          return;
        }

        // Verify user is participant
        const conversation = await Conversation.findById(conversationId);
        if (!conversation) {
          socket.emit('error', { message: 'Conversation not found' });
          return;
        }

        if (!conversation.isParticipant(socket.userId)) {
          socket.emit('error', { message: 'Not authorized to send message' });
          return;
        }

        // Get receiver ID
        const receiverId = conversation.participants.find(
          (id) => id.toString() !== socket.userId
        );

        // Save message to database
        const newMessage = await Message.create({
          conversation: conversationId,
          sender: socket.userId,
          receiver: receiverId,
          message: message.trim(),
        });

        // Update conversation's last message
        conversation.lastMessage = message.trim();
        conversation.lastMessageTime = new Date();
        conversation.lastMessageSender = socket.userId;
        await conversation.save();

        // Populate message details
        await newMessage.populate([
          { path: 'sender', select: '_id name email' },
          { path: 'receiver', select: '_id name email' },
        ]);

        // Log message details
        console.log(`📨 Message sent:`);
        console.log(`   Sender: ${newMessage.sender.name} (ID: ${socket.userId})`);
        console.log(`   Receiver: ${newMessage.receiver.name} (ID: ${receiverId})`);
        console.log(`   Conversation: ${conversationId}`);
        console.log(`   Content: "${message.trim().substring(0, 50)}..."`);

        // Emit to conversation room (both sender and receiver)
        io.to(`conversation_${conversationId}`).emit('receive_message', {
          message: newMessage,
          conversationId,
        });

        // Also emit to receiver's personal room for notification
        io.to(`user_${receiverId.toString()}`).emit('new_message_notification', {
          conversationId,
          message: newMessage,
        });
      } catch (error) {
        console.error('Send message error:', error);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    // Event: Mark message as read
    socket.on('mark_as_read', async (data) => {
      try {
        const { conversationId } = data;

        // Mark all messages in conversation as read
        await Message.markConversationAsRead(conversationId, socket.userId);

        // Notify the other user
        const conversation = await Conversation.findById(conversationId);
        if (conversation) {
          const otherUserId = conversation.participants.find(
            (id) => id.toString() !== socket.userId
          );
          io.to(`user_${otherUserId.toString()}`).emit('messages_read', {
            conversationId,
            readBy: socket.userId,
          });
        }
      } catch (error) {
        console.error('Mark as read error:', error);
      }
    });

    // Event: Typing indicator
    socket.on('typing', (data) => {
      const { conversationId, isTyping } = data;
      socket.to(`conversation_${conversationId}`).emit('user_typing', {
        userId: socket.userId,
        conversationId,
        isTyping,
      });
    });

    // Event: Disconnect
    socket.on('disconnect', () => {
      console.log(`User disconnected: ${socket.userId} (Socket ID: ${socket.id})`);
      userSockets.delete(socket.userId);
    });
  });

  return io;
};

module.exports = { configureSocket, userSockets };

