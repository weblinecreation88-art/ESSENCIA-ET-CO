import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../auth/application/auth_providers.dart";
import "../../notifications/application/notification_providers.dart";
import "../../notifications/domain/app_notification.dart";
import "../application/chat_providers.dart";
import "../domain/chat_conversation.dart";
import "../domain/chat_message.dart";

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String senderId) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    final chatRepository = ref.read(chatRepositoryProvider);
    await chatRepository.sendMessage(
      chatId: widget.chatId,
      senderId: senderId,
      text: text,
    );

    final conversation = await chatRepository.getChat(widget.chatId);
    final recipient = conversation?.otherParticipant(senderId);
    final sender = conversation?.participants[senderId];
    if (recipient != null) {
      await ref.read(notificationRepositoryProvider).create(
        recipientUid: recipient.uid,
        type: NotificationType.message,
        title: sender?.name ?? "Nouveau message",
        body: text,
        relatedId: widget.chatId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Aucun utilisateur connecté.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<List<ChatConversation>>(
          stream: ref.read(chatRepositoryProvider).watchConversations(user.uid),
          builder: (context, snapshot) {
            final conversation = snapshot.data?.firstWhere(
              (c) => c.id == widget.chatId,
              orElse: () => const ChatConversation(
                id: "",
                participantIds: [],
                participants: {},
              ),
            );
            final other = conversation?.otherParticipant(user.uid);
            return Text(other?.name ?? "Conversation");
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: ref.read(chatRepositoryProvider).watchMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text("Dites bonjour 👋"));
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == user.uid;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primary
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(AppRadii.field),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.text,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: "Écrire un message...",
                      ),
                      onSubmitted: (_) => _send(user.uid),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    onPressed: () => _send(user.uid),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
