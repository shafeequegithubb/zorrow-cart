
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zorrow_cart/features/presentation/profile/model/payment_hostory_model.dart';

class PaymentHistoryProvider extends ChangeNotifier {
  List<PaymentHistoryModel> paymentHistory = [];

  bool isPaymentLoading = false;

  Future<void> saveTransactions(PaymentHistoryModel paymenthistory) async {
    final user = FirebaseAuth.instance.currentUser!;
    final document = await FirebaseFirestore.instance
        .collection("transactions")
        .doc(user.uid)
        .collection("trans")
        .add(paymenthistory.toMap());
  }

  Future<void> getPaymentHistory() async {
    isPaymentLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection("transactions")
          .doc(user.uid)
          .collection("trans")
          .orderBy("orderedAt", descending: true)
          .get();

      paymentHistory = snapshot.docs
          .map((doc) => PaymentHistoryModel.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isPaymentLoading = false;
      notifyListeners();
    }
  }
  // Future<void> getPaymentHistory() async {
  //   isPaymentLoading = true;
  //   notifyListeners();

  //   try {
  //     log("heloooooo");
  //     final user = FirebaseAuth.instance.currentUser;

  //     if (user == null) return;

  //     final snapshot = await FirebaseFirestore.instance
  //         .collection("orders")
  //         .where("userId", isEqualTo: user.uid)
  //         .orderBy("orderedAt", descending: true)
  //         .get();

  //     paymentHistory = snapshot.docs
  //         .map((doc) => PaymentHistoryModel.fromMap(doc.data(), id: doc.id))
  //         .toList();
  //     log(paymentHistory.length.toString());
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   } finally {
  //     isPaymentLoading = false;
  //     notifyListeners();
  //   }
  // }
}
