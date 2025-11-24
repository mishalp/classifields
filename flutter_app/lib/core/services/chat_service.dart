import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import 'storage_service.dart';
import 'api_service.dart';

class ChatService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  IO.Socket? _socket;

  // Socket.io connection
  Future<void> connectSocket() async {
    // CRITICAL: Ensure any existing socket is completely destroyed first
    if (_socket != null) {
      print('⚠️ Socket already exists! Destroying old socket first...');
      print('   Old socket ID: ${_socket?.id}, Connected: ${_socket?.connected}');
      try {
        // Remove all listeners first
        _socket?.clearListeners();
        _socket?.off('connect');
        _socket?.off('disconnect');
        _socket?.off('error');
        _socket?.off('receive_message');
        _socket?.off('user_typing');
        _socket?.off('messages_read');
        
        // Disconnect and destroy
        if (_socket!.connected) {
          _socket?.disconnect();
        }
        _socket?.dispose();
        _socket?.destroy();
        _socket = null;
        
        // Wait longer to ensure complete disconnection
        await Future.delayed(const Duration(milliseconds: 500));
        print('✅ Old socket destroyed, waiting complete');
      } catch (e) {
        print('⚠️ Error destroying old socket: $e');
        _socket = null;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    final token = await _storage.getToken();
    if (token == null) {
      print('❌ No token available for socket connection');
      return;
    }

    // Decode JWT to show which user is connecting (for debugging)
    String? userId;
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        // Add padding if needed
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        userId = json['id'] as String?;
        print('🔄 Creating NEW socket connection for user ID: $userId');
        print('   Token payload: $decoded');
      }
    } catch (e) {
      print('🔄 Creating NEW socket connection with token (could not decode): ${token.substring(0, 20)}...');
    }

    // Create a COMPLETELY NEW socket instance
    _socket = IO.io(
      ApiConstants.baseUrlNoApi,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableForceNew() // Force new connection
          .build(),
    );

    _socket?.connect();

    _socket?.onConnect((_) {
      print('✅ NEW Socket connected successfully for user ID: $userId (Socket ID: ${_socket?.id})');
    });

    _socket?.onDisconnect((reason) {
      print('❌ Socket disconnected for user ID: $userId (Reason: $reason)');
    });

    _socket?.onError((error) {
      print('❌ Socket error for user ID: $userId - $error');
    });

    _socket?.onConnectError((error) {
      print('❌ Socket connection error for user ID: $userId - $error');
    });
  }

  Future<void> disconnectSocket() async {
    if (_socket != null) {
      final socketId = _socket?.id;
      final wasConnected = _socket?.connected ?? false;
      print('🔌 Disconnecting socket (ID: $socketId, Connected: $wasConnected)...');
      
      try {
        // Remove all listeners first
        _socket?.clearListeners();
        _socket?.off('connect');
        _socket?.off('disconnect');
        _socket?.off('error');
        _socket?.off('connect_error');
        _socket?.off('receive_message');
        _socket?.off('user_typing');
        _socket?.off('messages_read');
        
        // Disconnect and destroy
        if (wasConnected) {
          _socket?.disconnect();
        }
        _socket?.dispose();
        _socket?.destroy();
        
        // Clear reference immediately
        _socket = null;
        
        // Wait longer to ensure complete disconnection
        await Future.delayed(const Duration(milliseconds: 500));
        
        print('✅ Socket completely disconnected and destroyed (was ID: $socketId)');
      } catch (e) {
        print('⚠️ Error during socket disconnect: $e');
        _socket = null;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } else {
      print('ℹ️ No socket to disconnect');
    }
  }

  bool get isConnected => _socket?.connected ?? false;

  // Join conversation room
  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', conversationId);
  }

  // Leave conversation room
  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', conversationId);
  }

  // Send message via Socket.io
  void sendMessageViaSocket(String conversationId, String message) {
    _socket?.emit('send_message', {
      'conversationId': conversationId,
      'message': message,
    });
  }

  // Listen for new messages
  void onReceiveMessage(Function(Map<String, dynamic>) callback) {
    _socket?.on('receive_message', (data) {
      callback(data);
    });
  }

  // Listen for typing indicator
  void onTyping(Function(Map<String, dynamic>) callback) {
    _socket?.on('user_typing', (data) {
      callback(data);
    });
  }

  // Send typing indicator
  void sendTypingIndicator(String conversationId, bool isTyping) {
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  // Remove all listeners
  void removeListeners() {
    if (_socket != null) {
      print('🔕 Removing all socket listeners...');
      _socket?.off('receive_message');
      _socket?.off('user_typing');
      _socket?.off('messages_read');
      _socket?.clearListeners(); // Clear all listeners
    }
  }

  // REST API: Start conversation
  Future<ConversationModel> startConversation({
    required String postId,
    required String receiverId,
  }) async {
    try {
      final response = await _api.post(
        '${ApiConstants.baseUrl}/chat/start',
        data: {
          'postId': postId,
          'receiverId': receiverId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('Start conversation response: $responseData');
        
        final data = responseData['data'];
        if (data == null) {
          throw Exception('No data in response');
        }
        
        // Handle different response formats
        dynamic conversationData;
        if (data is Map && data.containsKey('conversation')) {
          conversationData = data['conversation'];
        } else if (data is Map && !data.containsKey('conversation')) {
          // Conversation data is directly in data object
          conversationData = data;
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        
        // Ensure conversationData is a Map
        if (conversationData is! Map<String, dynamic>) {
          if (conversationData is String) {
            throw Exception('Conversation data is a string, not a map. Data: $conversationData');
          }
          throw Exception('Conversation data is not a map. Type: ${conversationData.runtimeType}');
        }
        
        return ConversationModel.fromJson(conversationData);
      } else {
        throw Exception('Failed to start conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('Start conversation error: $e');
      rethrow;
    }
  }

  // REST API: Get all conversations
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _api.get(
        '${ApiConstants.baseUrl}/chat/conversations',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List<dynamic> conversationsJson = data['conversations'] ?? [];
        return conversationsJson
            .map((json) => ConversationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch conversations');
      }
    } catch (e) {
      print('Get conversations error: $e');
      rethrow;
    }
  }

  // REST API: Get messages for a conversation
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _api.get(
        '${ApiConstants.baseUrl}/chat/$conversationId/messages',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List<dynamic> messagesJson = data['messages'] ?? [];
        return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
      print('Get messages error: $e');
      rethrow;
    }
  }

  // REST API: Send message (fallback)
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    try {
      final response = await _api.post(
        '${ApiConstants.baseUrl}/chat/$conversationId/message',
        data: {'message': message},
      );

      if (response.statusCode == 201) {
        final data = response.data['data'];
        return MessageModel.fromJson(data['message']);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Send message error: $e');
      rethrow;
    }
  }

  // REST API: Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _api.get(
        '${ApiConstants.baseUrl}/chat/unread-count',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data['unreadCount'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Get unread count error: $e');
      return 0;
    }
  }

  // REST API: Mark messages as read
  Future<bool> markMessagesAsRead(String conversationId) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.baseUrl}/chat/$conversationId/mark-read',
      );

      if (response.statusCode == 200) {
        print('Messages marked as read in conversation $conversationId');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Mark messages as read error: $e');
      return false;
    }
  }

  // Socket: Emit mark as read event
  void markAsReadViaSocket(String conversationId) {
    _socket?.emit('mark_as_read', {
      'conversationId': conversationId,
    });
  }

  // Listen for messages read notification
  void onMessagesRead(Function(Map<String, dynamic>) callback) {
    _socket?.on('messages_read', (data) {
      callback(data);
    });
  }
}

