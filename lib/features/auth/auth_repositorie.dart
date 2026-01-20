import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn.instance;

  /// ================================
  /// CURRENT USER
  /// ================================
  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// ================================
  /// REGISTER WITH EMAIL & PASSWORD
  /// ================================
  Future<User> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[AUTH] Register with email started');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('[AUTH] Register success');
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH][ERROR] Register failed: ${e.code}');
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// ================================
  /// LOGIN WITH EMAIL & PASSWORD
  /// ================================
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[AUTH] Login with email started');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('[AUTH] Login success');
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH][ERROR] Login failed: ${e.code}');
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// ================================
  /// GOOGLE SIGN IN
  /// ================================
  Future<User> signInWithGoogle() async {
    try {
      debugPrint('[AUTH] Google Sign-In started');

      await _google.initialize(
        serverClientId:
            '950306042372-lt8rnub5bclupmse9l8b1enstqhhj2le.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? account = await _google.authenticate();

      if (account == null) {
        throw Exception('Google Sign-In canceled');
      }

      final googleAuth = await account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      debugPrint('[AUTH] Google login success');
      return userCredential.user!;
    } catch (e) {
      debugPrint('[AUTH][ERROR] Google login failed');
      rethrow;
    }
  }

  /// ================================
  /// LOGOUT
  /// ================================
  Future<void> signOut() async {
    debugPrint('[AUTH] Sign out');

    await _auth.signOut();
    await _google.disconnect();
  }

  /// ================================
  /// ERROR MAPPER
  /// ================================
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'user-not-found':
        return 'User tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      default:
        return 'Terjadi kesalahan, coba lagi';
    }
  }
}
