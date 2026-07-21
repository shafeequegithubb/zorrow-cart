import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final User? user = FirebaseAuth.instance.currentUser!;
}
