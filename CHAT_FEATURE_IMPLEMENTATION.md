# 💬 Chat Feature Implementation Guide

## 🎯 Overview

This guide will help you complete the real-time chat functionality for the classifieds marketplace app.

---

## ✅ What's Already Done

### **Backend (Complete!)**
✅ **Models Created:**
- `server/src/models/Conversation.js` - Stores chat conversations
- `server/src/models/Message.js` - Stores individual messages

✅ **Controller Created:**
- `server/src/controllers/chatController.js` - All REST API endpoints

✅ **Routes Created:**
- `server/src/routes/chatRoutes.js` - Chat API routes

✅ **Socket.io Configured:**
- `server/src/config/socket.js` - Real-time messaging events
- Integrated with Express server in `server/server.js`

✅ **Dependencies Installed:**
- `socket.io` - Real-time communication

### **Frontend (Partially Complete)**
✅ **Dependencies Added:**
- `socket_io_client: ^2.0.3+1` in `pubspec.yaml`

✅ **Models Created:**
- `lib/data/models/conversation_model.dart`
- `lib/data/models/message_model.dart`

---

## 📋 What Still Needs to Be Done

### **Frontend Tasks:**

#### **1. Create Chat Service** ⚠️ HIGH PRIORITY
Create: `lib/core/services/chat_service.dart`

```dart
import 'package:dio/dio.dart';
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
    final token = await _storage.getToken();
    if (token == null) return;

    _socket = IO.io(
      ApiConstants.baseUrlNoApi,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket?.connect();
    
    _socket?.onConnect((_) {
      print('Socket connected');
    });

    _socket?.onDisconnect((_) {
      print('Socket disconnected');
    });
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

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
        final data = response.data['data'];
        return ConversationModel.fromJson(data['conversation']);
      } else {
        throw Exception('Failed to start conversation');
      }
    } catch (e) {
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
        return messagesJson
            .map((json) => MessageModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
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
      return 0;
    }
  }
}
```

---

#### **2. Create Chat Provider** ⚠️ HIGH PRIORITY
Create: `lib/providers/chat_provider.dart`

```dart
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

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get isTyping => _isTyping;

  // Initialize chat (connect socket)
  Future<void> initialize() async {
    await _chatService.connectSocket();
    _setupSocketListeners();
    await fetchUnreadCount();
  }

  // Dispose (disconnect socket)
  void disposeChat() {
    _chatService.disconnectSocket();
  }

  // Setup socket listeners
  void _setupSocketListeners() {
    _chatService.onReceiveMessage((data) {
      final message = MessageModel.fromJson(data['message']);
      _messages.add(message);
      notifyListeners();
    });

    _chatService.onTyping((data) {
      _isTyping = data['isTyping'];
      notifyListeners();
    });
  }

  // Start or get conversation
  Future<ConversationModel?> startConversation({
    required String postId,
    required String receiverId,
  }) async {
    try {
      _isLoading = true;
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
      notifyListeners();

      _messages = await _chatService.getMessages(conversationId);
      _chatService.joinConversation(conversationId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  void sendMessage(String conversationId, String message) {
    _chatService.sendMessageViaSocket(conversationId, message);
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
  }

  // Clear messages (when leaving chat screen)
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
```

---

#### **3. Create Chat List Screen** 
Create: `lib/screens/chat/chat_list_screen.dart`

**Features:**
- Display all conversations
- Show last message and timestamp
- Show unread count badge
- Pull to refresh
- Tap to open chat screen

---

#### **4. Create Chat Screen**
Create: `lib/screens/chat/chat_screen.dart`

**Features:**
- Display messages in chat bubbles
- Different colors for sent/received messages
- Text input with send button
- Auto-scroll to bottom on new message
- Typing indicator
- Real-time message updates via Socket.io

---

#### **5. Update Ad Details Screen**
Update: `lib/screens/post/post_details_screen.dart`

**Add "Message Seller" Button:**
```dart
// In bottom navigation bar area
if (!isOwnPost)
  ElevatedButton.icon(
    onPressed: () async {
      final chatProvider = context.read<ChatProvider>();
      final conversation = await chatProvider.startConversation(
        postId: post.id,
        receiverId: post.createdBy.id,
      );
      
      if (conversation != null) {
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: conversation.id,
        );
      }
    },
    icon: Icon(Icons.message),
    label: Text('Message Seller'),
  )
```

---

#### **6. Update Bottom Navigation**
Update: `lib/screens/main_screen.dart`

