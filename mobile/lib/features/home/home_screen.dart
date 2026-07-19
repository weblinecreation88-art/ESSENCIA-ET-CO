import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_radii.dart";
import "../../core/theme/app_spacing.dart";
import "../../core/theme/app_theme.dart";
import "../auth/application/auth_providers.dart";
import "../notifications/application/notification_providers.dart";

/// Écran d'accueil avec la bottom nav (Accueil / Messages / Agenda / Profil),
/// reprenant la structure de navigation principale des maquettes. Le contenu
/// de l'onglet "Accueil" est un placeholder tant que la fonctionnalité n'est
/// pas construite ; les autres onglets naviguent vers leurs routes dédiées.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _tabs = [
    (route: null, icon: Icons.home_rounded, label: "Accueil"),
    (route: "/chat", icon: Icons.chat_bubble_rounded, label: "Messages"),
    (route: "/agenda", icon: Icons.calendar_today_rounded, label: "Agenda"),
    (route: "/profile", icon: Icons.person_rounded, label: "Profil"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: const _AccueilTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.label),
        ],
        onTap: (i) {
          final route = _tabs[i].route;
          if (route != null) {
            context.push(route);
            return;
          }
          setState(() => _index = i);
        },
      ),
    );
  }
}

class _AccueilTab extends StatelessWidget {
  const _AccueilTab();

  @override
  Widget build(BuildContext context) {
    const quickActions = [
      (
        icon: Icons.people_alt_rounded,
        label: "Ma famille",
        route: "/profile/family",
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        label: "Messages",
        route: "/chat",
      ),
      (icon: Icons.photo_camera_rounded, label: "Photos", route: "/services"),
      (
        icon: Icons.calendar_month_rounded,
        label: "Agenda",
        route: "/agenda",
      ),
      (
        icon: Icons.event_available_rounded,
        label: "Réserver un service",
        route: "/services",
      ),
      (
        icon: Icons.recycling_rounded,
        label: "Seconde vie",
        route: "/services",
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HomeHero(),
          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _NextAppointmentCard(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Accès rapides",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.5,
                  children: [
                    for (final action in quickActions)
                      _QuickActionCard(
                        icon: action.icon,
                        label: action.label,
                        onTap: () => context.push(action.route),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bandeau hero en tête de l'accueil : dégradé de marque, salutation et
/// avatar, sur le même principe que le Hero de la landing page web.
class _HomeHero extends ConsumerWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        MediaQuery.of(context).padding.top + AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bonjour Marie 👋",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Voici vos activités du jour",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push("/notifications"),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                  ),
                ),
                if (user != null)
                  StreamBuilder<int>(
                    stream: ref
                        .read(notificationRepositoryProvider)
                        .watchUnreadCount(user.uid),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      if (count == 0) return const SizedBox.shrink();
                      return Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            "$count",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte "prochain rendez-vous" qui chevauche le bas du hero, comme sur la
/// maquette de l'écran d'accueil.
class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadii.field),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Prochain rendez-vous",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Coiffeur — Aujourd'hui 14h30",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push("/agenda"),
            child: const Text("Voir"),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 36,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
