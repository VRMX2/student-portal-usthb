import 'package:cloud_firestore/cloud_firestore.dart';

/// Type of message content
enum MessageType {
  text,
  image,
  voice,
  emoji,
}

/// Represents a single message in a chat
class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderPhoto;
  final MessageType type;
  final String content; // Text content or Cloudinary URL
  final DateTime timestamp;
  final List<String> readBy;
  final Map<String, String> reactions; // userId -> emoji

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderPhoto,
    required this.type,
    required this.content,
    required this.timestamp,
    this.readBy = const [],
    this.reactions = const {},
  });

  factory Message.fromMap(Map<String, dynamic> data, String id) {
    return Message(
      id: id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhoto: data['senderPhoto'],
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'type': type.name,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
      'reactions': reactions,
    };
  }

  /// Check if message has been read by a specific user
  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  /// Check if message is sent by a specific user
  bool isSentBy(String userId) {
    return senderId == userId;
  }

  /// Get preview text for the message
  String getPreview() {
    switch (type) {
      case MessageType.text:
      case MessageType.emoji:
        return content;
      case MessageType.image:
        return '📷 Image';
      case MessageType.voice:
        return '🎤 Voice message';
    }
  }
}
