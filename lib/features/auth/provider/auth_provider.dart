import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zorrow_cart/core/services/google_services.dart';
import 'package:zorrow_cart/features/presentation/home/provider/home_provider.dart';

class AuthenticationProvider extends ChangeNotifier {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  User? _user;
  bool isLoading = false;

  User? get user => _user;

  Future<void> saveUserToFirestore(User user) async {
    final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);

    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        "uid": user.uid,
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "photoUrl": user.photoURL ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      _user = await _googleAuthService.signInWithGoogle();
      if (_user != null) {
        await saveUserToFirestore(_user!);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();

    try {
      await _googleAuthService.signOut();
      _user = null;
    } catch (e) {
      rethrow; // Optional: UI-ൽ error handle ചെയ്യാൻ
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
