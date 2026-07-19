import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../../auth/domain/user_profile.dart";
import "../../auth/domain/user_role.dart";
import "journal_detail_screen.dart";

/// Point d'entrée du journal de vie : un résident voit directement son
/// propre journal ; les autres profils choisissent d'abord le résident dont
/// ils veulent consulter ou alimenter le journal.
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authRepositoryProvider).currentUser;
    _profileFuture = user == null
        ? Future.value(null)
        : ref.read(userProfileRepositoryProvider).fetch(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snapshot.data;
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text("Aucun utilisateur connecté.")),
          );
        }
        if (profile.role == UserRole.resident) {
          return JournalDetailScreen(
            residentId: profile.uid,
            title: "Mon journal de vie",
          );
        }
        return _ResidentPickerScreen();
      },
    );
  }
}

class _ResidentPickerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Journal de vie")),
      body: StreamBuilder<List<UserProfile>>(
        stream: ref
            .read(userProfileRepositoryProvider)
            .watchByRole(UserRole.resident),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final residents = snapshot.data ?? [];
          if (residents.isEmpty) {
            return const Center(
              child: Text("Aucun résident disponible pour l'instant."),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: residents.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final resident = residents[index];
              final name = resident.displayName?.isNotEmpty == true
                  ? resident.displayName!
                  : resident.email;
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.field),
                  boxShadow: AppTheme.softShadow,
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.field),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.roleResident,
                    backgroundImage: AssetImage(resident.role.defaultAvatarAsset),
                  ),
                  title: Text(name),
                  subtitle: const Text("Résident"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(
                    "/journal/detail?residentId=${resident.uid}"
                    "&title=${Uri.encodeComponent("Journal de $name")}",
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
