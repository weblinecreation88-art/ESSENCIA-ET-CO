import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_radii.dart";
import "../../core/theme/app_spacing.dart";
import "../../core/theme/app_theme.dart";
import "../auth/application/auth_providers.dart";

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _resetPassword(BuildContext context, WidgetRef ref) async {
    final email = ref.read(authRepositoryProvider).currentUser?.email;
    if (email == null) return;
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Un e-mail a été envoyé à $email.")),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(authRepositoryProvider).currentUser?.email ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres")),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Compte", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => _resetPassword(context, ref),
                  icon: const Icon(Icons.lock_reset_rounded),
                  label: const Text("Changer le mot de passe"),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("À propos", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "E-sensya & Co — Le lien qui prend soin de l'essentiel.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Supprimer mon compte",
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.secondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Pour supprimer définitivement votre compte et vos données, contactez notre équipe depuis Aide et support.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
