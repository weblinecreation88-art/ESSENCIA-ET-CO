import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/theme/app_spacing.dart";
import "../auth/application/auth_providers.dart";
import "../auth/domain/user_profile.dart";

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _load();
  }

  Future<UserProfile?> _load() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return Future.value(null);
    return ref.read(userProfileRepositoryProvider).fetch(user.uid);
  }

  Future<void> _update(UserProfile profile, NotificationPreferences prefs) async {
    await ref
        .read(userProfileRepositoryProvider)
        .updatePreferences(uid: profile.uid, preferences: prefs);
    setState(() => _profileFuture = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes préférences")),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text("Aucun utilisateur connecté."));
          }
          final prefs = profile.preferences;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(
                "Notifications",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Nouveaux messages"),
                subtitle: const Text(
                  "Être notifié quand un proche vous écrit.",
                ),
                value: prefs.notifyMessages,
                onChanged: (value) => _update(
                  profile,
                  NotificationPreferences(
                    notifyMessages: value,
                    notifyBookings: prefs.notifyBookings,
                  ),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Réservations"),
                subtitle: const Text(
                  "Être notifié pour les nouvelles réservations et confirmations.",
                ),
                value: prefs.notifyBookings,
                onChanged: (value) => _update(
                  profile,
                  NotificationPreferences(
                    notifyMessages: prefs.notifyMessages,
                    notifyBookings: value,
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
