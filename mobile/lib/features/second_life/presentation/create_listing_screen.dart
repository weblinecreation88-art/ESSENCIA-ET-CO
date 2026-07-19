import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../auth/application/auth_providers.dart";
import "../application/listing_providers.dart";
import "../domain/listing.dart";

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  ListingType _type = ListingType.don;
  Uint8List? _photoBytes;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoBytes = Uint8List.fromList(bytes));
  }

  Future<void> _submit(String uid) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final profile = await ref.read(userProfileRepositoryProvider).fetch(uid);
      final authorName = profile?.displayName?.isNotEmpty == true
          ? profile!.displayName!
          : (profile?.email ?? "Un utilisateur");
      final price = _type == ListingType.don
          ? null
          : double.tryParse(_priceController.text.trim());
      await ref.read(listingRepositoryProvider).create(
        authorUid: uid,
        authorName: authorName,
        type: _type,
        title: title,
        description: _descriptionController.text.trim(),
        price: price,
        photoBytes: _photoBytes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Annonce publiée !")),
      );
      context.pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Publier une annonce")),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final type in ListingType.values)
                      ChoiceChip(
                        label: Text(type.label),
                        selected: _type == type,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _type == type ? Colors.white : AppColors.text,
                        ),
                        onSelected: (_) => setState(() => _type = type),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Titre"),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                if (_type != ListingType.don) ...[
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Prix (€)",
                      suffixText: _type == ListingType.location ? "/ jour" : null,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.add_a_photo_rounded),
                  label: Text(
                    _photoBytes == null ? "Ajouter une photo" : "Photo ajoutée",
                  ),
                ),
                if (_photoBytes != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.field),
                    child: Image.memory(
                      _photoBytes!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : () => _submit(user.uid),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Publier"),
                  ),
                ),
              ],
            ),
    );
  }
}
