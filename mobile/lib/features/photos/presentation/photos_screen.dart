import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../auth/application/auth_providers.dart";
import "../application/photo_providers.dart";
import "../domain/photo.dart";

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  bool _isUploading = false;

  Future<void> _addPhoto(String uid) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    if (!mounted) return;
    final captionController = TextEditingController();
    final caption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter une légende"),
        content: TextField(
          controller: captionController,
          decoration: const InputDecoration(
            labelText: "Légende (optionnel)",
            hintText: "Un bon souvenir avec...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(""),
            child: const Text("Ignorer"),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(captionController.text.trim()),
            child: const Text("Publier"),
          ),
        ],
      ),
    );
    if (caption == null) return;
    setState(() => _isUploading = true);
    try {
      final bytes = await picked.readAsBytes();
      await ref
          .read(photoRepositoryProvider)
          .upload(uid: uid, bytes: Uint8List.fromList(bytes), caption: caption);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _openPhoto(Photo photo, String uid) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.card),
              ),
              child: Image.network(photo.url, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      photo.caption.isNotEmpty
                          ? photo.caption
                          : "Sans légende",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await ref
                          .read(photoRepositoryProvider)
                          .delete(uid, photo.id);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.secondary,
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Photos")),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _isUploading ? null : () => _addPhoto(user.uid),
              icon: _isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_a_photo_rounded),
              label: const Text("Ajouter une photo"),
            ),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : StreamBuilder<List<Photo>>(
              stream: ref.read(photoRepositoryProvider).watchPhotos(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final photos = snapshot.data ?? [];
                if (photos.isEmpty) {
                  return const Center(
                    child: Text("Aucune photo publiée pour l'instant."),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return GestureDetector(
                      onTap: () => _openPhoto(photo, user.uid),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.field),
                        child: Image.network(photo.url, fit: BoxFit.cover),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
