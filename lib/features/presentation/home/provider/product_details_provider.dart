import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zorrow_cart/features/presentation/home/model/cart_model.dart';
import 'package:zorrow_cart/features/presentation/home/model/review_model.dart';

class ProductDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isCheckCart = false;
  int quantity = 1;
  List<ReviewModel> reviews = [];


  Future<void> getReviews({
  required String productId,
}) async {
  isLoading = true;
  notifyListeners();

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection("products")
        .doc(productId)
        .collection("reviews")
        .orderBy("createdAt", descending: true)
        .get();

    reviews = snapshot.docs
        .map(
          (doc) => ReviewModel.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
  Future<void> saveReview({
    required String productId,
    required ReviewModel review,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .collection("reviews")
          .add(review.toMap());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkCartItems(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    final query = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart")
        .where("productId", isEqualTo: productId)
        .get();

    isCheckCart = query.docs.isNotEmpty;
    notifyListeners();
  }

  void increment() {
    quantity++;
    notifyListeners();
  }

  void decriment() {
    if (quantity > 1) {
      quantity--;
      notifyListeners();
    } else {
      return null;
    }
  }

  void resetQuantity() {
    quantity = 1;
    notifyListeners();
  }

  Future<void> addCart(CartModel cart) async {
    try {
      isLoading = true;
      notifyListeners();
      final user = FirebaseAuth.instance.currentUser;

      final cartRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("cart");

      final query = await cartRef
          .where("productId", isEqualTo: cart.productId)
          .get();

      if (query.docs.isEmpty) {
        await cartRef.add(cart.toMap());
      } else {
        final doc = query.docs.first;

        await doc.reference.update({
          "quantity": FieldValue.increment(cart.quantity),
        });
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
