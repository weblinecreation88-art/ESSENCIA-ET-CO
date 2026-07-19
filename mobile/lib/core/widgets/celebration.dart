import "dart:math";

import "package:confetti/confetti.dart";
import "package:flutter/material.dart";

import "../theme/app_colors.dart";

/// Affiche une courte pluie de confettis par-dessus l'écran courant, pour
/// célébrer une action réussie (rendez-vous ajouté, réservation confirmée...).
void celebrate(BuildContext context) {
  final overlay = Overlay.of(context);
  final controller = ConfettiController(duration: const Duration(milliseconds: 600));

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: controller,
          blastDirection: pi / 2,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 28,
          maxBlastForce: 18,
          minBlastForce: 6,
          gravity: 0.3,
          colors: const [
            AppColors.primary,
            AppColors.secondary,
            AppColors.success,
            AppColors.warning,
          ],
        ),
      ),
    ),
  );

  overlay.insert(entry);
  controller.play();

  Future.delayed(const Duration(milliseconds: 1800), () {
    entry.remove();
    controller.dispose();
  });
}
