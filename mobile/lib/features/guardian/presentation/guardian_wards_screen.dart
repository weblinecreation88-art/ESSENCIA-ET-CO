import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../../auth/domain/user_profile.dart";

class GuardianWardsScreen extends ConsumerWidget {
  const GuardianWardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Sous ma tutelle")),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : StreamBuilder<List<UserProfile>>(
              stream: ref
                  .read(userProfileRepositoryProvider)
                  .watchWardsOf(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final wards = snapshot.data ?? [];
                if (wards.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun résident ne vous a désigné comme tuteur pour l'instant.",
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: wards.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final ward = wards[index];
                    final name = ward.displayName?.isNotEmpty == true
                        ? ward.displayName!
                        : ward.email;
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
                          backgroundColor: AppColors.roleResident,
                          backgroundImage: AssetImage(ward.role.defaultAvatarAsset),
                        ),
                        title: Text(name),
                        subtitle: const Text("Résident"),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push(
                          "/guardian/dossier?residentId=${ward.uid}"
                          "&residentName=${Uri.encodeComponent(name)}",
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
