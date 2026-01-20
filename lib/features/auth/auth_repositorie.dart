import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH][ERROR] Register: ${e.code}');
      throw e; // 🔥 PENTING
    }
  }

  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH][ERROR] Login: ${e.code}');
      throw e; // 🔥 PENTING
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      await _google.initialize(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );

      final account = await _google.authenticate();
      _validateGoogleAccount(account);

      final googleAuth = await account!.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return result.user!;
    } catch (e) {
      debugPrint('[AUTH][ERROR] Google Sign-In: $e');
      rethrow;
    }
  }

  void _validateGoogleAccount(GoogleSignInAccount? account) {
    if (account == null) {
      throw FirebaseAuthException(
        code: 'google-cancelled',
        message: 'Login Google dibatalkan oleh pengguna',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _google.disconnect();
  }
}
