import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
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
  });

  final String providerId;
  final String providerName;
  final ServiceCategory category;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late DateTime _selectedDate;
  String _selectedTime = _timeSlots.first;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
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

  Future<void> _confirm(String residentId) async {
    setState(() => _isSubmitting = true);
    try {
      final date = _dateTime;
      final resident = await ref.read(userProfileRepositoryProvider).fetch(residentId);
      final residentName = resident?.displayName?.isNotEmpty == true
          ? resident!.displayName!
          : (resident?.email ?? "Un résident");
      final dateLabel = DateFormat.yMMMEd("fr_FR").format(date);

      final bookingId = await ref.read(bookingRepositoryProvider).create(
        Booking(
          id: "",
          residentId: residentId,
          providerId: widget.providerId,
          providerName: widget.providerName,
          category: widget.category,
          date: date,
        ),
      );
      await ref.read(agendaRepositoryProvider).add(
        residentId,
        AgendaEvent(
          id: "",
          title: widget.category.label,
          subtitle: widget.providerName,
          date: date,
        ),
      );
      final notificationRepository = ref.read(notificationRepositoryProvider);
      await notificationRepository.create(
        recipientUid: widget.providerId,
        type: NotificationType.booking,
        title: "Nouvelle réservation",
        body: "$residentName — ${widget.category.label} le $dateLabel",
        relatedId: bookingId,
      );
      await notificationRepository.create(
        recipientUid: residentId,
        type: NotificationType.booking,
        title: "Réservation confirmée",
        body: "${widget.category.label} avec ${widget.providerName} le $dateLabel",
        relatedId: bookingId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Réservation confirmée !")),
      );
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
                      _RecapRow(label: "Prestataire", value: widget.providerName),
                      _RecapRow(label: "Service", value: widget.category.label),
                      _RecapRow(
                        label: "Date",
                        value: DateFormat.yMMMEd("fr_FR").format(_selectedDate),
                      ),
                      _RecapRow(label: "Heure", value: _selectedTime),
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

class _RecapRow extends StatelessWidget {
  const _RecapRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
