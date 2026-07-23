import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../../core/widgets/celebration.dart";
import "../../agenda/application/agenda_providers.dart";
import "../../agenda/domain/agenda_event.dart";
import "../../auth/application/auth_providers.dart";
import "../../notifications/application/notification_providers.dart";
import "../../notifications/domain/app_notification.dart";
import "../application/service_providers.dart";
import "../domain/booking.dart";
import "../domain/service_category.dart";

const _timeSlots = ["10:00", "11:00", "13:00", "14:30", "15:30", "16:30"];

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.category,
    this.specialty,
  });

  final String providerId;
  final String providerName;
  final ServiceCategory category;
  final String? specialty;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late DateTime _selectedDate;
  String _selectedTime = _timeSlots.first;
  AppointmentMode _selectedMode = AppointmentMode.inPerson;
  final _locationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (result != null) setState(() => _selectedDate = result);
  }

  DateTime get _dateTime {
    final parts = _selectedTime.split(":");
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String? get _locationDetails {
    final value = _locationController.text.trim();
    return switch (_selectedMode) {
      AppointmentMode.video => "Lien sécurisé communiqué avant le rendez-vous",
      AppointmentMode.medicalCenter =>
        value.isEmpty ? "Centre médical E-sensya & Co" : value,
      AppointmentMode.inPerson => value.isEmpty ? null : value,
    };
  }

  Future<void> _confirm(String residentId) async {
    setState(() => _isSubmitting = true);
    try {
      final date = _dateTime;
      final resident = await ref
          .read(userProfileRepositoryProvider)
          .fetch(residentId);
      final residentName = resident?.displayName?.isNotEmpty == true
          ? resident!.displayName!
          : (resident?.email ?? "Un résident");
      final dateLabel = DateFormat.yMMMEd("fr_FR").format(date);

      final bookingId = await ref
          .read(bookingRepositoryProvider)
          .create(
            Booking(
              id: "",
              residentId: residentId,
              residentName: residentName,
              providerId: widget.providerId,
              providerName: widget.providerName,
              category: widget.category,
              date: date,
              specialty: widget.specialty,
              mode: _selectedMode,
              locationDetails: _locationDetails,
            ),
          );
      await ref
          .read(agendaRepositoryProvider)
          .add(
            residentId,
            AgendaEvent(
              id: "",
              title: widget.specialty ?? widget.category.label,
              subtitle: "${widget.providerName} · ${_selectedMode.label}",
              date: date,
            ),
          );
      final notificationRepository = ref.read(notificationRepositoryProvider);
      final provider = await ref
          .read(userProfileRepositoryProvider)
          .fetch(widget.providerId);
      if (provider?.preferences.notifyBookings ?? true) {
        await notificationRepository.create(
          recipientUid: widget.providerId,
          type: NotificationType.booking,
          title: "Nouvelle réservation",
          body:
              "$residentName — ${widget.specialty ?? widget.category.label} "
              "(${_selectedMode.label}) le $dateLabel",
          relatedId: bookingId,
        );
      }
      if (resident?.preferences.notifyBookings ?? true) {
        await notificationRepository.create(
          recipientUid: residentId,
          type: NotificationType.booking,
          title: "Réservation confirmée",
          body:
              "${widget.specialty ?? widget.category.label} avec ${widget.providerName} "
              "(${_selectedMode.label}) le $dateLabel",
          relatedId: bookingId,
        );
      }
      if (!mounted) return;
      celebrate(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Réservation confirmée !")));
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      context.go("/home");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Choisir date & heure")),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Text("Date", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(DateFormat.yMMMEd("fr_FR").format(_selectedDate)),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text("Heure", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final time in _timeSlots)
                      ChoiceChip(
                        label: Text(time),
                        selected: _selectedTime == time,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _selectedTime == time
                              ? Colors.white
                              : AppColors.text,
                        ),
                        onSelected: (_) => setState(() => _selectedTime = time),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  "Modalité du rendez-vous",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final mode in AppointmentMode.values) ...[
                  _AppointmentModeCard(
                    mode: mode,
                    isSelected: _selectedMode == mode,
                    onTap: () => setState(() => _selectedMode = mode),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (_selectedMode != AppointmentMode.video) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: _selectedMode == AppointmentMode.medicalCenter
                          ? "Centre ou service médical"
                          : "Lieu ou adresse (optionnel)",
                      hintText: _selectedMode == AppointmentMode.medicalCenter
                          ? "Centre médical E-sensya & Co"
                          : "Cabinet, domicile…",
                      prefixIcon: Icon(_selectedMode.icon),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  "Récapitulatif",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
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
                      _RecapRow(
                        label: "Prestataire",
                        value: widget.providerName,
                      ),
                      _RecapRow(label: "Service", value: widget.category.label),
                      if (widget.specialty?.isNotEmpty == true)
                        _RecapRow(
                          label: "Sous-catégorie",
                          value: widget.specialty!,
                        ),
                      _RecapRow(
                        label: "Date",
                        value: DateFormat.yMMMEd("fr_FR").format(_selectedDate),
                      ),
                      _RecapRow(label: "Heure", value: _selectedTime),
                      _RecapRow(label: "Modalité", value: _selectedMode.label),
                      if (_locationDetails != null)
                        _RecapRow(label: "Lieu", value: _locationDetails!),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : () => _confirm(user.uid),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Confirmer la réservation"),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AppointmentModeCard extends StatelessWidget {
  const _AppointmentModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final AppointmentMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.field),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.field),
              ),
              child: Icon(mode.icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mode.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
