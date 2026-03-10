import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  const GoogleAuthResult({
    required this.id,
    required this.name,
    required this.email,
  });
  final String id;
  final String name;
  final String email;
}

class GoogleAuthService {
  final GoogleSignIn _google = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _google.initialize();
    _initialized = true;
  }

  Future<GoogleAuthResult?> signIn() async {
    await init();
    final account = await _google.authenticate();
    return GoogleAuthResult(
      id: account.id,
      name: account.displayName ?? account.email,
      email: account.email,
    );
  }
}
