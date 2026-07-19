import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../application/auth_providers.dart";
import "../domain/user_role.dart";

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  bool _isSubmitting = false;

  Future<void> _selectRole(UserRole role) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      context.go("/welcome");
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(userProfileRepositoryProvider).createProfile(
        uid: user.uid,
        email: user.email ?? "",
        role: role,
      );
      if (!mounted) return;
      context.go("/home");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Je suis...", style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Choisissez le profil qui vous correspond.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Expanded(
                child: AbsorbPointer(
                  absorbing: _isSubmitting,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 0.95,
                    children: [
                      for (final role in UserRole.values)
                        _RoleCard(role: role, onTap: () => _selectRole(role)),
                    ],
                  ),
                ),
              ),
              if (_isSubmitting) ...[
                const SizedBox(height: AppSpacing.md),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role, required this.onTap});

  final UserRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: role.color.withValues(alpha: 0.12),
              backgroundImage: AssetImage(role.defaultAvatarAsset),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              role.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
