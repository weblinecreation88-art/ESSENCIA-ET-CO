import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../auth/application/auth_providers.dart";
import "../../auth/domain/user_profile.dart";
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
  void initState() {
    super.initState();
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      ref.read(chatRepositoryProvider).markAsRead(widget.chatId, user.uid);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteMessage(ChatMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le message ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(chatRepositoryProvider)
          .deleteMessage(widget.chatId, message.id);
    }
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
    await _notifyRecipient(senderId, body: text);
  }

  Future<void> _notifyRecipient(String senderId, {required String body}) async {
    final chatRepository = ref.read(chatRepositoryProvider);
    final conversation = await chatRepository.getChat(widget.chatId);
    final recipient = conversation?.otherParticipant(senderId);
    final sender = conversation?.participants[senderId];
    if (recipient != null) {
      final UserProfile? recipientProfile = await ref
          .read(userProfileRepositoryProvider)
          .fetch(recipient.uid);
      if (recipientProfile?.preferences.notifyMessages ?? true) {
        await ref.read(notificationRepositoryProvider).create(
          recipientUid: recipient.uid,
          type: NotificationType.message,
          title: sender?.name ?? "Nouveau message",
          body: body,
          relatedId: widget.chatId,
        );
      }
    }
  }

  Future<void> _pickAndSendImage(String senderId) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text("Prendre une photo"),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text("Choisir dans la galerie"),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    await ref.read(chatRepositoryProvider).sendImage(
      chatId: widget.chatId,
      senderId: senderId,
      bytes: Uint8List.fromList(bytes),
    );
    await _notifyRecipient(senderId, body: "📷 Photo");
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
                      child: GestureDetector(
                        onLongPress: isMe
                            ? () => _confirmDeleteMessage(message)
                            : null,
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: AppSpacing.xs),
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
                              child: message.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.field - 4,
                                      ),
                                      child: Image.network(
                                        message.imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Text(
                                      message.text,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : AppColors.text,
                                      ),
                                    ),
                            ),
                            if (message.sentAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  DateFormat.Hm().format(message.sentAt!),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
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
                  IconButton(
                    onPressed: () => _pickAndSendImage(user.uid),
                    icon: const Icon(
                      Icons.add_a_photo_rounded,
                      color: AppColors.primary,
                    ),
                  ),
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
