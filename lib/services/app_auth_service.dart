import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'backend_config.dart';
import 'firebase_bootstrap.dart';

class AuthIdentity {
  const AuthIdentity({
    required this.uid,
    required this.name,
    required this.email,
  });

  final String uid;
  final String name;
  final String email;
}

class AppAuthService {
  final GoogleSignIn _google = GoogleSignIn.instance;
  bool _googleInitialized = false;
  bool _firebaseConfigured = false;

  Future<void> _ensureFirebase() async {
    final initialized = await FirebaseBootstrap.ensureInitialized();
    if (!initialized) {
      throw StateError(FirebaseBootstrap.configurationErrorMessage());
    }
    if (_firebaseConfigured) return;
    if (BackendConfig.useEmulators) {
      FirebaseAuth.instance.useAuthEmulator(
        BackendConfig.emulatorHost,
        BackendConfig.authPort,
      );
    }
    _firebaseConfigured = true;
  }

  Future<void> _ensureGoogle() async {
    if (_googleInitialized) return;
    await _google.initialize();
    _googleInitialized = true;
  }

  Future<AuthIdentity?> signInWithGoogle() async {
    await _ensureGoogle();
    final account = await _google.authenticate();
    await _ensureFirebase();
    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
    final result = await FirebaseAuth.instance.signInWithCredential(credential);
    final user = result.user;
    if (user == null) return null;
    return AuthIdentity(
      uid: user.uid,
      name:
          user.displayName ??
          account.displayName ??
          user.email ??
          account.email,
      email: user.email ?? account.email,
    );
  }

  Future<AuthIdentity?> signInWithEmail(String email, String password) async {
    await _ensureFirebase();
    final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = result.user;
    if (user == null) return null;
    return AuthIdentity(
      uid: user.uid,
      name: user.displayName ?? user.email?.split('@').first ?? 'Explorer',
      email: user.email ?? email.trim(),
    );
  }

  Future<AuthIdentity?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    await _ensureFirebase();
    final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = result.user;
    if (user == null) return null;
    await user.updateDisplayName(name.trim());
    return AuthIdentity(
      uid: user.uid,
      name: name.trim(),
      email: user.email ?? email.trim(),
    );
  }

  Future<void> signOut() async {
    await _ensureGoogle();
    await _google.signOut();
    await _ensureFirebase();
    await FirebaseAuth.instance.signOut();
  }
}
