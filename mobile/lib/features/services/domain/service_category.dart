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

  String get storageValue => name;

  static ServiceCategory fromStorage(String value) =>
      ServiceCategory.values.firstWhere((c) => c.name == value);
}
