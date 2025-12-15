import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jti_reports/core/utils/validators.dart';
import 'package:jti_reports/core/utils/error_handler.dart';

void main() {
  group('LOGIN - Unit Test per Field (Validators)', () {
    group('Email', () {
      test('Email kosong -> "Email harus diisi"', () {
        expect(Validators.validasiEmail(null), 'Email harus diisi');
        expect(Validators.validasiEmail(''), 'Email harus diisi');
      });

      test('Email format tidak valid -> "Format email tidak valid"', () {
        expect(Validators.validasiEmail('abc'), 'Format email tidak valid');
        expect(Validators.validasiEmail('abc@'), 'Format email tidak valid');
        expect(
          Validators.validasiEmail('abc@gmail'),
          'Format email tidak valid',
        );
      });

      test('Email valid -> null', () {
        expect(Validators.validasiEmail('afriansyy@gmail.com'), isNull);
      });
    });

    group('Password', () {
      test('Password kosong -> "Password harus diisi"', () {
        expect(Validators.validasiPassword(null), 'Password harus diisi');
        expect(Validators.validasiPassword(''), 'Password harus diisi');
      });

      test('Password < 6 -> "Password minimal 6 karakter"', () {
        expect(
          Validators.validasiPassword('12345'),
          'Password minimal 6 karakter',
        );
      });

      test('Password > 20 -> "Password maksimal 20 karakter"', () {
        expect(
          Validators.validasiPassword('123456789012345678901'),
          'Password maksimal 20 karakter',
        );
      });

      test('Password valid (6..20) -> null', () {
        expect(Validators.validasiPassword('Afriansyah12'), isNull);
        expect(Validators.validasiPassword('123456'), isNull);
        expect(
          Validators.validasiPassword('12345678901234567890'),
          isNull,
        ); // 20 char
      });
    });
  });

  group('LOGIN - Unit Test ErrorHandler', () {
    test('FirebaseAuthException wrong-password -> "Password salah"', () {
      final e = FirebaseAuthException(code: 'wrong-password');
      expect(ErrorHandler.getErrorMessage(e), 'Password salah');
    });

    test('FirebaseAuthException user-not-found -> "Akun tidak ditemukan"', () {
      final e = FirebaseAuthException(code: 'user-not-found');
      expect(ErrorHandler.getErrorMessage(e), 'Akun tidak ditemukan');
    });

    test('Google sign in canceled -> "Login dengan Google dibatalkan"', () {
      expect(
        ErrorHandler.getErrorMessage('sign_in_canceled'),
        'Login dengan Google dibatalkan',
      );
      expect(
        ErrorHandler.getErrorMessage('canceled'),
        'Login dengan Google dibatalkan',
      );
    });

    test('Network error -> friendly message koneksi', () {
      final e = FirebaseAuthException(code: 'network-request-failed');
      expect(ErrorHandler.getErrorMessage(e), 'Koneksi internet bermasalah');
      expect(
        ErrorHandler.getFriendlyErrorMessage(e),
        'Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.',
      );
    });
  });
}
