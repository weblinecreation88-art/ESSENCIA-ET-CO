import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../../auth/domain/user_role.dart";
import "../../satisfaction/application/satisfaction_providers.dart";
import "../../second_life/application/listing_providers.dart";
import "../../services/application/service_providers.dart";
import "../application/staff_feedback_providers.dart";

class _DashboardStats {
  const _DashboardStats({
    required this.residents,
    required this.families,
    required this.professionals,
    required this.providers,
    required this.bookingsToday,
    required this.activeListings,
    required this.feedbackCount,
    required this.satisfactionAverage,
    required this.satisfactionCount,
  });

  final int residents;
  final int families;
  final int professionals;
  final int providers;
  final int bookingsToday;
  final int activeListings;
  final int feedbackCount;
  final double satisfactionAverage;
  final int satisfactionCount;
}

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  late Future<_DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _load();
  }

  Future<_DashboardStats> _load() async {
    final users = await ref.read(userProfileRepositoryProvider).fetchAll();
    final bookings = await ref.read(bookingRepositoryProvider).fetchAll();
    final listings = await ref.read(listingRepositoryProvider).watchAll().first;
    final feedback = await ref
        .read(staffFeedbackRepositoryProvider)
        .fetchAllGroupedByStaff();
    final satisfaction = await ref
        .read(satisfactionRepositoryProvider)
        .fetchAll();

    final now = DateTime.now();
    final bookingsToday = bookings
        .where((b) => DateUtils.isSameDay(b.date, now))
        .length;
    final feedbackCount = feedback.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final satisfactionAverage = satisfaction.isEmpty
        ? 0.0
        : satisfaction.map((e) => e.rating.score).reduce((a, b) => a + b) /
              satisfaction.length;

    return _DashboardStats(
      residents: users.where((u) => u.role == UserRole.resident).length,
      families: users.where((u) => u.role == UserRole.family).length,
      professionals: users.where((u) => u.role == UserRole.professional).length,
      providers: users.where((u) => u.role == UserRole.provider).length,
      bookingsToday: bookingsToday,
      activeListings: listings.length,
      feedbackCount: feedbackCount,
      satisfactionAverage: satisfactionAverage,
      satisfactionCount: satisfaction.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tableau de bord")),
      body: FutureBuilder<_DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data;
          if (stats == null) {
            return const Center(child: Text("Impossible de charger les données."));
          }
          final cards = [
            (
              icon: Icons.favorite_rounded,
              label: "Résidents",
              value: "${stats.residents}",
              color: AppColors.roleResident,
            ),
            (
              icon: Icons.people_alt_rounded,
              label: "Familles",
              value: "${stats.families}",
              color: AppColors.roleFamily,
            ),
            (
              icon: Icons.medical_services_rounded,
              label: "Personnel",
              value: "${stats.professionals}",
              color: AppColors.roleProfessional,
            ),
            (
              icon: Icons.local_shipping_rounded,
              label: "Prestataires",
              value: "${stats.providers}",
              color: AppColors.roleProvider,
            ),
            (
              icon: Icons.event_available_rounded,
              label: "Réservations aujourd'hui",
              value: "${stats.bookingsToday}",
              color: AppColors.primary,
            ),
            (
              icon: Icons.recycling_rounded,
              label: "Annonces Seconde vie",
              value: "${stats.activeListings}",
              color: AppColors.secondary,
            ),
            (
              icon: Icons.emoji_emotions_rounded,
              label: "Avis reçus (personnel)",
              value: "${stats.feedbackCount}",
              color: AppColors.success,
            ),
            (
              icon: Icons.sentiment_satisfied_alt_rounded,
              label: "Satisfaction moyenne",
              value: stats.satisfactionCount == 0
                  ? "—"
                  : "${stats.satisfactionAverage.toStringAsFixed(1)}/3",
              color: AppColors.primaryDark,
            ),
          ];
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.3,
                children: [
                  for (final card in cards)
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
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: card.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(card.icon, color: card.color, size: 18),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            card.value,
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(fontSize: 26),
                          ),
                          Text(
                            card.label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () => context.push("/admin/staff"),
                icon: const Icon(Icons.leaderboard_rounded),
                label: const Text("Classement du personnel"),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => context.push("/admin/satisfaction"),
                icon: const Icon(Icons.sentiment_satisfied_alt_rounded),
                label: const Text("Avis de satisfaction"),
              ),
            ],
          );
        },
      ),
    );
  }
}
