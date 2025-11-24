import 'user_model.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final UserModel sender;
  final UserModel receiver;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.receiver,
    required this.message,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      conversationId: json['conversation'] is String
          ? json['conversation']
          : (json['conversation']?['_id'] ?? ''),
      sender: UserModel.fromJson(json['sender'] ?? {}),
      receiver: UserModel.fromJson(json['receiver'] ?? {}),
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversation': conversationId,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'message': message,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper to check if this message was sent by the current user
  bool isSentByMe(String currentUserId) {
    return sender.id == currentUserId;
  }
}

