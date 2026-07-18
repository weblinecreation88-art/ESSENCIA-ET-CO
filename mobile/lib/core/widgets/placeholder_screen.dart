import "package:flutter/material.dart";

import "../theme/app_colors.dart";

/// Écran générique utilisé par les routes des futures fonctionnalités
/// (agenda, services, réservation, notifications...) tant qu'elles ne sont
/// pas implémentées, pour valider que la navigation fonctionne bout en bout.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.icon = Icons.construction_rounded,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 20),
            Text("Écran à venir", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
