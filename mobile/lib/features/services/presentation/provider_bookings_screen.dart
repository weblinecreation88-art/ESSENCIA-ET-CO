import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../application/service_providers.dart";
import "../domain/booking.dart";

class ProviderBookingsScreen extends ConsumerWidget {
  const ProviderBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Mes rendez-vous")),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : StreamBuilder<List<Booking>>(
              stream: ref
                  .read(bookingRepositoryProvider)
                  .watchForProvider(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return const Center(
                    child: Text("Aucun rendez-vous pour l'instant."),
                  );
                }

                final now = DateTime.now();
                final today = bookings
                    .where((booking) => DateUtils.isSameDay(booking.date, now))
                    .length;
                final upcoming = bookings
                    .where((booking) => !booking.date.isBefore(now))
                    .length;

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: "Aujourd'hui",
                            value: today,
                            icon: Icons.today_rounded,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _SummaryCard(
                            label: "À venir",
                            value: upcoming,
                            icon: Icons.upcoming_rounded,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _SummaryCard(
                            label: "Total",
                            value: bookings.length,
                            icon: Icons.event_note_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      "Aperçu des rendez-vous",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final booking in bookings) ...[
                      _BookingCard(booking: booking),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.field),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "$value",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.field),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.field),
            ),
            child: Icon(booking.mode.icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.residentName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  booking.specialty ?? booking.category.label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _InfoChip(
                      icon: booking.mode.icon,
                      label: booking.mode.label,
                    ),
                    _InfoChip(
                      icon: Icons.schedule_rounded,
                      label: DateFormat(
                        "d MMM · HH:mm",
                        "fr_FR",
                      ).format(booking.date),
                    ),
                  ],
                ),
                if (booking.locationDetails?.isNotEmpty == true) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    booking.locationDetails!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.field),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
