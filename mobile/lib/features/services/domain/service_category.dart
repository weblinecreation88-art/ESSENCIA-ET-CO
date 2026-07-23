import "package:flutter/material.dart";

enum ServiceCategory {
  santeAccompagnement,
  beauteBienEtre,
  alimentationRestauration,
  transportMobilite,
  maisonVieQuotidienne,
  compagnieAccompagnement,
  loisirsCulture,
  animaux,
  commercesServices,
  accompagnementSpirituel,
  familleAidants;

  String get label => switch (this) {
    ServiceCategory.santeAccompagnement => "Santé & accompagnement",
    ServiceCategory.beauteBienEtre => "Beauté & bien-être",
    ServiceCategory.alimentationRestauration => "Alimentation & restauration",
    ServiceCategory.transportMobilite => "Transport & mobilité",
    ServiceCategory.maisonVieQuotidienne => "Maison & vie quotidienne",
    ServiceCategory.compagnieAccompagnement => "Compagnie & accompagnement",
    ServiceCategory.loisirsCulture => "Loisirs & culture",
    ServiceCategory.animaux => "Animaux",
    ServiceCategory.commercesServices => "Commerces & services",
    ServiceCategory.accompagnementSpirituel => "Accompagnement spirituel",
    ServiceCategory.familleAidants => "Famille & aidants",
  };

  IconData get icon => switch (this) {
    ServiceCategory.santeAccompagnement => Icons.medical_services_rounded,
    ServiceCategory.beauteBienEtre => Icons.spa_rounded,
    ServiceCategory.alimentationRestauration => Icons.restaurant_rounded,
    ServiceCategory.transportMobilite => Icons.local_taxi_rounded,
    ServiceCategory.maisonVieQuotidienne => Icons.home_repair_service_rounded,
    ServiceCategory.compagnieAccompagnement => Icons.volunteer_activism_rounded,
    ServiceCategory.loisirsCulture => Icons.palette_rounded,
    ServiceCategory.animaux => Icons.pets_rounded,
    ServiceCategory.commercesServices => Icons.storefront_rounded,
    ServiceCategory.accompagnementSpirituel => Icons.self_improvement_rounded,
    ServiceCategory.familleAidants => Icons.family_restroom_rounded,
  };

  List<String> get specialties => switch (this) {
    ServiceCategory.santeAccompagnement => const [
      "Médecins",
      "Infirmiers",
      "Kinésithérapeutes",
      "Ergothérapeutes",
      "Psychologues",
      "Sophrologues",
      "Podologues",
      "Orthophonistes",
      "Opticiens",
      "Audioprothésistes",
    ],
    ServiceCategory.beauteBienEtre => const [
      "Coiffeurs",
      "Barbiers",
      "Esthéticiennes",
      "Manucures",
      "Pédicures",
      "Masseurs bien-être",
      "Réflexologues",
      "Spas et instituts de beauté",
    ],
    ServiceCategory.alimentationRestauration => const [
      "Restaurants",
      "Traiteurs",
      "Cuisiniers à domicile",
      "Boulangers",
      "Pâtissiers",
      "Épiceries",
      "Primeurs",
      "Services de livraison de repas",
    ],
    ServiceCategory.transportMobilite => const [
      "Chauffeurs",
      "Taxis",
      "VTC",
      "Transport adapté",
      "Accompagnateurs",
      "Transport de personnes à mobilité réduite",
    ],
    ServiceCategory.maisonVieQuotidienne => const [
      "Aides à domicile",
      "Services de ménage",
      "Pressing et blanchisserie",
      "Repassage",
      "Couturiers",
      "Petits travaux et bricolage",
      "Informaticiens",
      "Assistance administrative",
    ],
    ServiceCategory.compagnieAccompagnement => const [
      "Visiteurs à domicile",
      "Accompagnateurs",
      "Promeneurs",
      "Bénévoles",
      "Associations",
      "Aidants",
      "Médiateurs sociaux",
    ],
    ServiceCategory.loisirsCulture => const [
      "Musiciens",
      "Chanteurs",
      "Artistes",
      "Animateurs",
      "Professeurs",
      "Ateliers créatifs",
      "Jeux et activités adaptées",
      "Théâtres et spectacles",
    ],
    ServiceCategory.animaux => const [
      "Médiation animale",
      "Éducateurs animaliers",
      "Promeneurs d'animaux",
      "Services de soins pour animaux",
    ],
    ServiceCategory.commercesServices => const [
      "Magasins de vêtements",
      "Fleuristes",
      "Librairies",
      "Cadeaux",
      "Opticiens",
      "Magasins spécialisés handicap",
      "Matériel médical",
    ],
    ServiceCategory.accompagnementSpirituel => const [
      "Aumôniers",
      "Responsables religieux",
      "Associations cultuelles",
      "Accompagnateurs spirituels",
    ],
    ServiceCategory.familleAidants => const [
      "Services de garde",
      "Accompagnement des proches aidants",
      "Associations spécialisées",
      "Soutien aux familles",
    ],
  };

  String get storageValue => name;

  static ServiceCategory fromStorage(String value) {
    for (final category in ServiceCategory.values) {
      if (category.name == value) return category;
    }

    // Compatibilité avec les catégories utilisées avant la nouvelle taxonomie.
    return switch (value) {
      "coiffure" ||
      "pedicurePodologue" ||
      "massageDetente" => ServiceCategory.beauteBienEtre,
      "activitesAnimations" => ServiceCategory.loisirsCulture,
      "autres" => ServiceCategory.commercesServices,
      _ => throw ArgumentError.value(value, "value", "Catégorie inconnue"),
    };
  }
}
