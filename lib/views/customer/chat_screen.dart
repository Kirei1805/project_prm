import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../../services/firestore_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage(String chatId, String currentUserId) {
    if (_messageController.text.trim().isEmpty) return;

    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      text: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    _firestoreService.sendMessage(chatId, message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    
    // Check if arguments were passed (Admin mode)
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String chatId = args?['chatId']?.toString() ?? auth.currentUser?.id ?? '';
    final String chatName = args?['name']?.toString() ?? 'Support Chat';
    final String currentUserId = auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(chatName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _firestoreService.getChatStream(chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet. Start a conversation!', style: TextStyle(color: AppColors.textSecondary)));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.accent : AppColors.surface,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                            bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.accent),
                  onPressed: () => _sendMessage(chatId, currentUserId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
