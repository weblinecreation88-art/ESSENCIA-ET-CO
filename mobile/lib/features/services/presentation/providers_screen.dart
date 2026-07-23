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
import "../domain/service_category.dart";

class ProvidersScreen extends ConsumerStatefulWidget {
  const ProvidersScreen({super.key, required this.category});

  final ServiceCategory category;

  @override
  ConsumerState<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends ConsumerState<ProvidersScreen> {
  String? _selectedSpecialty;

  ServiceCategory get category => widget.category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(category.label, maxLines: 2, softWrap: true),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.border),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.field),
                  ),
                  child: Icon(
                    category.icon,
                    color: AppColors.primary,
                    size: 28,
                    semanticLabel: category.label,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "Choisissez le service recherché",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Sous-catégories",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    for (final specialty in category.specialties)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _SpecialtyOption(
                          label: specialty,
                          isSelected: _selectedSpecialty == specialty,
                          onTap: () =>
                              setState(() => _selectedSpecialty = specialty),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _selectedSpecialty == null
                ? const _SelectSpecialtyPrompt()
                : _ProvidersList(
                    category: category,
                    specialty: _selectedSpecialty!,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyOption extends StatelessWidget {
  const _SpecialtyOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.field),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.field),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.title,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectSpecialtyPrompt extends StatelessWidget {
  const _SelectSpecialtyPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "Sélectionnez une sous-catégorie pour afficher les professionnels.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProvidersList extends ConsumerWidget {
  const _ProvidersList({required this.category, required this.specialty});

  final ServiceCategory category;
  final String specialty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<UserProfile>>(
      stream: ref.read(userProfileRepositoryProvider).watchByRoles(const [
        UserRole.provider,
        UserRole.professional,
      ]),
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          itemCount: providers.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final provider = providers[index];
            final name = provider.displayName?.isNotEmpty == true
                ? provider.displayName!
                : provider.email;
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.field),
                border: Border.all(color: AppColors.border),
                boxShadow: AppTheme.softShadow,
              ),
              child: ListTile(
                isThreeLine: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.field),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.roleProvider,
                  backgroundImage: AssetImage(provider.role.defaultAvatarAsset),
                ),
                title: Text(name),
                subtitle: Text(
                  "${provider.role.label}\n$specialty",
                  softWrap: true,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.35),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(
                  "/booking?providerId=${provider.uid}"
                  "&providerName=${Uri.encodeComponent(name)}"
                  "&category=${category.storageValue}"
                  "&specialty=${Uri.encodeComponent(specialty)}",
                ),
              ),
            );
          },
        );
      },
    );
  }
}
