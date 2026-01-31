import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a chat/conversation between users
class Chat {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantPhotos,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
    required this.createdAt,
  });

  factory Chat.fromMap(Map<String, dynamic> data, String id) {
    return Chat(
      id: id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      participantPhotos: Map<String, String?>.from(data['participantPhotos'] ?? {}),
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'],
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Get the other participant's name (for 1-on-1 chats)
  String getOtherParticipantName(String currentUserId) {
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return participantNames[otherId] ?? 'Unknown';
  }

  /// Get the other participant's photo (for 1-on-1 chats)
  String? getOtherParticipantPhoto(String currentUserId) {
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return participantPhotos[otherId];
  }

  /// Get unread count for a specific user
  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }
}
