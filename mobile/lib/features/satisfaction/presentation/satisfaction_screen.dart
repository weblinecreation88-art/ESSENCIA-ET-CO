import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../feedback/domain/staff_feedback.dart";
import "../application/satisfaction_providers.dart";

class SatisfactionScreen extends ConsumerStatefulWidget {
  const SatisfactionScreen({super.key});

  @override
  ConsumerState<SatisfactionScreen> createState() => _SatisfactionScreenState();
}

class _SatisfactionScreenState extends ConsumerState<SatisfactionScreen> {
  final _commentController = TextEditingController();
  FeedbackRating? _selected;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final rating = _selected;
    if (rating == null) return;
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(satisfactionRepositoryProvider)
          .submit(rating: rating, comment: _commentController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Merci, votre avis a été envoyé anonymement.")),
      );
      context.go("/home");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Votre satisfaction")),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            "Comment jugez-vous votre expérience globale avec l'établissement ? "
            "Votre avis est totalement anonyme.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final rating in FeedbackRating.values)
                _RatingButton(
                  rating: rating,
                  selected: _selected == rating,
                  onTap: () => setState(() => _selected = rating),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Commentaire (optionnel)",
              hintText: "Ce qui vous a plu, ce qui pourrait être amélioré...",
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selected == null || _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Envoyer anonymement"),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.rating,
    required this.selected,
    required this.onTap,
  });

  final FeedbackRating rating;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: onTap,
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(rating.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: AppSpacing.xs),
            Text(rating.label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
