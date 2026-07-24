import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../services/domain/booking.dart";
import "../../services/domain/service_category.dart";
import "../application/auth_providers.dart";
import "../domain/user_profile.dart";
import "../domain/user_role.dart";

class RoleOnboardingScreen extends ConsumerStatefulWidget {
  const RoleOnboardingScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<RoleOnboardingScreen> createState() =>
      _RoleOnboardingScreenState();
}

class _RoleOnboardingScreenState extends ConsumerState<RoleOnboardingScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _establishmentController = TextEditingController();
  final _accessibilityController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _residentEmailController = TextEditingController();
  final _organizationController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _interventionAreaController = TextEditingController();
  final _siretController = TextEditingController();

  int _step = 0;
  bool _isSubmitting = false;
  String? _errorMessage;
  GuardianType _guardianType = GuardianType.relative;
  ServiceCategory? _serviceCategory;
  final Set<String> _selectedSpecialties = {};
  final Set<AppointmentMode> _selectedModes = {};

  UserRole get role => widget.role;
  bool get _isServiceRole =>
      role == UserRole.provider || role == UserRole.professional;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authRepositoryProvider).currentUser;
    final suggestedName = user?.displayName?.trim();
    _nameController.text = suggestedName?.isNotEmpty == true
        ? suggestedName!
        : user?.email?.split("@").first ?? "";
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _phoneController,
      _establishmentController,
      _accessibilityController,
      _emergencyContactController,
      _relationshipController,
      _residentEmailController,
      _organizationController,
      _jobTitleController,
      _businessNameController,
      _descriptionController,
      _interventionAreaController,
      _siretController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _stepTitle => switch (_step) {
    0 => "Vos informations",
    1 => switch (role) {
      UserRole.resident => "Votre quotidien",
      UserRole.family => "Le proche accompagné",
      UserRole.professional => "Votre établissement",
      UserRole.provider => "Votre activité",
    },
    _ => _isServiceRole ? "Vos prestations" : "Vérification",
  };

  bool _validateCurrentStep() {
    String? error;
    if (_step == 0 && _nameController.text.trim().isEmpty) {
      error = "Veuillez indiquer votre nom.";
    } else if (_step == 1) {
      error = switch (role) {
        UserRole.resident when _establishmentController.text.trim().isEmpty =>
          "Veuillez indiquer votre établissement ou lieu de résidence.",
        UserRole.family when _relationshipController.text.trim().isEmpty =>
          "Veuillez indiquer votre lien avec le proche.",
        UserRole.family when _residentEmailController.text.trim().isEmpty =>
          "Veuillez indiquer l'e-mail du proche accompagné.",
        UserRole.professional
            when _organizationController.text.trim().isEmpty =>
          "Veuillez indiquer votre établissement.",
        UserRole.professional when _jobTitleController.text.trim().isEmpty =>
          "Veuillez indiquer votre métier ou fonction.",
        UserRole.provider when _businessNameController.text.trim().isEmpty =>
          "Veuillez indiquer le nom de votre activité.",
        UserRole.provider when _descriptionController.text.trim().isEmpty =>
          "Veuillez présenter brièvement votre prestation.",
        UserRole.provider
            when _interventionAreaController.text.trim().isEmpty =>
          "Veuillez indiquer votre zone d'intervention.",
        _ => null,
      };
    } else if (_step == 2 && _isServiceRole) {
      if (_serviceCategory == null) {
        error = "Veuillez choisir une catégorie de services.";
      } else if (_selectedSpecialties.isEmpty) {
        error = "Choisissez au moins une sous-catégorie.";
      } else if (_selectedModes.isEmpty) {
        error = "Choisissez au moins une modalité de rendez-vous.";
      }
    } else if (_step == 2 &&
        role == UserRole.family &&
        _guardianType == GuardianType.organization &&
        _organizationController.text.trim().isEmpty) {
      error = "Veuillez indiquer le nom de l'organisme.";
    }

    setState(() => _errorMessage = error);
    return error == null;
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    setState(() {
      _errorMessage = null;
      _step += 1;
    });
  }

  void _back() {
    if (_step == 0) {
      context.go("/role-selection");
      return;
    }
    setState(() {
      _errorMessage = null;
      _step -= 1;
    });
  }

  Map<String, dynamic> _buildRoleDetails() {
    final details = <String, dynamic>{"phone": _phoneController.text.trim()};

    switch (role) {
      case UserRole.resident:
        details.addAll({
          "establishment": _establishmentController.text.trim(),
          "accessibilityNeeds": _accessibilityController.text.trim(),
          "emergencyContact": _emergencyContactController.text.trim(),
        });
      case UserRole.family:
        details.addAll({
          "relationship": _relationshipController.text.trim(),
          "linkedResidentEmail": _residentEmailController.text.trim(),
          "guardianType": _guardianType.storageValue,
          if (_guardianType == GuardianType.organization)
            "organizationName": _organizationController.text.trim(),
        });
      case UserRole.professional:
        details.addAll({
          "organizationName": _organizationController.text.trim(),
          "jobTitle": _jobTitleController.text.trim(),
          "serviceCategories": [_serviceCategory!.storageValue],
          "serviceSpecialties": _selectedSpecialties.toList()..sort(),
          "appointmentModes": [
            for (final mode in _selectedModes) mode.storageValue,
          ],
        });
      case UserRole.provider:
        details.addAll({
          "businessName": _businessNameController.text.trim(),
          "description": _descriptionController.text.trim(),
          "interventionArea": _interventionAreaController.text.trim(),
          "siret": _siretController.text.trim(),
          "serviceCategories": [_serviceCategory!.storageValue],
          "serviceSpecialties": _selectedSpecialties.toList()..sort(),
          "appointmentModes": [
            for (final mode in _selectedModes) mode.storageValue,
          ],
        });
    }
    return details;
  }

  Future<void> _submit() async {
    if (!_validateCurrentStep()) return;
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      context.go("/welcome");
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(userProfileRepositoryProvider)
          .completeOnboarding(
            uid: user.uid,
            displayName: _nameController.text.trim(),
            roleDetails: _buildRoleDetails(),
          );
      if (!mounted) return;
      context.go("/home");
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              "Impossible d'enregistrer le profil pour le moment. "
              "Vérifiez votre connexion puis réessayez.";
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _isSubmitting ? null : _back,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: "Retour",
        ),
        title: const Text("Configurer mon profil"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _OnboardingHeader(role: role, step: _step, title: _stepTitle),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(context),
                  ),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _back,
                        child: const Text("Précédent"),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting
                          ? null
                          : _step == 2
                          ? _submit
                          : _next,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_step == 2 ? "Terminer" : "Continuer"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) => switch (_step) {
    0 => _QuestionCard(
      title: "Faisons connaissance",
      subtitle: "Ces informations permettent de personnaliser votre espace.",
      children: [
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: "Nom et prénom",
            prefixIcon: Icon(Icons.person_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Téléphone (optionnel)",
            prefixIcon: Icon(Icons.phone_rounded),
          ),
        ),
      ],
    ),
    1 => _buildRoleQuestions(),
    _ => _buildFinalQuestions(context),
  };

  Widget _buildRoleQuestions() => switch (role) {
    UserRole.resident => _QuestionCard(
      title: "Votre lieu de vie",
      subtitle: "Indiquez uniquement ce qui est utile à votre accompagnement.",
      children: [
        TextField(
          controller: _establishmentController,
          decoration: const InputDecoration(
            labelText: "Établissement ou lieu de résidence",
            prefixIcon: Icon(Icons.home_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _accessibilityController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: "Besoins d'accessibilité (optionnel)",
            hintText: "Mobilité, audition, lecture…",
            prefixIcon: Icon(Icons.accessible_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _emergencyContactController,
          decoration: const InputDecoration(
            labelText: "Contact d'urgence (optionnel)",
            hintText: "Nom et téléphone",
            prefixIcon: Icon(Icons.contact_emergency_rounded),
          ),
        ),
      ],
    ),
    UserRole.family => _QuestionCard(
      title: "Votre proche",
      subtitle: "Ces informations serviront à préparer la mise en relation.",
      children: [
        TextField(
          controller: _relationshipController,
          decoration: const InputDecoration(
            labelText: "Lien avec le proche",
            hintText: "Fille, fils, conjoint, tuteur…",
            prefixIcon: Icon(Icons.family_restroom_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _residentEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "E-mail du proche accompagné",
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
        ),
      ],
    ),
    UserRole.professional => _QuestionCard(
      title: "Votre activité au centre",
      subtitle: "Présentez votre fonction aux résidents et aux familles.",
      children: [
        TextField(
          controller: _organizationController,
          decoration: const InputDecoration(
            labelText: "Établissement ou service",
            prefixIcon: Icon(Icons.apartment_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _jobTitleController,
          decoration: const InputDecoration(
            labelText: "Métier ou fonction",
            hintText: "Infirmier, animateur, psychologue…",
            prefixIcon: Icon(Icons.badge_rounded),
          ),
        ),
      ],
    ),
    UserRole.provider => _QuestionCard(
      title: "Votre activité",
      subtitle: "Ces informations seront visibles avant une réservation.",
      children: [
        TextField(
          controller: _businessNameController,
          decoration: const InputDecoration(
            labelText: "Nom de l'activité ou de l'entreprise",
            prefixIcon: Icon(Icons.storefront_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _descriptionController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: "Présentation de la prestation",
            hintText: "Décrivez simplement ce que vous proposez.",
            prefixIcon: Icon(Icons.description_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _interventionAreaController,
          decoration: const InputDecoration(
            labelText: "Zone d'intervention",
            hintText: "Ville, département ou rayon",
            prefixIcon: Icon(Icons.location_on_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _siretController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "SIRET (optionnel)",
            prefixIcon: Icon(Icons.numbers_rounded),
          ),
        ),
      ],
    ),
  };

  Widget _buildFinalQuestions(BuildContext context) {
    if (_isServiceRole) return _buildServiceQuestions(context);
    if (role == UserRole.family) {
      return _QuestionCard(
        title: "Type d'accompagnement",
        subtitle:
            "Précisez si le suivi est assuré par un proche ou un organisme.",
        children: [
          SegmentedButton<GuardianType>(
            segments: const [
              ButtonSegment(
                value: GuardianType.relative,
                icon: Icon(Icons.person_rounded),
                label: Text("Proche"),
              ),
              ButtonSegment(
                value: GuardianType.organization,
                icon: Icon(Icons.apartment_rounded),
                label: Text("Organisme"),
              ),
            ],
            selected: {_guardianType},
            onSelectionChanged: (selection) =>
                setState(() => _guardianType = selection.first),
          ),
          if (_guardianType == GuardianType.organization) ...[
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _organizationController,
              decoration: const InputDecoration(
                labelText: "Nom de l'organisme",
                hintText: "Ex. UDAF",
                prefixIcon: Icon(Icons.account_balance_rounded),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          const _PrivacyNote(
            text:
                "La liaison avec le dossier du proche devra être confirmée "
                "avant tout accès à ses informations.",
          ),
        ],
      );
    }

    return const _QuestionCard(
      title: "Votre profil est prêt",
      subtitle: "Vous pourrez modifier ces informations depuis votre profil.",
      children: [
        _PrivacyNote(
          text:
              "Seules les informations utiles au fonctionnement de l'application "
              "sont enregistrées.",
        ),
      ],
    );
  }

  Widget _buildServiceQuestions(BuildContext context) {
    final specialties = _serviceCategory?.specialties ?? const <String>[];
    return _QuestionCard(
      title: "Services proposés",
      subtitle: "Ces choix permettront d'afficher votre profil au bon endroit.",
      children: [
        DropdownButtonFormField<ServiceCategory>(
          initialValue: _serviceCategory,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: "Catégorie principale",
            prefixIcon: Icon(Icons.category_rounded),
          ),
          items: [
            for (final category in ServiceCategory.values)
              DropdownMenuItem(
                value: category,
                child: Text(category.label, softWrap: true),
              ),
          ],
          onChanged: (category) => setState(() {
            _serviceCategory = category;
            _selectedSpecialties.clear();
          }),
        ),
        if (_serviceCategory != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            "Sous-catégories",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final specialty in specialties)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _MultiSelectOption(
                label: specialty,
                isSelected: _selectedSpecialties.contains(specialty),
                onTap: () => setState(() {
                  if (!_selectedSpecialties.add(specialty)) {
                    _selectedSpecialties.remove(specialty);
                  }
                }),
              ),
            ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          "Modalités de rendez-vous",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final mode in AppointmentMode.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _MultiSelectOption(
              label: mode.label,
              description: mode.description,
              icon: mode.icon,
              isSelected: _selectedModes.contains(mode),
              onTap: () => setState(() {
                if (!_selectedModes.add(mode)) _selectedModes.remove(mode);
              }),
            ),
          ),
      ],
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.role,
    required this.step,
    required this.title,
  });

  final UserRole role;
  final int step;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(gradient: AppColors.gradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Icon(role.icon, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profil ${role.label}",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Text(
                "${step + 1}/3",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              for (var index = 0; index < 3; index++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 5,
                    decoration: BoxDecoration(
                      color: index <= step ? Colors.white : Colors.white30,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xl),
          ...children,
        ],
      ),
    );
  }
}

class _MultiSelectOption extends StatelessWidget {
  const _MultiSelectOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.description,
    this.icon,
  });

  final String label;
  final String? description;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.field),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.field),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.field),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
