import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_radii.dart";
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Je suis...", style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                "Choisissez le profil qui vous correspond.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: AbsorbPointer(
                  absorbing: _isSubmitting,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                    children: [
                      for (final role in UserRole.values)
                        _RoleCard(role: role, onTap: () => _selectRole(role)),
                    ],
                  ),
                ),
              ),
              if (_isSubmitting) ...[
                const SizedBox(height: 12),
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: role.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(role.icon, color: role.color, size: 28),
            ),
            const SizedBox(height: 14),
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
