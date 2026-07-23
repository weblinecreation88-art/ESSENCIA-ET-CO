import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../domain/subscription_offer.dart";

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  SubscriptionTier _selectedTier = SubscriptionTier.comfort;
  SubscriptionDuration _selectedDuration = SubscriptionDuration.twelveMonths;

  Future<void> _openCheckout(SubscriptionOffer offer) async {
    final url = offer.checkoutUrl;
    if (url == null || url.isEmpty) return;

    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'ouvrir le paiement Stripe."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedOffer = subscriptionOfferFor(
      _selectedTier,
      _selectedDuration,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Mon abonnement")),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(AppRadii.card),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "Choisissez votre formule",
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Un abonnement adapté à vos besoins et à votre rythme.",
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text("Formule", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final tier in SubscriptionTier.values) ...[
            _TierCard(
              tier: tier,
              isSelected: tier == _selectedTier,
              onTap: () => setState(() => _selectedTier = tier),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text("Durée", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<SubscriptionDuration>(
            showSelectedIcon: false,
            segments: [
              for (final duration in SubscriptionDuration.values)
                ButtonSegment(value: duration, label: Text(duration.label)),
            ],
            selected: {_selectedDuration},
            onSelectionChanged: (selection) =>
                setState(() => _selectedDuration = selection.first),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.border),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTier.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            _selectedDuration.label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      selectedOffer.priceLabel ?? "Tarif à venir",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: selectedOffer.isAvailable
                        ? () => _openCheckout(selectedOffer)
                        : null,
                    icon: const Icon(Icons.lock_rounded),
                    label: Text(
                      selectedOffer.isAvailable
                          ? "S'abonner avec Stripe"
                          : "Lien Stripe bientôt disponible",
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      "Paiement sécurisé par Stripe",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.isSelected,
    required this.onTap,
  });

  final SubscriptionTier tier;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon => switch (tier) {
    SubscriptionTier.standard => Icons.favorite_outline_rounded,
    SubscriptionTier.comfort => Icons.spa_rounded,
    SubscriptionTier.premium => Icons.workspace_premium_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.09)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.field),
              ),
              child: Icon(_icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tier.tagline,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
