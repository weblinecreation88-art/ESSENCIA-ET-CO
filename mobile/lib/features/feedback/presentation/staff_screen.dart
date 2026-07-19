import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../../auth/domain/user_profile.dart";
import "../../auth/domain/user_role.dart";

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Noter le personnel")),
      body: StreamBuilder<List<UserProfile>>(
        stream: ref
            .read(userProfileRepositoryProvider)
            .watchByRole(UserRole.professional),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final staff = snapshot.data ?? [];
          if (staff.isEmpty) {
            return const Center(
              child: Text("Aucun membre du personnel disponible pour l'instant."),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: staff.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final member = staff[index];
              final name = member.displayName?.isNotEmpty == true
                  ? member.displayName!
                  : member.email;
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
                    backgroundColor: AppColors.roleProfessional,
                    backgroundImage: AssetImage(member.role.defaultAvatarAsset),
                  ),
                  title: Text(name),
                  subtitle: const Text("Professionnel"),
                  trailing: FilledButton(
                    onPressed: () => context.push(
                      "/staff/feedback?staffId=${member.uid}"
                      "&staffName=${Uri.encodeComponent(name)}",
                    ),
                    child: const Text("Noter"),
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