**Add Chat Tab:**
```dart
BottomNavigationBarItem(
  icon: Badge(
    label: Text('3'), // unread count
    child: Icon(Icons.chat_bubble_outline),
  ),
  activeIcon: Icon(Icons.chat_bubble),
  label: 'Chat',
)
```

---

#### **7. Update Main.dart**
Update: `lib/main.dart`

**Add ChatProvider:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => PostProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
  ],
  child: MyApp(),
)
```

**Add Chat Routes:**
```dart
'/chat-list': (context) => ChatListScreen(),
'/chat': (context) => ChatScreen(),
```

---

## 🎨 UI Design Guidelines

### **Chat List Item:**
```
┌──────────────────────────────────┐
│  [Avatar] John Doe              │
│           iPhone 13 for sale    │ ← Post title
│           Hey, is this avail... │ ← Last message
│           2h ago               [3]│ ← Time & Badge
└──────────────────────────────────┘
```

### **Chat Screen:**
```
┌──────────────────────────────────┐
│  ← John Doe               ●      │ ← Header (online status)
├──────────────────────────────────┤
│                                  │
│  ┌────────────────────┐          │ ← Received
│  │ Hi, is this still  │          │
│  │ available?         │          │
│  └────────────────────┘          │
│                                  │
│          ┌────────────────────┐  │ ← Sent
│          │ Yes, it is!        │  │
│          └────────────────────┘  │
│                                  │
├──────────────────────────────────┤
│  [Type a message...      ] [▶]  │ ← Input
└──────────────────────────────────┘
```

---

## 🔧 Testing

### **Backend Testing:**
```bash
# Test REST API
curl -X POST http://localhost:5000/api/chat/start \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "postId": "POST_ID",
    "receiverId": "RECEIVER_ID"
  }'
```

### **Socket.io Testing:**
Use Socket.io client test tool or Postman to test:
1. Connect to socket with JWT
2. Join conversation
3. Send message
4. Verify message is received

---

## 📚 Additional Resources

### **Socket.io Flutter Documentation:**
https://pub.dev/packages/socket_io_client

### **Material 3 Chat UI Examples:**
- https://m3.material.io/components/cards
- https://m3.material.io/components/lists

---

## 🚀 Implementation Order

**Phase 1: Basic REST API Chat**
1. ✅ Create chat service (REST API only)
2. ✅ Create chat provider
3. ✅ Create simple chat list screen
4. ✅ Create simple chat screen
5. ✅ Test message sending via REST API

**Phase 2: Real-time Socket.io**
1. ✅ Integrate Socket.io in chat service
2. ✅ Update chat provider with socket listeners
3. ✅ Test real-time messaging

**Phase 3: Polish & Features**
1. ✅ Add typing indicators
2. ✅ Add online/offline status
3. ✅ Add message read receipts
4. ✅ Add push notifications

---

## ⚠️ Important Notes

1. **JWT Token**: Ensure you pass the JWT token correctly for Socket.io authentication

2. **Connection Management**: 
   - Connect socket when user logs in
   - Disconnect when user logs out
   - Handle reconnection automatically

3. **Message Persistence**:
   - Always save messages to database via REST API
   - Socket.io is for real-time delivery only

4. **Error Handling**:
   - Handle connection errors gracefully
   - Show offline indicators
   - Queue messages when offline

---

## 📊 Backend API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/chat/start` | Start or get conversation |
| GET | `/api/chat/conversations` | Get all conversations |
| GET | `/api/chat/:id/messages` | Get messages |
| POST | `/api/chat/:id/message` | Send message (REST fallback) |
| GET | `/api/chat/unread-count` | Get unread count |

---

## 🔌 Socket.io Events

| Event | Direction | Data | Description |
|-------|-----------|------|-------------|
| `join_conversation` | Client → Server | `conversationId` | Join conversation room |
| `leave_conversation` | Client → Server | `conversationId` | Leave conversation |
| `send_message` | Client → Server | `{conversationId, message}` | Send message |
| `receive_message` | Server → Client | `{message, conversationId}` | Receive new message |
| `typing` | Client → Server | `{conversationId, isTyping}` | Send typing status |
| `user_typing` | Server → Client | `{userId, isTyping}` | Receive typing status |

---

## ✅ Success Checklist

Before marking complete:
- [ ] User can start conversation from Ad Details
- [ ] Chat list shows all conversations
- [ ] Can send and receive messages
- [ ] Real-time updates work via Socket.io
- [ ] Unread count displays correctly
- [ ] Messages persist across app restarts
- [ ] Typing indicator works
- [ ] UI is polished and professional
- [ ] No crashes or errors

---

**You have all the backend ready! Now implement the Flutter screens following this guide.** 🚀

