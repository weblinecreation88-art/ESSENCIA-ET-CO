import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../../core/widgets/celebration.dart";
import "../../auth/application/auth_providers.dart";
import "../application/agenda_providers.dart";
import "../domain/agenda_event.dart";

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  late DateTime _selectedDay;
  late List<DateTime> _strip;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _selectedDay = today;
    _strip = List.generate(14, (i) => today.add(Duration(days: i - 3)));
  }

  Future<void> _addEvent(String uid) async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    var pickedDate = _selectedDay;
    var pickedTime = TimeOfDay.now();

    final event = await showDialog<AgendaEvent>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Ajouter un rendez-vous"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Titre"),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(
                  labelText: "Sous-titre (optionnel)",
                  hintText: "Avec Sophie, Salle d'animation...",
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      label: Text(DateFormat.yMMMd("fr_FR").format(pickedDate)),
                      onPressed: () async {
                        final result = await showDatePicker(
                          context: context,
                          initialDate: pickedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (result != null) {
                          setDialogState(() => pickedDate = result);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.access_time_rounded, size: 18),
                      label: Text(pickedTime.format(context)),
                      onPressed: () async {
                        final result = await showTimePicker(
                          context: context,
                          initialTime: pickedTime,
                        );
                        if (result != null) {
                          setDialogState(() => pickedTime = result);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final date = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                Navigator.of(context).pop(
                  AgendaEvent(
                    id: "",
                    title: titleController.text.trim(),
                    subtitle: subtitleController.text.trim().isEmpty
                        ? null
                        : subtitleController.text.trim(),
                    date: date,
                  ),
                );
              },
              child: const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );

    if (event != null) {
      await ref.read(agendaRepositoryProvider).add(uid, event);
      if (mounted) celebrate(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mon agenda — ${DateFormat.yMMMM("fr_FR").format(_selectedDay)}",
        ),
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              onPressed: () => _addEvent(user.uid),
              child: const Icon(Icons.add_rounded),
            ),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : Column(
              children: [
                SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: _strip.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final day = _strip[index];
                      final isSelected = DateUtils.isSameDay(day, _selectedDay);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: Container(
                          width: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.field),
                            boxShadow: isSelected ? null : AppTheme.softShadow,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat.E("fr_FR").format(day).substring(0, 3),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white70 : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                "${day.day}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.title,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: StreamBuilder<List<AgendaEvent>>(
                    stream: ref.read(agendaRepositoryProvider).watchEvents(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final events = (snapshot.data ?? [])
                          .where((e) => DateUtils.isSameDay(e.date, _selectedDay))
                          .toList();
                      if (events.isEmpty) {
                        return const Center(
                          child: Text("Aucun rendez-vous ce jour-là."),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        itemCount: events.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Dismissible(
                            key: ValueKey(event.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadii.field),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.secondary,
                              ),
                            ),
                            onDismissed: (_) =>
                                ref.read(agendaRepositoryProvider).remove(user.uid, event.id),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(AppRadii.field),
                                boxShadow: AppTheme.softShadow,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat.Hm().format(event.date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        if (event.subtitle != null)
                                          Text(
                                            event.subtitle!,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
