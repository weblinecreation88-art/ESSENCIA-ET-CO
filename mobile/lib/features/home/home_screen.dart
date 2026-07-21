import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:showcaseview/showcaseview.dart";

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
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  final _bellShowcaseKey = GlobalKey();
  final _quickActionsShowcaseKey = GlobalKey();
  final _navShowcaseKey = GlobalKey();

  static const _tabs = [
    (route: null, icon: Icons.home_rounded, label: "Accueil"),
    (route: "/chat", icon: Icons.chat_bubble_rounded, label: "Messages"),
    (route: "/agenda", icon: Icons.calendar_today_rounded, label: "Agenda"),
    (route: "/profile", icon: Icons.person_rounded, label: "Profil"),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartGuide());
  }

  Future<void> _maybeStartGuide() async {
    final uid = ref.read(authRepositoryProvider).currentUser?.uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = "onboarding_home_seen_v1_$uid";
    if (prefs.getBool(key) ?? false) return;
    await prefs.setBool(key, true);
    if (!mounted) return;
    ShowCaseWidget.of(context).startShowCase([
      _bellShowcaseKey,
      _quickActionsShowcaseKey,
      _navShowcaseKey,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _AccueilTab(
        bellShowcaseKey: _bellShowcaseKey,
        quickActionsShowcaseKey: _quickActionsShowcaseKey,
      ),
      bottomNavigationBar: Showcase(
        key: _navShowcaseKey,
        description: "Naviguez ici entre les différentes sections de l'app.",
        tooltipBackgroundColor: AppColors.surface,
        descTextStyle: const TextStyle(color: AppColors.text, fontSize: 14),
        targetPadding: const EdgeInsets.all(4),
        child: BottomNavigationBar(
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
      ),
    );
  }
}

class _AccueilTab extends StatelessWidget {
  const _AccueilTab({
    required this.bellShowcaseKey,
    required this.quickActionsShowcaseKey,
  });

  final GlobalKey bellShowcaseKey;
  final GlobalKey quickActionsShowcaseKey;

  @override
  Widget build(BuildContext context) {
    const quickActions = [
      (
        icon: Icons.people_alt_rounded,
        label: "Ma famille",
        route: "/profile/family",
        color: AppColors.roleFamily,
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        label: "Messages",
        route: "/chat",
        color: AppColors.roleFamily,
      ),
      (
        icon: Icons.photo_camera_rounded,
        label: "Photos",
        route: "/photos",
        color: AppColors.roleResident,
      ),
      (
        icon: Icons.calendar_month_rounded,
        label: "Agenda",
        route: "/agenda",
        color: AppColors.roleResident,
      ),
      (
        icon: Icons.menu_book_rounded,
        label: "Journal de vie",
        route: "/journal",
        color: AppColors.roleResident,
      ),
      (
        icon: Icons.event_available_rounded,
        label: "Réserver un service",
        route: "/services",
        color: AppColors.roleProvider,
      ),
      (
        icon: Icons.recycling_rounded,
        label: "Seconde vie",
        route: "/second-life",
        color: AppColors.roleProvider,
      ),
      (
        icon: Icons.emoji_emotions_rounded,
        label: "Noter le personnel",
        route: "/staff",
        color: AppColors.roleProfessional,
      ),
      (
        icon: Icons.sentiment_satisfied_alt_rounded,
        label: "Donner mon avis",
        route: "/satisfaction",
        color: AppColors.roleFamily,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeHero(bellShowcaseKey: bellShowcaseKey),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _NextAppointmentCard(),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Showcase(
                key: quickActionsShowcaseKey,
                description:
                    "Retrouvez ici vos actions principales : famille, "
                    "messages, agenda, services...",
                tooltipBackgroundColor: AppColors.surface,
                descTextStyle: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                ),
                targetPadding: const EdgeInsets.all(8),
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
                      childAspectRatio: 1.45,
                      children: [
                        for (final action in quickActions)
                          _QuickActionCard(
                            icon: action.icon,
                            label: action.label,
                            color: action.color,
                            onTap: () => context.push(action.route),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
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
  const _HomeHero({required this.bellShowcaseKey});

  final GlobalKey bellShowcaseKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        MediaQuery.of(context).padding.top + AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl,
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
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
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
          Showcase(
            key: bellShowcaseKey,
            description: "Vos notifications s'affichent ici.",
            tooltipBackgroundColor: AppColors.surface,
            descTextStyle: const TextStyle(color: AppColors.text, fontSize: 14),
            targetShapeBorder: const CircleBorder(),
            child: GestureDetector(
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
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              height: 40,
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
