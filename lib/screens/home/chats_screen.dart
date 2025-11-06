import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../chat/chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final chatService = Provider.of<ChatService>(context);
    final currentUserId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: const Color(0xFF1E2139),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getChatRooms(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No chats yet'),
            );
          }

          List<Map<String, dynamic>> chatRooms = snapshot.data!;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> chatRoom = chatRooms[index];
              List<dynamic> participants = chatRoom['participants'] ?? [];
              String otherUserId = participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1E2139),
                  child: Text(
                    otherUserId.isNotEmpty ? otherUserId[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(otherUserId),
                subtitle: Text(
                  chatRoom['lastMessage'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        otherUserId: otherUserId,
                        otherUserEmail: otherUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
