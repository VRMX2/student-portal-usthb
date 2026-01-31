import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

/// Service for managing chats and messages
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Create or get existing chat between users
  /// Returns the chat ID
  Future<String> createOrGetChat({
    required List<String> participantIds,
    required Map<String, String> participantNames,
    Map<String, String?>? participantPhotos,
  }) async {
    // Sort participant IDs for consistent querying
    final sortedIds = List<String>.from(participantIds)..sort();

    // Check if chat already exists
    final existingChats = await _firestore
        .collection('chats')
        .where('participantIds', isEqualTo: sortedIds)
        .limit(1)
        .get();

    if (existingChats.docs.isNotEmpty) {
      return existingChats.docs.first.id;
    }

    // Create new chat
    final chatId = _uuid.v4();
    final chat = Chat(
      id: chatId,
      participantIds: sortedIds,
      participantNames: participantNames,
      participantPhotos: participantPhotos ?? {},
      unreadCount: {for (var id in sortedIds) id: 0},
      createdAt: DateTime.now(),
    );

    await _firestore.collection('chats').doc(chatId).set(chat.toMap());
    return chatId;
  }

  /// Get all chats for a user
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Chat.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Send a message
  Future<void> sendMessage(Message message) async {
    final batch = _firestore.batch();

    // Add message to messages subcollection
    final messageRef = _firestore
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .doc(message.id);
    
    batch.set(messageRef, message.toMap());

    // Update chat metadata
    final chatRef = _firestore.collection('chats').doc(message.chatId);
    batch.update(chatRef, {
      'lastMessage': message.getPreview(),
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': message.senderId,
      // Increment unread count for other participants
      ...{
        for (var participantId in (await chatRef.get()).data()!['participantIds'])
          if (participantId != message.senderId)
            'unreadCount.$participantId': FieldValue.increment(1)
      },
    });

    await batch.commit();
  }

  /// Get messages for a chat
  Stream<List<Message>> getChatMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Mark messages as read
  Future<void> markAsRead(String chatId, String userId) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    
    await chatRef.update({
      'unreadCount.$userId': 0,
    });

    // Update read status for recent messages
    final messages = await chatRef
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .orderBy('senderId')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      final message = Message.fromMap(doc.data(), doc.id);
      if (!message.isReadBy(userId)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId])
        });
      }
    }
    await batch.commit();
  }

  /// Delete a message
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  /// Add reaction to a message
  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reactions.$userId': emoji,
    });
  }

  /// Remove reaction from a message
  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reactions.$userId': FieldValue.delete(),
    });
  }

  /// Delete a chat
  Future<void> deleteChat(String chatId) async {
    // Delete all messages first
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }

    // Delete the chat
    batch.delete(_firestore.collection('chats').doc(chatId));
    
    await batch.commit();
  }
}
