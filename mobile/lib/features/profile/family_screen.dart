import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:url_launcher/url_launcher.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_radii.dart";
import "../../core/theme/app_spacing.dart";
import "../../core/theme/app_theme.dart";
import "../auth/application/auth_providers.dart";
import "../chat/application/chat_providers.dart";
import "application/profile_providers.dart";
import "domain/proche.dart";

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  Future<Proche?> _procheDialog(BuildContext context, {Proche? existing}) {
    final nameController = TextEditingController(text: existing?.name);
    final relationController = TextEditingController(text: existing?.relation);
    final phoneController = TextEditingController(text: existing?.phone);
    final emailController = TextEditingController(text: existing?.email);

    return showDialog<Proche>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? "Ajouter un proche" : "Modifier ce proche"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: relationController,
                decoration: const InputDecoration(
                  labelText: "Lien de parenté",
                  hintText: "Fille, Fils, Petit-fils...",
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Téléphone (optionnel)"),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "E-mail du compte E-sensya & Co (optionnel)",
                  hintText: "Pour pouvoir lui écrire depuis l'app",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              Navigator.of(context).pop(
                Proche(
                  id: existing?.id ?? "",
                  name: nameController.text.trim(),
                  relation: relationController.text.trim(),
                  phone: phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim(),
                  email: emailController.text.trim().isEmpty
                      ? null
                      : emailController.text.trim(),
                ),
              );
            },
            child: Text(existing == null ? "Ajouter" : "Enregistrer"),
          ),
        ],
      ),
    );
  }

  Future<void> _addProche(BuildContext context, WidgetRef ref, String uid) async {
    final proche = await _procheDialog(context);
    if (proche != null) {
      await ref.read(procheRepositoryProvider).add(uid, proche);
    }
  }

  Future<void> _editProche(BuildContext context, WidgetRef ref, String uid, Proche proche) async {
    final updated = await _procheDialog(context, existing: proche);
    if (updated != null) {
      await ref.read(procheRepositoryProvider).update(uid, updated);
    }
  }

  Future<bool> _confirmMissingInfo(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _message(BuildContext context, WidgetRef ref, String uid, Proche proche) async {
    if (proche.email == null || proche.email!.isEmpty) {
      final shouldEdit = await _confirmMissingInfo(
        context,
        "Aucun e-mail enregistré pour ce proche. L'ajouter pour pouvoir lui écrire ?",
      );
      if (shouldEdit && context.mounted) {
        await _editProche(context, ref, uid, proche);
      }
      return;
    }
    final userProfileRepository = ref.read(userProfileRepositoryProvider);
    final me = await userProfileRepository.fetch(uid);
    final other = await userProfileRepository.findByEmail(proche.email!);
    if (me == null) return;
    if (other == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucun compte E-sensya & Co ne correspond à cet e-mail."),
        ),
      );
      return;
    }
    final chatId = await ref.read(chatRepositoryProvider).getOrCreateChat(me, other);
    if (!context.mounted) return;
    context.push("/chat/$chatId");
  }

  Future<void> _call(BuildContext context, WidgetRef ref, String uid, Proche proche) async {
    if (proche.phone == null || proche.phone!.isEmpty) {
      final shouldEdit = await _confirmMissingInfo(
        context,
        "Aucun téléphone enregistré pour ce proche. L'ajouter pour pouvoir l'appeler ?",
      );
      if (shouldEdit && context.mounted) {
        await _editProche(context, ref, uid, proche);
      }
      return;
    }
    final uri = Uri(scheme: "tel", path: proche.phone);
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de lancer l'appel sur cet appareil.")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Ma famille")),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.secondary,
              onPressed: () => _addProche(context, ref, user.uid),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text("Ajouter un proche"),
            ),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : StreamBuilder<List<Proche>>(
              stream: ref.read(procheRepositoryProvider).watch(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final proches = snapshot.data ?? [];
                if (proches.isEmpty) {
                  return const Center(
                    child: Text("Aucun proche ajouté pour l'instant."),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: proches.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final proche = proches[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(AppRadii.field),
                      onTap: () => _editProche(context, ref, user.uid, proche),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadii.field),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                              child: Text(
                                proche.name.isNotEmpty
                                    ? proche.name[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    proche.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (proche.relation.isNotEmpty)
                                    Text(
                                      proche.relation,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _message(context, ref, user.uid, proche),
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _call(context, ref, user.uid, proche),
                              icon: const Icon(
                                Icons.call_rounded,
                                color: AppColors.success,
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
    );
  }
}
