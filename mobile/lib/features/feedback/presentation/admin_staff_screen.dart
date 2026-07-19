import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../../auth/domain/user_role.dart";
import "../application/staff_feedback_providers.dart";
import "../domain/staff_feedback.dart";

class _StaffRanking {
  const _StaffRanking({
    required this.name,
    required this.average,
    required this.feedback,
  });

  final String name;
  final double average;
  final List<StaffFeedback> feedback;
}

class AdminStaffScreen extends ConsumerStatefulWidget {
  const AdminStaffScreen({super.key});

  @override
  ConsumerState<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends ConsumerState<AdminStaffScreen> {
  late Future<List<_StaffRanking>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _rankingFuture = _load();
  }

  Future<List<_StaffRanking>> _load() async {
    final staff = await ref
        .read(userProfileRepositoryProvider)
        .watchByRole(UserRole.professional)
        .first;
    final grouped = await ref
        .read(staffFeedbackRepositoryProvider)
        .fetchAllGroupedByStaff();

    final rankings = <_StaffRanking>[];
    for (final member in staff) {
      final feedback = grouped[member.uid] ?? [];
      final name = member.displayName?.isNotEmpty == true
          ? member.displayName!
          : member.email;
      final average = feedback.isEmpty
          ? 0.0
          : feedback.map((f) => f.rating.score).reduce((a, b) => a + b) /
                feedback.length;
      rankings.add(
        _StaffRanking(name: name, average: average, feedback: feedback),
      );
    }
    rankings.sort((a, b) => b.average.compareTo(a.average));
    return rankings;
  }

  void _showComments(_StaffRanking ranking) {
    final comments = ranking.feedback.where((f) => f.comment.isNotEmpty);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Avis reçus — ${ranking.name}"),
        content: SizedBox(
          width: double.maxFinite,
          child: comments.isEmpty
              ? const Text("Aucun commentaire pour l'instant.")
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final f in comments)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Text("${f.rating.emoji} ${f.comment}"),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administration — Personnel")),
      body: FutureBuilder<List<_StaffRanking>>(
        future: _rankingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rankings = snapshot.data ?? [];
          if (rankings.isEmpty) {
            return const Center(
              child: Text("Aucun membre du personnel pour l'instant."),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: rankings.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final ranking = rankings[index];
              final isTop = index == 0 && ranking.average > 0;
              return InkWell(
                borderRadius: BorderRadius.circular(AppRadii.field),
                onTap: () => _showComments(ranking),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isTop
                        ? AppColors.roleProvider.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.field),
                    border: isTop
                        ? Border.all(color: AppColors.roleProvider, width: 1.5)
                        : null,
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      Text(
                        isTop ? "🏆" : "#${index + 1}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ranking.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (isTop)
                              Text(
                                "Employé du mois",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.roleProvider),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        ranking.feedback.isEmpty
                            ? "Pas encore d'avis"
                            : "${ranking.average.toStringAsFixed(1)}/3 · ${ranking.feedback.length} avis",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
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
