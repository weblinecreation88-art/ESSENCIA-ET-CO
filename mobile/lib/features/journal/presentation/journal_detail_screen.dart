import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../application/journal_providers.dart";
import "../domain/journal_entry.dart";

class JournalDetailScreen extends ConsumerStatefulWidget {
  const JournalDetailScreen({
    super.key,
    required this.residentId,
    required this.title,
  });

  final String residentId;
  final String title;

  @override
  ConsumerState<JournalDetailScreen> createState() =>
      _JournalDetailScreenState();
}

class _JournalDetailScreenState extends ConsumerState<JournalDetailScreen> {
  Future<void> _addEntry() async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter une note"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Un moment du quotidien à partager...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text("Publier"),
          ),
        ],
      ),
    );
    if (note == null || note.isEmpty) return;
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    final profile = await ref.read(userProfileRepositoryProvider).fetch(user.uid);
    final authorName = profile?.displayName?.isNotEmpty == true
        ? profile!.displayName!
        : (profile?.email ?? "Quelqu'un");
    await ref
        .read(journalRepositoryProvider)
        .add(residentUid: widget.residentId, authorName: authorName, note: note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntry,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text("Ajouter une note"),
      ),
      body: StreamBuilder<List<JournalEntry>>(
        stream: ref.read(journalRepositoryProvider).watch(widget.residentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(
              child: Text("Aucune note pour l'instant."),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xxxl * 2,
            ),
            itemCount: entries.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.field),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.authorName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.primaryDark),
                        ),
                        if (entry.createdAt != null)
                          Text(
                            DateFormat("d MMM, HH:mm", "fr_FR").format(
                              entry.createdAt!,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(entry.note, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
