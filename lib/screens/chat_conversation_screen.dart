import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:io';
import '../models/message_model.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/cloudinary_service.dart';
import 'package:uuid/uuid.dart';

/// Screen for chat conversation between users
class ChatConversationScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String? otherUserPhoto;

  const ChatConversationScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    this.otherUserPhoto,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();
  final _uuid = const Uuid();
  bool _showEmojiPicker = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  void _markAsRead() {
    final authService = context.read<AuthService>();
    final currentUserId = authService.user?.uid ?? '';
    _chatService.markAsRead(widget.chatId, currentUserId);
  }

  Future<void> _sendTextMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final authService = context.read<AuthService>();
      final currentUser = authService.user;
      if (currentUser == null) return;

      final message = Message(
        id: _uuid.v4(),
        chatId: widget.chatId,
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'User',
        senderPhoto: currentUser.photoURL,
        type: MessageType.text,
        content: _messageController.text.trim(),
        timestamp: DateTime.now(),
      );

      await _chatService.sendMessage(message);
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isSending = true);

      // Upload to Cloudinary
      final imageUrl = await _cloudinaryService.uploadImage(
        File(image.path),
        folder: 'chat_images',
      );

      final authService = context.read<AuthService>();
      final currentUser = authService.user;
      if (currentUser == null) return;

      final message = Message(
        id: _uuid.v4(),
        chatId: widget.chatId,
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'User',
        senderPhoto: currentUser.photoURL,
        type: MessageType.image,
        content: imageUrl,
        timestamp: DateTime.now(),
      );

      await _chatService.sendMessage(message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final currentUserId = authService.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.otherUserPhoto != null
                  ? NetworkImage(widget.otherUserPhoto!)
                  : null,
              child: widget.otherUserPhoto == null
                  ? Text(widget.otherUserName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Text(widget.otherUserName),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Say hi! 👋',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSentByMe = message.senderId == currentUserId;
                    return _MessageBubble(
                      message: message,
                      isSentByMe: isSentByMe,
                    );
                  },
                );
              },
            ),
          ),

          // Emoji picker
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _messageController.text += emoji.emoji;
                },
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _isSending ? null : _sendImage,
                ),
                IconButton(
                  icon: Icon(
                    _showEmojiPicker
                        ? Icons.keyboard
                        : Icons.emoji_emotions_outlined,
                  ),
                  onPressed: () {
                    setState(() => _showEmojiPicker = !_showEmojiPicker);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onTap: () {
                      if (_showEmojiPicker) {
                        setState(() => _showEmojiPicker = false);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSending ? null : _sendTextMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSentByMe;

  const _MessageBubble({
    required this.message,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isSentByMe
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.image)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.content,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              )
            else
              Text(
                message.content,
                style: TextStyle(
                  color: isSentByMe ? Colors.white : Colors.black87,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isSentByMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
