import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_radii.dart";
import "../../core/theme/app_spacing.dart";
import "../../core/theme/app_theme.dart";
import "../auth/application/auth_providers.dart";
import "../auth/domain/user_profile.dart";
import "../auth/domain/user_role.dart";
import "../feedback/application/staff_feedback_providers.dart";
import "../feedback/domain/staff_feedback.dart";
import "application/profile_providers.dart";

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late Future<UserProfile?> _profileFuture;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<UserProfile?> _loadProfile() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return Future.value(null);
    return ref.read(userProfileRepositoryProvider).fetch(user.uid);
  }

  Future<void> _changePhoto() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _isUploadingPhoto = true);
    try {
      final bytes = await picked.readAsBytes();
      final url = await ref
          .read(profilePhotoRepositoryProvider)
          .uploadProfilePhoto(uid: user.uid, bytes: Uint8List.fromList(bytes));
      await ref
          .read(userProfileRepositoryProvider)
          .updatePhotoUrl(uid: user.uid, photoUrl: url);
      if (!mounted) return;
      setState(() => _profileFuture = _loadProfile());
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _editDisplayName(UserProfile profile) async {
    final controller = TextEditingController(text: profile.displayName ?? "");
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mes informations"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nom affiché"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    await ref
        .read(userProfileRepositoryProvider)
        .updateDisplayName(uid: profile.uid, displayName: result);
    if (!mounted) return;
    setState(() => _profileFuture = _loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.xxxl,
                    AppSpacing.xxl,
                    AppSpacing.xxxl,
                  ),
                  decoration: const BoxDecoration(gradient: AppColors.gradient),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isUploadingPhoto ? null : _changePhoto,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white24,
                              backgroundImage: AssetImage(
                                profile.role.defaultAvatarAsset,
                              ),
                              foregroundImage: profile.photoUrl != null
                                  ? NetworkImage(profile.photoUrl!)
                                  : null,
                              child: _isUploadingPhoto
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        profile.displayName?.isNotEmpty == true
                            ? profile.displayName!
                            : profile.email,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        profile.role.label,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: SliverList.list(
                  children: [
                    if (profile.role == UserRole.professional)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _AverageRatingCard(uid: profile.uid),
                      ),
                    if (profile.role == UserRole.provider)
                      _ProfileMenuTile(
                        icon: Icons.event_available_rounded,
                        label: "Mes réservations",
                        onTap: () => context.push("/provider/bookings"),
                      ),
                    _ProfileMenuTile(
                      icon: Icons.badge_rounded,
                      label: "Mes informations",
                      onTap: () => _editDisplayName(profile),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.tune_rounded,
                      label: "Mes préférences",
                      onTap: () => context.push(
                        "/profile/preferences",
                      ),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.people_alt_rounded,
                      label: "Mes proches",
                      onTap: () => context.push("/profile/family"),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.settings_rounded,
                      label: "Paramètres",
                      onTap: () => context.push("/profile/settings"),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.help_rounded,
                      label: "Aide et support",
                      onTap: () => context.push("/profile/help"),
                    ),
                    if (profile.isAdmin)
                      _ProfileMenuTile(
                        icon: Icons.leaderboard_rounded,
                        label: "Administration",
                        onTap: () => context.push("/admin/staff"),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) context.go("/welcome");
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Se déconnecter"),
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

class _AverageRatingCard extends ConsumerWidget {
  const _AverageRatingCard({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.field),
        boxShadow: AppTheme.softShadow,
      ),
      child: StreamBuilder<List<StaffFeedback>>(
        stream: ref.read(staffFeedbackRepositoryProvider).watch(uid),
        builder: (context, snapshot) {
          final feedback = snapshot.data ?? [];
          final title = Text(
            "Ma note moyenne",
            style: Theme.of(context).textTheme.titleMedium,
          );
          if (feedback.isEmpty) {
            return Row(
              children: [
                Expanded(child: title),
                Text(
                  "Pas encore d'avis",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }
          final average =
              feedback.map((f) => f.rating.score).reduce((a, b) => a + b) /
              feedback.length;
          final emoji = average >= 2.5
              ? "😊"
              : average >= 1.5
              ? "😐"
              : "😠";
          return Row(
            children: [
              Expanded(child: title),
              Text(
                "${average.toStringAsFixed(1)}/3 $emoji · ${feedback.length} avis",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.field),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
        ),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
