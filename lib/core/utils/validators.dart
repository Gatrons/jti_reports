class Validators {
  static String? validasiNamaLengkap(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap harus diisi';
    }
    if (value.length < 3) {
      return 'Nama lengkap minimal 3 karakter';
    }
    if (value.length > 50) {
      return 'Nama lengkap maksimal 50 karakter';
    }
    return null;
  }

  static String? validasiEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validasiPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (value.length > 20) {
      return 'Password maksimal 20 karakter';
    }
    return null;
  }

  static String? validasiKonfirmasiPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    if (password != confirmPassword) {
      return 'Password tidak sama';
    }
    return null;
  }
}
