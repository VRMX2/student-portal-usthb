import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:badges/badges.dart' as badges;
import '../models/chat_model.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'chat_conversation_screen.dart';

/// Screen showing list of all user's chats
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final chatService = ChatService();
    final currentUserId = authService.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to user search
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Chat>>(
        stream: chatService.getUserChats(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation with your classmates',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatListTile(
                chat: chat,
                currentUserId: currentUserId,
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final Chat chat;
  final String currentUserId;

  const _ChatListTile({
    required this.chat,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserName = chat.getOtherParticipantName(currentUserId);
    final otherUserPhoto = chat.getOtherParticipantPhoto(currentUserId);
    final unreadCount = chat.getUnreadCount(currentUserId);
    final hasUnread = unreadCount > 0;

    return ListTile(
      leading: badges.Badge(
        showBadge: hasUnread,
        badgeContent: Text(
          unreadCount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        child: CircleAvatar(
          backgroundImage: otherUserPhoto != null
              ? NetworkImage(otherUserPhoto)
              : null,
          child: otherUserPhoto == null
              ? Text(otherUserName[0].toUpperCase())
              : null,
        ),
      ),
      title: Text(
        otherUserName,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        chat.lastMessage ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: chat.lastMessageTime != null
          ? Text(
              timeago.format(chat.lastMessageTime!),
              style: TextStyle(
                fontSize: 12,
                color: hasUnread ? Theme.of(context).primaryColor : Colors.grey,
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationScreen(
              chatId: chat.id,
              otherUserName: otherUserName,
              otherUserPhoto: otherUserPhoto,
            ),
          ),
        );
      },
    );
  }
}
