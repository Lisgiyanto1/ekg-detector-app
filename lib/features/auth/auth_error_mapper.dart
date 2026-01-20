import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorMapper {
  static String map(dynamic error) {
    /// ===============================
    /// CASE 1: FirebaseAuthException
    /// ===============================
    if (error is FirebaseAuthException) {
      return _fromCode(error.code);
    }

    /// ===============================
    /// CASE 2: String-based error (fallback)
    /// ===============================
    final message = error.toString();

    if (message.contains('invalid-credential')) {
      return 'Password Anda salah';
    }

    if (message.contains('wrong-password')) {
      return 'Password Anda salah';
    }

    if (message.contains('user-not-found')) {
      return 'Email belum terdaftar';
    }

    if (message.contains('invalid-email')) {
      return 'Format email tidak valid';
    }

    if (message.contains('network')) {
      return 'Tidak ada koneksi internet';
    }

    if (message.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan, coba lagi nanti';
    }

    return 'Terjadi kesalahan, silakan coba lagi';
  }

  /// ===============================
  /// FIREBASE ERROR CODE MAPPER
  /// ===============================
  static String _fromCode(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Password Anda salah';

      case 'user-not-found':
        return 'Email belum terdaftar';

      case 'invalid-email':
        return 'Format email tidak valid';

      case 'email-already-in-use':
        return 'Email sudah terdaftar';

      case 'weak-password':
        return 'Password terlalu lemah';

      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';

      case 'network-request-failed':
        return 'Tidak ada koneksi internet';

      default:
        return 'Autentikasi gagal';
    }
  }
}
