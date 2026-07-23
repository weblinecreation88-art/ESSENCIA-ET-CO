enum SubscriptionTier {
  standard,
  comfort,
  premium;

  String get label => switch (this) {
    SubscriptionTier.standard => "Standard",
    SubscriptionTier.comfort => "Confort",
    SubscriptionTier.premium => "Premium",
  };

  String get tagline => switch (this) {
    SubscriptionTier.standard => "L'essentiel pour rester connecté",
    SubscriptionTier.comfort => "Plus de sérénité au quotidien",
    SubscriptionTier.premium => "L'accompagnement le plus complet",
  };
}

enum SubscriptionDuration {
  fourMonths(4),
  sixMonths(6),
  twelveMonths(12);

  const SubscriptionDuration(this.months);

  final int months;

  String get label => "$months mois";
}

class SubscriptionOffer {
  const SubscriptionOffer({
    required this.tier,
    required this.duration,
    this.priceLabel,
    this.checkoutUrl,
  });

  final SubscriptionTier tier;
  final SubscriptionDuration duration;
  final String? priceLabel;
  final String? checkoutUrl;

  bool get isAvailable => checkoutUrl?.isNotEmpty == true;
}

/// Configuration unique des tarifs et liens Stripe.
///
/// Renseigner `priceLabel` et `checkoutUrl` pour chaque offre suffit à activer
/// automatiquement le bouton d'abonnement correspondant dans le paywall.
const subscriptionOffers = [
  SubscriptionOffer(
    tier: SubscriptionTier.standard,
    duration: SubscriptionDuration.fourMonths,
  ),
  SubscriptionOffer(
    tier: SubscriptionTier.standard,
    duration: SubscriptionDuration.sixMonths,
  ),
  SubscriptionOffer(
    tier: SubscriptionTier.standard,
    duration: SubscriptionDuration.twelveMonths,
  ),
  SubscriptionOffer(
    tier: SubscriptionTier.comfort,
    duration: SubscriptionDuration.fourMonths,
  ),
  SubscriptionOffer(
    tier: SubscriptionTier.comfort,
    duration: SubscriptionDuration.sixMonths,
  ),
  SubscriptionOffer(
    tier: SubscriptionTier.comfort,
    duration: SubscriptionDuration.twelveMonths,
  ),
  SubscriptionOffer(
    tier: SubscriptionTier.premium,
    duration: SubscriptionDuration.fourMonths,
  ),
  SubscriptionOffer(
    tier: SubscriptionTier.premium,
    duration: SubscriptionDuration.sixMonths,
  ),
  SubscriptionOffer(
    tier: SubscriptionTier.premium,
    duration: SubscriptionDuration.twelveMonths,
  ),
];

SubscriptionOffer subscriptionOfferFor(
  SubscriptionTier tier,
  SubscriptionDuration duration,
) => subscriptionOffers.firstWhere(
  (offer) => offer.tier == tier && offer.duration == duration,
);
