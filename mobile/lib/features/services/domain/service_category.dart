import "package:flutter/material.dart";

enum ServiceCategory {
  coiffure,
  beauteBienEtre,
  pedicurePodologue,
  massageDetente,
  activitesAnimations,
  autres;

  String get label => switch (this) {
    ServiceCategory.coiffure => "Coiffeur",
    ServiceCategory.beauteBienEtre => "Esthétique / Bien-être",
    ServiceCategory.pedicurePodologue => "Pédicure / Podologue",
    ServiceCategory.massageDetente => "Massage / Détente",
    ServiceCategory.activitesAnimations => "Activités / Animations",
    ServiceCategory.autres => "Autres services",
  };

  IconData get icon => switch (this) {
    ServiceCategory.coiffure => Icons.content_cut_rounded,
    ServiceCategory.beauteBienEtre => Icons.spa_rounded,
    ServiceCategory.pedicurePodologue => Icons.healing_rounded,
    ServiceCategory.massageDetente => Icons.self_improvement_rounded,
    ServiceCategory.activitesAnimations => Icons.theater_comedy_rounded,
    ServiceCategory.autres => Icons.more_horiz_rounded,
  };

  /// Illustration de catégorie, affichée sur les tuiles de services.
  String get imageAsset => switch (this) {
    ServiceCategory.coiffure => "assets/images/services/coiffure.png",
    ServiceCategory.beauteBienEtre =>
      "assets/images/services/beaute_bien_etre.png",
    ServiceCategory.pedicurePodologue =>
      "assets/images/services/pedicure_podologue.png",
    ServiceCategory.massageDetente =>
      "assets/images/services/massage_detente.png",
    ServiceCategory.activitesAnimations =>
      "assets/images/services/activites_animations.png",
    ServiceCategory.autres => "assets/images/services/autres.png",
  };

  String get storageValue => name;

  static ServiceCategory fromStorage(String value) =>
      ServiceCategory.values.firstWhere((c) => c.name == value);
}
