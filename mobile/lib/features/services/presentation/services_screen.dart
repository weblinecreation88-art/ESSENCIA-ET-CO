import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../domain/service_category.dart";

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Réserver un service")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final useSingleColumn =
              constraints.maxWidth < 320 || textScale > 1.35;

          return GridView.count(
            padding: const EdgeInsets.all(AppSpacing.xl),
            crossAxisCount: useSingleColumn ? 1 : 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: useSingleColumn ? 240 : 220,
            children: [
              for (final category in ServiceCategory.values)
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  onTap: () =>
                      context.push("/services/${category.storageValue}"),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadii.field),
                          ),
                          child: Icon(
                            category.icon,
                            color: AppColors.primary,
                            size: 32,
                            semanticLabel: category.label,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: Text(
                            category.label,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(height: 1.25),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
