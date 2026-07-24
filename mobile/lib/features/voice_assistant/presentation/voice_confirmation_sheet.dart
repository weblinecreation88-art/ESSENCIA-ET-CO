import "package:flutter/material.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

/// Boîte de confirmation obligatoire avant toute action vocale sensible
/// (appel, envoi de message), même pattern que `_confirmMissingInfo` dans
/// `family_screen.dart`.
Future<void> showVoiceConfirmationSheet(
  BuildContext context, {
  required String message,
  required VoidCallback onConfirm,
  required VoidCallback onCancel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic_rounded, color: AppColors.primary, size: 32),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCancel();
                  },
                  child: const Text("Annuler"),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  child: const Text("Confirmer"),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
