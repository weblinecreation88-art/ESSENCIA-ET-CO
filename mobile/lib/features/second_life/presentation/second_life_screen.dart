import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_theme.dart";
import "../../auth/application/auth_providers.dart";
import "../../chat/application/chat_providers.dart";
import "../application/listing_providers.dart";
import "../domain/listing.dart";

Color _typeColor(ListingType type) => switch (type) {
  ListingType.don => AppColors.success,
  ListingType.vente => AppColors.primary,
  ListingType.location => AppColors.roleProvider,
};

class SecondLifeScreen extends ConsumerWidget {
  const SecondLifeScreen({super.key});

  Future<void> _openListing(
    BuildContext context,
    WidgetRef ref,
    Listing listing,
  ) async {
    final me = ref.read(authRepositoryProvider).currentUser;
    final isMine = me != null && me.uid == listing.authorUid;

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (listing.photoUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.field),
                  child: Image.network(
                    listing.photoUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _typeColor(listing.type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.field),
                ),
                child: Text(
                  listing.type.label,
                  style: TextStyle(
                    color: _typeColor(listing.type),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(listing.title, style: Theme.of(context).textTheme.titleMedium),
              if (listing.price != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "${listing.price!.toStringAsFixed(0)} €",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                listing.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                "Publié par ${listing.authorName}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: isMine
                    ? OutlinedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(listingRepositoryProvider)
                              .delete(listing.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text("Supprimer mon annonce"),
                      )
                    : FilledButton.icon(
                        onPressed: () async {
                          if (me == null) return;
                          final myProfile = await ref
                              .read(userProfileRepositoryProvider)
                              .fetch(me.uid);
                          final author = await ref
                              .read(userProfileRepositoryProvider)
                              .fetch(listing.authorUid);
                          if (myProfile == null || author == null) return;
                          final chatId = await ref
                              .read(chatRepositoryProvider)
                              .getOrCreateChat(myProfile, author);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          context.push("/chat/$chatId");
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text("Contacter"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seconde vie")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push("/second-life/new"),
        icon: const Icon(Icons.add_rounded),
        label: const Text("Publier une annonce"),
      ),
      body: StreamBuilder<List<Listing>>(
        stream: ref.read(listingRepositoryProvider).watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final listings = snapshot.data ?? [];
          if (listings.isEmpty) {
            return const Center(
              child: Text("Aucune annonce pour l'instant."),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xxxl * 2,
            ),
            itemCount: listings.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final listing = listings[index];
              return InkWell(
                borderRadius: BorderRadius.circular(AppRadii.field),
                onTap: () => _openListing(context, ref, listing),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.field),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      if (listing.photoUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.field),
                          child: Image.network(
                            listing.photoUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _typeColor(
                              listing.type,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadii.field),
                          ),
                          child: Icon(
                            Icons.inventory_2_rounded,
                            color: _typeColor(listing.type),
                          ),
                        ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              listing.price != null
                                  ? "${listing.type.label} · ${listing.price!.toStringAsFixed(0)} €"
                                  : listing.type.label,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
