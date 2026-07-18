import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../auth/application/auth_providers.dart";
import "../auth/domain/user_profile.dart";

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Mon profil")),
      body: user == null
          ? const Center(child: Text("Aucun utilisateur connecté."))
          : FutureBuilder<UserProfile?>(
              future: ref.read(userProfileRepositoryProvider).fetch(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final profile = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          gradient: AppColors.gradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.email ?? "",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile != null
                            ? "Profil : ${profile.role.label}"
                            : "Profil non renseigné",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(authRepositoryProvider).signOut();
                            if (context.mounted) context.go("/welcome");
                          },
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text("Se déconnecter"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
