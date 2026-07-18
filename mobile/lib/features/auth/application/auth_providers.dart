import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/auth_repository.dart";
import "../data/user_profile_repository.dart";

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepository(),
);

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Détermine où rediriger un utilisateur déjà authentifié : `/role-selection`
/// si son profil Firestore n'existe pas encore, sinon `/home`. Utilisé par le
/// splash et par l'écran de connexion.
Future<String> resolvePostAuthRoute(WidgetRef ref, String uid) async {
  final profile = await ref.read(userProfileRepositoryProvider).fetch(uid);
  return profile == null ? "/role-selection" : "/home";
}
