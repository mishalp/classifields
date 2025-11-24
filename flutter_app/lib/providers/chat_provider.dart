import 'package:flutter/material.dart';
import '../core/services/chat_service.dart';
import '../data/models/conversation_model.dart';
import '../data/models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;
  bool _isTyping = false;
  String? _currentConversationId;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get isTyping => _isTyping;
  bool get isSocketConnected => _chatService.isConnected;

  // Initialize chat (connect socket)
  Future<void> initialize() async {
    try {
      print('🚀 ChatProvider: Starting initialization...');
      
      // CRITICAL: Disconnect existing connection first (handles user switching)
      await _chatService.disconnectSocket();
      
      // Clear any previous state
      _conversations = [];
      _messages = [];
      _unreadCount = 0;
      _isTyping = false;
      _currentConversationId = null;
      _errorMessage = null;
      
      print('⏳ ChatProvider: Waiting for socket to fully disconnect and token to be ready...');
      // Wait longer to ensure socket is fully disconnected AND token is saved
      await Future.delayed(const Duration(milliseconds: 800));
      
      print('🔌 ChatProvider: Connecting socket with current user token...');
      // Connect with current user's token
      await _chatService.connectSocket();
      
      // Wait a bit more to ensure connection is established
      await Future.delayed(const Duration(milliseconds: 300));
      
      _setupSocketListeners();
      await fetchUnreadCount();
      
      print('✅ ChatProvider: Initialization complete!');
      notifyListeners();
    } catch (e) {
      print('❌ ChatProvider: Initialization error - $e');
      _errorMessage = 'Failed to connect to chat service';
      notifyListeners();
    }
  }

  // Dispose (disconnect socket)
  Future<void> disposeChat() async {
    print('🧹 Disposing ChatProvider...');
    
    _chatService.removeListeners();
    await _chatService.disconnectSocket();
    
    // Clear local state
    _conversations = [];
    _messages = [];
    _unreadCount = 0;
    _isTyping = false;
    _currentConversationId = null;
    _errorMessage = null;
    
    print('✅ ChatProvider disposed');
  }

  // Setup socket listeners
  void _setupSocketListeners() {
    _chatService.onReceiveMessage((data) {
      try {
        final message = MessageModel.fromJson(data['message']);
        
        // Only add if it's for the current conversation
        if (data['conversationId'] == _currentConversationId) {
          _messages.add(message);
          notifyListeners();
        }
        
        // Update unread count
        fetchUnreadCount();
      } catch (e) {
        print('Error handling received message: $e');
      }
    });

    _chatService.onTyping((data) {
      _isTyping = data['isTyping'] ?? false;
      notifyListeners();
    });

    _chatService.onMessagesRead((data) {
      try {
        final conversationId = data['conversationId'];
        // Update messages in current conversation to read
        if (conversationId == _currentConversationId) {
          for (var message in _messages) {
            if (!message.isRead) {
              message = MessageModel(
                id: message.id,
                conversationId: message.conversationId,
                sender: message.sender,
                receiver: message.receiver,
                message: message.message,
                isRead: true,
                readAt: DateTime.now(),
                createdAt: message.createdAt,
                updatedAt: message.updatedAt,
              );
            }
          }
          notifyListeners();
        }
        // Update conversation list
        fetchConversations();
      } catch (e) {
        print('Error handling messages read: $e');
      }
    });
  }

  // Start or get conversation
  Future<ConversationModel?> startConversation({
    required String postId,
    required String receiverId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final conversation = await _chatService.startConversation(
        postId: postId,
        receiverId: receiverId,
      );

      _isLoading = false;
      notifyListeners();
      return conversation;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Fetch all conversations
  Future<void> fetchConversations() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _conversations = await _chatService.getConversations();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch messages for a conversation
  Future<void> fetchMessages(String conversationId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _currentConversationId = conversationId;
      notifyListeners();

      _messages = await _chatService.getMessages(conversationId);
      _chatService.joinConversation(conversationId);

      _isLoading = false;
      notifyListeners();

      // Mark messages as read after fetching
      await markConversationAsRead(conversationId);
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark messages as read in a conversation
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      // Mark via REST API
      await _chatService.markMessagesAsRead(conversationId);
      
      // Also mark via Socket if connected
      if (_chatService.isConnected) {
        _chatService.markAsReadViaSocket(conversationId);
      }
      
      // Update unread count
      await fetchUnreadCount();
    } catch (e) {
      print('Error marking conversation as read: $e');
    }
  }

  // Send message
  void sendMessage(String conversationId, String message) {
    if (message.trim().isEmpty) return;
    
    try {
      if (_chatService.isConnected) {
        // Use Socket.io for real-time
        _chatService.sendMessageViaSocket(conversationId, message);
      } else {
        // Fallback to REST API
        _sendMessageViaRest(conversationId, message);
      }
    } catch (e) {
      print('Send message error: $e');
      // Fallback to REST API
      _sendMessageViaRest(conversationId, message);
    }
  }

  // Send message via REST API (fallback)
  Future<void> _sendMessageViaRest(String conversationId, String message) async {
    try {
      final newMessage = await _chatService.sendMessage(
        conversationId: conversationId,
        message: message,
      );
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to send message';
      notifyListeners();
    }
  }

  // Send typing indicator
  void sendTypingIndicator(String conversationId, bool isTyping) {
    _chatService.sendTypingIndicator(conversationId, isTyping);
  }

  // Fetch unread count
  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _chatService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  // Leave conversation
  void leaveConversation(String conversationId) {
    _chatService.leaveConversation(conversationId);
    _currentConversationId = null;
  }

  // Clear messages (when leaving chat screen)
  void clearMessages() {
    _messages = [];
    _currentConversationId = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

