import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_radii.dart";

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
      appBar: AppBar(title: const Text("Essencia & Co")),
      body: _AccueilTab(),
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
      (icon: Icons.people_alt_rounded, label: "Ma famille", route: "/chat"),
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
        route: "/booking",
      ),
      (
        icon: Icons.recycling_rounded,
        label: "Seconde vie",
        route: "/services",
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bonjour 👋",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
