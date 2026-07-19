import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_radii.dart";
import "../../core/theme/app_theme.dart";
import "../auth/application/auth_providers.dart";
import "application/profile_providers.dart";
import "domain/proche.dart";

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  Future<void> _addProche(BuildContext context, WidgetRef ref, String uid) async {
    final nameController = TextEditingController();
    final relationController = TextEditingController();
    final phoneController = TextEditingController();

    final proche = await showDialog<Proche>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un proche"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relationController,
              decoration: const InputDecoration(
                labelText: "Lien de parenté",
                hintText: "Fille, Fils, Petit-fils...",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Téléphone (optionnel)"),
            ),
          ],
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
                  id: "",
                  name: nameController.text.trim(),
                  relation: relationController.text.trim(),
                  phone: phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim(),
                ),
              );
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );

    if (proche != null) {
      await ref.read(procheRepositoryProvider).add(uid, proche);
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
                  padding: const EdgeInsets.all(20),
                  itemCount: proches.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final proche = proches[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
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
                          const SizedBox(width: 12),
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
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Messagerie bientôt disponible.")),
                            ),
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Appel bientôt disponible.")),
                            ),
                            icon: const Icon(
                              Icons.call_rounded,
                              color: AppColors.success,
                            ),
                          ),
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
