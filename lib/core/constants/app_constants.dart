class AppConstants {
  // Roles
  static const String defaultUserRole = 'user';
  static const String adminRole = 'admin';

  // Animations
  static const Duration animationDuration = Duration(milliseconds: 1500);

  // Collections
  static const String usersCollection = 'users';

  // Google Sign In
  static const List<String> googleSignInScopes = ['email', 'profile'];

  // Error Messages
  static const String errorGoogleSignInCancelled = 'Google Sign In dibatalkan';
  static const String errorEmailAlreadyInUse = 'Email sudah digunakan';
  static const String errorWeakPassword = 'Password terlalu lemah';
  static const String errorInvalidEmail = 'Format email tidak valid';

  // Success Messages
  static const String successRegistration =
      'Registrasi berhasil! Cek email untuk verifikasi.';
  static const String successGoogleSignIn = 'Login dengan Google berhasil!';
}
