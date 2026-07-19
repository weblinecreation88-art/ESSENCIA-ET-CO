import "package:flutter/material.dart";

import "../../core/theme/app_radii.dart";
import "../../core/theme/app_spacing.dart";
import "../../core/theme/app_theme.dart";

const _faq = [
  (
    question: "Comment ajouter un proche ?",
    answer: "Depuis l'accueil, appuyez sur \"Ma famille\" puis sur \"Ajouter un proche\".",
  ),
  (
    question: "Comment réserver un service ?",
    answer: "Depuis l'accueil, appuyez sur \"Réserver un service\", choisissez une catégorie, un prestataire, puis une date et une heure.",
  ),
  (
    question: "Comment activer ou désactiver les notifications ?",
    answer: "Rendez-vous dans Profil > Mes préférences pour choisir les notifications que vous souhaitez recevoir.",
  ),
  (
    question: "Comment supprimer mon compte ?",
    answer: "Écrivez-nous à contact@essencia-co.fr, notre équipe traitera votre demande rapidement.",
  ),
];

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aide et support")),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          for (final item in _faq)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.card),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.question,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.answer, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            "Besoin d'aide supplémentaire ? Écrivez-nous à contact@essencia-co.fr",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
