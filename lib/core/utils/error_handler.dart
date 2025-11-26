import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email sudah digunakan';
        case 'weak-password':
          return 'Password terlalu lemah';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'operation-not-allowed':
          return 'Operasi tidak diizinkan';
        case 'user-disabled':
          return 'Akun dinonaktifkan';
        case 'user-not-found':
          return 'Akun tidak ditemukan';
        case 'wrong-password':
          return 'Password salah';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan, coba lagi nanti';
        case 'network-request-failed':
          return 'Koneksi internet bermasalah';
        case 'requires-recent-login':
          return 'Sesi login telah berakhir, silakan login ulang';
        default:
          return error.message ?? 'Terjadi kesalahan authentication';
      }
    }

    // Handle Google Sign In cancellation
    if (error.toString().contains('sign_in_canceled') ||
        error.toString().contains('canceled')) {
      return 'Login dengan Google dibatalkan';
    }

    // Handle general exceptions
    if (error is String) {
      if (error.contains('firebase') || error.contains('auth')) {
        return 'Terjadi kesalahan authentication';
      }
      return error;
    }

    return 'Terjadi kesalahan yang tidak diketahui. Silakan coba lagi.';
  }

  static String getFriendlyErrorMessage(dynamic error) {
    final message = getErrorMessage(error);

    // Tambahkan pesan yang lebih user-friendly
    if (message.contains('network') || message.contains('internet')) {
      return 'Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.';
    }

    if (message.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan login. Tunggu beberapa saat dan coba lagi.';
    }

    return message;
  }
}
