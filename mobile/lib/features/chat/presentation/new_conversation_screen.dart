import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../../auth/domain/user_profile.dart";
import "../application/chat_providers.dart";

class NewConversationScreen extends ConsumerStatefulWidget {
  const NewConversationScreen({super.key});

  @override
  ConsumerState<NewConversationScreen> createState() =>
      _NewConversationScreenState();
}

class _NewConversationScreenState extends ConsumerState<NewConversationScreen> {
  bool _isOpening = false;

  Future<void> _openChatWith(UserProfile me, UserProfile other) async {
    setState(() => _isOpening = true);
    try {
      final chatId = await ref
          .read(chatRepositoryProvider)
          .getOrCreateChat(me, other);
      if (!mounted) return;
      context.replace("/chat/$chatId");
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Nouvelle conversation")),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : FutureBuilder<UserProfile?>(
              future: ref.read(userProfileRepositoryProvider).fetch(user.uid),
              builder: (context, meSnapshot) {
                final me = meSnapshot.data;
                if (me == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return StreamBuilder<List<UserProfile>>(
                  stream: ref
                      .read(userProfileRepositoryProvider)
                      .watchAll(excludeUid: user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final profiles = snapshot.data ?? [];
                    if (profiles.isEmpty) {
                      return const Center(
                        child: Text("Aucun autre utilisateur pour l'instant."),
                      );
                    }
                    return AbsorbPointer(
                      absorbing: _isOpening,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        itemCount: profiles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final other = profiles[index];
                          final displayName =
                              other.displayName?.isNotEmpty == true
                              ? other.displayName!
                              : other.email;
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
                                backgroundColor: other.role.color.withValues(
                                  alpha: 0.15,
                                ),
                                backgroundImage: AssetImage(
                                  other.role.defaultAvatarAsset,
                                ),
                              ),
                              title: Text(displayName),
                              subtitle: Text(other.role.label),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => _openChatWith(me, other),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
