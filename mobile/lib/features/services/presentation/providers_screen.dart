import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../../auth/domain/user_profile.dart";
import "../../auth/domain/user_role.dart";
import "../domain/service_category.dart";

class ProvidersScreen extends ConsumerWidget {
  const ProvidersScreen({super.key, required this.category});

  final ServiceCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(category.label)),
      body: StreamBuilder<List<UserProfile>>(
        stream: ref
            .read(userProfileRepositoryProvider)
            .watchByRole(UserRole.provider),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final providers = snapshot.data ?? [];
          if (providers.isEmpty) {
            return const Center(
              child: Text("Aucun prestataire disponible pour l'instant."),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: providers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final provider = providers[index];
              final name = provider.displayName?.isNotEmpty == true
                  ? provider.displayName!
                  : provider.email;
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
                    backgroundColor: AppColors.roleProvider,
                    backgroundImage: AssetImage(provider.role.defaultAvatarAsset),
                  ),
                  title: Text(name),
                  subtitle: const Text("Prestataire"),
                  trailing: FilledButton(
                    onPressed: () => context.push(
                      "/booking?providerId=${provider.uid}"
                      "&providerName=${Uri.encodeComponent(name)}"
                      "&category=${category.storageValue}",
                    ),
                    child: const Text("Réserver"),
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
