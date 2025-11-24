const mongoose = require('mongoose');

const conversationSchema = new mongoose.Schema(
  {
    participants: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
      },
    ],
    post: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Post',
      required: true,
    },
    lastMessage: {
      type: String,
      default: '',
    },
    lastMessageTime: {
      type: Date,
      default: Date.now,
    },
    lastMessageSender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
  },
  {
    timestamps: true,
  }
);

// Index for efficient queries
conversationSchema.index({ participants: 1 });
conversationSchema.index({ post: 1 });
conversationSchema.index({ lastMessageTime: -1 });

// Ensure participants array has exactly 2 users
conversationSchema.pre('save', function (next) {
  if (this.participants.length !== 2) {
    next(new Error('Conversation must have exactly 2 participants'));
  }
  next();
});

// Static method to find or create conversation
conversationSchema.statics.findOrCreate = async function (userId1, userId2, postId) {
  // Sort user IDs to ensure consistent ordering
  const participantIds = [userId1, userId2].sort();

  let conversation = await this.findOne({
    participants: { $all: participantIds },
    post: postId,
  });

  if (!conversation) {
    conversation = await this.create({
      participants: participantIds,
      post: postId,
    });
  }

  return conversation;
};

// Instance method to check if user is participant
conversationSchema.methods.isParticipant = function (userId) {
  return this.participants.some((id) => id.toString() === userId.toString());
};

module.exports = mongoose.model('Conversation', conversationSchema);

