import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../agenda/application/agenda_providers.dart";
import "../../agenda/domain/agenda_event.dart";
import "../../auth/application/auth_providers.dart";
import "../../auth/domain/user_profile.dart";
import "../../journal/application/journal_providers.dart";
import "../../journal/domain/journal_entry.dart";
import "../../services/application/service_providers.dart";
import "../../services/domain/booking.dart";

/// Dossier en lecture seule d'un résident, consulté par son tuteur légal :
/// agenda, réservations et journal de vie, sans aucune action de
/// modification (ajout/suppression réservés au résident lui-même).
class GuardianDossierScreen extends ConsumerWidget {
  const GuardianDossierScreen({
    super.key,
    required this.residentId,
    required this.residentName,
  });

  final String residentId;
  final String residentName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Dossier de $residentName")),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          FutureBuilder<UserProfile?>(
            future: ref.read(userProfileRepositoryProvider).fetch(residentId),
            builder: (context, snapshot) => _GuardianshipSummary(
              residentName: residentName,
              profile: snapshot.data,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle("Agenda", Icons.calendar_month_rounded),
          StreamBuilder<List<AgendaEvent>>(
            stream: ref.read(agendaRepositoryProvider).watchEvents(residentId),
            builder: (context, snapshot) {
              final events = snapshot.data ?? [];
              if (events.isEmpty) {
                return const _EmptyNote("Aucun rendez-vous.");
              }
              return Column(
                children: [
                  for (final event in events)
                    _InfoTile(
                      title: event.title,
                      subtitle:
                          "${DateFormat("d MMM, HH:mm", "fr_FR").format(event.date)}"
                          "${event.subtitle != null ? " · ${event.subtitle}" : ""}",
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle("Réservations", Icons.event_available_rounded),
          StreamBuilder<List<Booking>>(
            stream: ref
                .read(bookingRepositoryProvider)
                .watchForResident(residentId),
            builder: (context, snapshot) {
              final bookings = snapshot.data ?? [];
              if (bookings.isEmpty) {
                return const _EmptyNote("Aucune réservation.");
              }
              return Column(
                children: [
                  for (final booking in bookings)
                    _InfoTile(
                      title: booking.specialty ?? booking.category.label,
                      subtitle:
                          "${booking.providerName} · "
                          "${DateFormat("d MMM, HH:mm", "fr_FR").format(booking.date)}"
                          " · ${booking.mode.label}"
                          "${booking.locationDetails?.isNotEmpty == true ? " · ${booking.locationDetails}" : ""}",
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle("Journal de vie", Icons.menu_book_rounded),
          StreamBuilder<List<JournalEntry>>(
            stream: ref.read(journalRepositoryProvider).watch(residentId),
            builder: (context, snapshot) {
              final entries = snapshot.data ?? [];
              if (entries.isEmpty) {
                return const _EmptyNote("Aucune note pour l'instant.");
              }
              return Column(
                children: [
                  for (final entry in entries)
                    _InfoTile(title: entry.authorName, subtitle: entry.note),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GuardianshipSummary extends StatelessWidget {
  const _GuardianshipSummary({
    required this.residentName,
    required this.profile,
  });

  final String residentName;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final isOrganization = profile?.guardianType == GuardianType.organization;
    final guardianLabel = isOrganization
        ? profile?.guardianOrganization ?? "Organisme de tutelle"
        : profile?.guardianName ?? "Proche désigné";

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.field),
            ),
            child: Icon(
              isOrganization
                  ? Icons.apartment_rounded
                  : Icons.health_and_safety_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Suivi de $residentName",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  guardianLabel,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (profile?.guardianReference?.isNotEmpty == true)
                  Text(
                    "Référence : ${profile!.guardianReference}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, this.icon);

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.field),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
