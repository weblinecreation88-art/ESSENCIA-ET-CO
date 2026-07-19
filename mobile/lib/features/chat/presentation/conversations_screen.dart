import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 40,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Aucune conversation pour l'instant.",
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
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
                  padding: const EdgeInsets.all(20),
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final other = conversation.otherParticipant(user.uid);
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
                          child: Text(
                            other != null && other.name.isNotEmpty
                                ? other.name[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              color: other?.role.color ?? AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(other?.name ?? "Utilisateur"),
                        subtitle: Text(
                          conversation.lastMessage ?? "Nouvelle conversation",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: conversation.lastMessageAt != null
                            ? Text(
                                DateFormat.Hm().format(conversation.lastMessageAt!),
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                            : null,
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
