import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jti_reports/core/utils/validators.dart';
import 'package:jti_reports/core/utils/error_handler.dart';

void main() {
  group('REGISTER - Unit Test per Field (Validators)', () {
    group('Nama Lengkap', () {
      test('Nama kosong -> "Nama lengkap harus diisi"', () {
        expect(
          Validators.validasiNamaLengkap(null),
          'Nama lengkap harus diisi',
        );
        expect(Validators.validasiNamaLengkap(''), 'Nama lengkap harus diisi');
      });

      test('Nama < 3 -> "Nama lengkap minimal 3 karakter"', () {
        expect(
          Validators.validasiNamaLengkap('ab'),
          'Nama lengkap minimal 3 karakter',
        );
      });

      test('Nama > 50 -> "Nama lengkap maksimal 50 karakter"', () {
        final longName = 'a' * 51;
        expect(
          Validators.validasiNamaLengkap(longName),
          'Nama lengkap maksimal 50 karakter',
        );
      });

      test('Nama valid (3..50) -> null', () {
        expect(Validators.validasiNamaLengkap('Ari'), isNull);
        expect(Validators.validasiNamaLengkap('a' * 50), isNull);
      });
    });

    group('Email', () {
      test('Email kosong -> "Email harus diisi"', () {
        expect(Validators.validasiEmail(null), 'Email harus diisi');
        expect(Validators.validasiEmail(''), 'Email harus diisi');
      });

      test('Email invalid -> "Format email tidak valid"', () {
        expect(Validators.validasiEmail('abc'), 'Format email tidak valid');
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

      test('Password valid -> null', () {
        expect(Validators.validasiPassword('Afriansyah12'), isNull);
      });
    });

    group('Konfirmasi Password', () {
      test('Konfirmasi kosong -> "Konfirmasi password harus diisi"', () {
        expect(
          Validators.validasiKonfirmasiPassword('123456', null),
          'Konfirmasi password harus diisi',
        );
        expect(
          Validators.validasiKonfirmasiPassword('123456', ''),
          'Konfirmasi password harus diisi',
        );
      });

      test('Password tidak sama -> "Password tidak sama"', () {
        expect(
          Validators.validasiKonfirmasiPassword('123456', '1234567'),
          'Password tidak sama',
        );
      });

      test('Password sama -> null', () {
        expect(
          Validators.validasiKonfirmasiPassword('123456', '123456'),
          isNull,
        );
      });
    });
  });

  group('REGISTER - Unit Test ErrorHandler', () {
    test('email-already-in-use -> "Email sudah digunakan"', () {
      final e = FirebaseAuthException(code: 'email-already-in-use');
      expect(ErrorHandler.getErrorMessage(e), 'Email sudah digunakan');
    });

    test('weak-password -> "Password terlalu lemah"', () {
      final e = FirebaseAuthException(code: 'weak-password');
      expect(ErrorHandler.getErrorMessage(e), 'Password terlalu lemah');
    });

    test('invalid-email -> "Format email tidak valid"', () {
      final e = FirebaseAuthException(code: 'invalid-email');
      expect(ErrorHandler.getErrorMessage(e), 'Format email tidak valid');
    });

    test('default FirebaseAuthException pakai message jika ada', () {
      final e = FirebaseAuthException(
        code: 'some-unknown-code',
        message: 'Custom firebase message',
      );
      expect(ErrorHandler.getErrorMessage(e), 'Custom firebase message');
    });

    test(
      'String yang mengandung firebase/auth -> "Terjadi kesalahan authentication"',
      () {
        expect(
          ErrorHandler.getErrorMessage('firebase error something'),
          'Terjadi kesalahan authentication',
        );
        expect(
          ErrorHandler.getErrorMessage('auth error something'),
          'Terjadi kesalahan authentication',
        );
      },
    );

    test('String biasa -> balikin string itu', () {
      expect(ErrorHandler.getErrorMessage('Oops'), 'Oops');
    });

    test('Unknown type -> fallback', () {
      expect(
        ErrorHandler.getErrorMessage(123),
        'Terjadi kesalahan yang tidak diketahui. Silakan coba lagi.',
      );
    });
  });
}
