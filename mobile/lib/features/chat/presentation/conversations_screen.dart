import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../application/chat_providers.dart";
import "../domain/chat_conversation.dart";

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Messagerie")),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              onPressed: () => context.push("/chat/new"),
              child: const Icon(Icons.edit_rounded),
            ),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : StreamBuilder<List<ChatConversation>>(
              stream: ref.read(chatRepositoryProvider).watchConversations(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final conversations = snapshot.data ?? [];
                if (conversations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 40,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            "Aucune conversation pour l'instant.",
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: () => context.push("/chat/new"),
                            child: const Text("Démarrer une conversation"),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final other = conversation.otherParticipant(user.uid);
                    final isUnread = conversation.isUnreadFor(user.uid);
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadii.field),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.field),
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              (other?.role.color ?? AppColors.primary).withValues(
                            alpha: 0.15,
                          ),
                          backgroundImage: other != null
                              ? AssetImage(other.role.defaultAvatarAsset)
                              : null,
                        ),
                        title: Text(
                          other?.name ?? "Utilisateur",
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : null,
                          ),
                        ),
                        subtitle: Text(
                          conversation.lastMessage ?? "Nouvelle conversation",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.w600 : null,
                            color: isUnread ? AppColors.title : null,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (conversation.lastMessageAt != null)
                              Text(
                                DateFormat.Hm().format(conversation.lastMessageAt!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (isUnread)
                              Container(
                                margin: const EdgeInsets.only(top: AppSpacing.xs),
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        onTap: () => context.push("/chat/${conversation.id}"),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
