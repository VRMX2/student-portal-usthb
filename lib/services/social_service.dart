import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/follow_model.dart';
import '../models/student_model.dart';

/// Service for managing social features (follow/unfollow)
class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Follow a user
  Future<void> followUser({
    required String followerId,
    required String followingId,
  }) async {
    if (followerId == followingId) {
      throw Exception('Cannot follow yourself');
    }

    // Check if already following
    final existing = await _firestore
        .collection('follows')
        .where('followerId', isEqualTo: followerId)
        .where('followingId', isEqualTo: followingId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Already following this user');
    }

    final batch = _firestore.batch();

    // Create follow relationship
    final followId = _uuid.v4();
    final follow = Follow(
      id: followId,
      followerId: followerId,
      followingId: followingId,
      timestamp: DateTime.now(),
      status: FollowStatus.accepted, // Auto-accept for now
    );

    batch.set(
      _firestore.collection('follows').doc(followId),
      follow.toMap(),
    );

    // Update follower count
    batch.update(
      _firestore.collection('users').doc(followingId),
      {'followerCount': FieldValue.increment(1)},
    );

    // Update following count
    batch.update(
      _firestore.collection('users').doc(followerId),
      {'followingCount': FieldValue.increment(1)},
    );

    await batch.commit();
  }

  /// Unfollow a user
  Future<void> unfollowUser({
    required String followerId,
    required String followingId,
  }) async {
    final follow = await _firestore
        .collection('follows')
        .where('followerId', isEqualTo: followerId)
        .where('followingId', isEqualTo: followingId)
        .limit(1)
        .get();

    if (follow.docs.isEmpty) {
      throw Exception('Not following this user');
    }

    final batch = _firestore.batch();

    // Delete follow relationship
    batch.delete(follow.docs.first.reference);

    // Update follower count
    batch.update(
      _firestore.collection('users').doc(followingId),
      {'followerCount': FieldValue.increment(-1)},
    );

    // Update following count
    batch.update(
      _firestore.collection('users').doc(followerId),
      {'followingCount': FieldValue.increment(-1)},
    );

    await batch.commit();
  }

  /// Check if user is following another user
  Future<bool> isFollowing({
    required String followerId,
    required String followingId,
  }) async {
    final result = await _firestore
        .collection('follows')
        .where('followerId', isEqualTo: followerId)
        .where('followingId', isEqualTo: followingId)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  /// Get followers of a user
  Stream<List<Student>> getFollowers(String userId) {
    return _firestore
        .collection('follows')
        .where('followingId', isEqualTo: userId)
        .where('status', isEqualTo: FollowStatus.accepted.name)
        .snapshots()
        .asyncMap((snapshot) async {
      final followerIds = snapshot.docs
          .map((doc) => Follow.fromMap(doc.data(), doc.id).followerId)
          .toList();

      if (followerIds.isEmpty) return [];

      final users = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: followerIds)
          .get();

      return users.docs
          .map((doc) => Student.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get users that a user is following
  Stream<List<Student>> getFollowing(String userId) {
    return _firestore
        .collection('follows')
        .where('followerId', isEqualTo: userId)
        .where('status', isEqualTo: FollowStatus.accepted.name)
        .snapshots()
        .asyncMap((snapshot) async {
      final followingIds = snapshot.docs
          .map((doc) => Follow.fromMap(doc.data(), doc.id).followingId)
          .toList();

      if (followingIds.isEmpty) return [];

      final users = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: followingIds)
          .get();

      return users.docs
          .map((doc) => Student.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Search for users by name or email
  Future<List<Student>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    // Search by full name
    final nameResults = await _firestore
        .collection('users')
        .where('fullName', isGreaterThanOrEqualTo: query)
        .where('fullName', isLessThan: query + 'z')
        .limit(20)
        .get();

    return nameResults.docs
        .map((doc) => Student.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Update user's online status
  Future<void> updateOnlineStatus({
    required String userId,
    required bool isOnline,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  /// Get suggested users to follow
  Future<List<Student>> getSuggestedUsers(String userId, {int limit = 10}) async {
    // Get users from same faculty
    final currentUser = await _firestore.collection('users').doc(userId).get();
    final faculty = currentUser.data()?['faculty'];

    final suggested = await _firestore
        .collection('users')
        .where('faculty', isEqualTo: faculty)
        .where(FieldPath.documentId, isNotEqualTo: userId)
        .limit(limit)
        .get();

    return suggested.docs
        .map((doc) => Student.fromMap(doc.data(), doc.id))
        .toList();
  }
}
