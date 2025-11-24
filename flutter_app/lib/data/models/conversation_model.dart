import 'user_model.dart';
import 'post_model.dart';

class ConversationModel {
  final String id;
  final List<UserModel> participants;
  final PostModel post;
  final String lastMessage;
  final DateTime lastMessageTime;
  final UserModel? lastMessageSender;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;
  final UserModel? otherParticipant;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.post,
    required this.lastMessage,
    required this.lastMessageTime,
    this.lastMessageSender,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
    this.otherParticipant,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id'] ?? '',
      participants: (json['participants'] as List?)
              ?.map((p) => UserModel.fromJson(p))
              .toList() ??
          [],
      post: PostModel.fromJson(json['post'] ?? {}),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: DateTime.parse(
        json['lastMessageTime'] ?? DateTime.now().toIso8601String(),
      ),
      lastMessageSender: json['lastMessageSender'] != null
          ? UserModel.fromJson(json['lastMessageSender'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      unreadCount: json['unreadCount'] ?? 0,
      otherParticipant: json['otherParticipant'] != null
          ? UserModel.fromJson(json['otherParticipant'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants.map((p) => p.toJson()).toList(),
      'post': post.toJson(),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessageSender': lastMessageSender?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'unreadCount': unreadCount,
      'otherParticipant': otherParticipant?.toJson(),
    };
  }
}

