import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../application/satisfaction_providers.dart";
import "../domain/satisfaction_entry.dart";

class AdminSatisfactionScreen extends ConsumerStatefulWidget {
  const AdminSatisfactionScreen({super.key});

  @override
  ConsumerState<AdminSatisfactionScreen> createState() =>
      _AdminSatisfactionScreenState();
}

class _AdminSatisfactionScreenState
    extends ConsumerState<AdminSatisfactionScreen> {
  late Future<List<SatisfactionEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = ref.read(satisfactionRepositoryProvider).fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Satisfaction des familles/résidents")),
      body: FutureBuilder<List<SatisfactionEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(child: Text("Aucun avis pour l'instant."));
          }
          final average =
              entries.map((e) => e.rating.score).reduce((a, b) => a + b) /
              entries.length;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Satisfaction moyenne",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      "${average.toStringAsFixed(1)}/3 · ${entries.length} avis",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final entry in entries)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.field),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.rating.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.comment.isNotEmpty
                                  ? entry.comment
                                  : "Sans commentaire",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (entry.createdAt != null)
                              Text(
                                DateFormat("d MMM yyyy", "fr_FR").format(
                                  entry.createdAt!,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
