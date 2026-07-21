import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // Google account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      debugPrint("Google User: $googleUser");

      if (googleUser == null) {
        return null; // User cancelled
      }

      // Authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Sign-In
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
