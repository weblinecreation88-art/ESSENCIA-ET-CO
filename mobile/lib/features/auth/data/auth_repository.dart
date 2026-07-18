import "package:firebase_auth/firebase_auth.dart";

/// Encapsule Firebase Auth. Ne contient aucune logique d'UI ni de navigation.
class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<User> signUp({required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();

  /// Traduit les codes d'erreur Firebase Auth les plus courants en français.
  static String messageFor(FirebaseAuthException error) {
    return switch (error.code) {
      "invalid-email" => "L'adresse e-mail n'est pas valide.",
      "user-disabled" => "Ce compte a été désactivé.",
      "user-not-found" => "Aucun compte ne correspond à cette adresse e-mail.",
      "wrong-password" || "invalid-credential" =>
        "Mot de passe incorrect.",
      "email-already-in-use" => "Un compte existe déjà avec cette adresse e-mail.",
      "weak-password" => "Le mot de passe doit contenir au moins 6 caractères.",
      "operation-not-allowed" =>
        "La connexion par e-mail n'est pas encore activée pour ce projet.",
      "network-request-failed" => "Problème de connexion réseau.",
      _ => "Une erreur est survenue. Veuillez réessayer.",
    };
  }
}
