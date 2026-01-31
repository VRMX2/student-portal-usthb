import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of a follow relationship
enum FollowStatus {
  pending,
  accepted,
  blocked,
}

/// Represents a follow relationship between users
class Follow {
  final String id;
  final String followerId; // User who is following
  final String followingId; // User being followed
  final DateTime timestamp;
  final FollowStatus status;

  Follow({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.timestamp,
    required this.status,
  });

  factory Follow.fromMap(Map<String, dynamic> data, String id) {
    return Follow(
      id: id,
      followerId: data['followerId'] ?? '',
      followingId: data['followingId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: FollowStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => FollowStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followerId': followerId,
      'followingId': followingId,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status.name,
    };
  }

  /// Check if follow is accepted
  bool get isAccepted => status == FollowStatus.accepted;

  /// Check if follow is pending
  bool get isPending => status == FollowStatus.pending;

  /// Check if follow is blocked
  bool get isBlocked => status == FollowStatus.blocked;
}
