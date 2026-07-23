import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";

class EmergencyNumbersScreen extends StatelessWidget {
  const EmergencyNumbersScreen({super.key});

  static const _numbers = [
    _EmergencyNumber(
      name: "SAMU",
      number: "15",
      description: "Urgence médicale",
      icon: Icons.medical_services_rounded,
      color: AppColors.secondary,
    ),
    _EmergencyNumber(
      name: "Pompiers",
      number: "18",
      description: "Incendie, accident ou secours",
      icon: Icons.fire_truck_rounded,
      color: AppColors.warning,
    ),
    _EmergencyNumber(
      name: "Police secours",
      number: "17",
      description: "Danger ou problème de sécurité",
      icon: Icons.local_police_rounded,
      color: AppColors.primaryDark,
    ),
    _EmergencyNumber(
      name: "Urgence européenne",
      number: "112",
      description: "Toutes les urgences en France et en Europe",
      icon: Icons.sos_rounded,
      color: AppColors.success,
    ),
    _EmergencyNumber(
      name: "Urgence accessible",
      number: "114",
      description: "SMS pour les personnes sourdes ou malentendantes",
      icon: Icons.sms_rounded,
      color: AppColors.primary,
      useSms: true,
    ),
  ];

  Future<void> _contact(
    BuildContext context,
    _EmergencyNumber emergency,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(emergency.icon, color: emergency.color, size: 40),
        title: Text(
          emergency.useSms
              ? "Envoyer un SMS au ${emergency.number} ?"
              : "Appeler le ${emergency.number} ?",
          textAlign: TextAlign.center,
        ),
        content: Text(
          "${emergency.name} — ${emergency.description}",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: emergency.color),
            onPressed: () => Navigator.of(context).pop(true),
            icon: Icon(
              emergency.useSms ? Icons.sms_rounded : Icons.call_rounded,
            ),
            label: Text(emergency.useSms ? "Écrire" : "Appeler"),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final uri = emergency.useSms
        ? Uri(scheme: "sms", path: emergency.number)
        : Uri(scheme: "tel", path: emergency.number);
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible d'ouvrir ${emergency.useSms ? "les SMS" : "l'appel"} "
            "sur cet appareil.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Numéros d'urgence")),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.secondary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    "France · appels gratuits 24 h/24. "
                    "Touchez un numéro pour contacter les secours.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final emergency in _numbers) ...[
            _EmergencyButton(
              emergency: emergency,
              onTap: () => _contact(context, emergency),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            "N'utilisez ces numéros qu'en cas d'urgence réelle.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton({required this.emergency, required this.onTap});

  final _EmergencyNumber emergency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "${emergency.name}, ${emergency.number}",
      hint: emergency.useSms ? "Ouvrir les SMS" : "Appeler les secours",
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: emergency.color, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: emergency.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(emergency.icon, color: emergency.color, size: 30),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emergency.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      emergency.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emergency.number,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: emergency.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(
                    emergency.useSms ? Icons.sms_rounded : Icons.call_rounded,
                    color: emergency.color,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyNumber {
  const _EmergencyNumber({
    required this.name,
    required this.number,
    required this.description,
    required this.icon,
    required this.color,
    this.useSms = false,
  });

  final String name;
  final String number;
  final String description;
  final IconData icon;
  final Color color;
  final bool useSms;
}
