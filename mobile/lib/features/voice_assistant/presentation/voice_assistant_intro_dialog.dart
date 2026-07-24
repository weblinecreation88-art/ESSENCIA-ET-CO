import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../auth/application/auth_providers.dart";

class _SensiCommandGroup {
  const _SensiCommandGroup({
    required this.icon,
    required this.color,
    required this.title,
    required this.examples,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<String> examples;
}

const _groups = [
  _SensiCommandGroup(
    icon: Icons.home_rounded,
    color: AppColors.roleResident,
    title: "Navigation",
    examples: ["« Ouvre mon tableau de bord »", "« Montre mes rendez-vous »"],
  ),
  _SensiCommandGroup(
    icon: Icons.favorite_rounded,
    color: AppColors.secondary,
    title: "Santé et bien-être",
    examples: [
      "« J'ai besoin d'aide »",
      "« Appelle ma fille »",
      "« Préviens mon fils que tout va bien »",
    ],
  ),
  _SensiCommandGroup(
    icon: Icons.groups_rounded,
    color: AppColors.roleProfessional,
    title: "Personnel",
    examples: ["« Je veux parler au personnel »", "« Je souhaite donner mon avis »"],
  ),
  _SensiCommandGroup(
    icon: Icons.wb_sunny_rounded,
    color: AppColors.roleProvider,
    title: "Vie quotidienne",
    examples: [
      "« Quel est mon prochain rendez-vous ? »",
      "« Lire mes notifications »",
      "« Que dois-je faire aujourd'hui ? »",
    ],
  ),
];

/// Affiche, une seule fois par compte, une présentation de SENSI et des
/// principales familles de commandes vocales disponibles.
Future<void> maybeShowSensiIntro(BuildContext context, WidgetRef ref) async {
  final uid = ref.read(authRepositoryProvider).currentUser?.uid;
  if (uid == null) return;
  final prefs = await SharedPreferences.getInstance();
  final key = "sensi_intro_seen_v1_$uid";
  if (prefs.getBool(key) ?? false) return;
  await prefs.setBool(key, true);
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                decoration: const BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadii.card),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Bonjour, je suis SENSI 👋",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "Voici ce que vous pouvez me demander",
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final group in _groups) ...[
                      _GroupTile(group: group),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("J'ai compris"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final _SensiCommandGroup group;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: group.color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(group.icon, color: group.color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              for (final example in group.examples)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    example,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
