import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zorrow_cart/features/presentation/home/model/cart_model.dart';

class CartProvider extends ChangeNotifier {
  bool isLoading = false;

  List<CartModel> cart = [];
  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  int get Subtotal {
    return cart.fold(0, (sum, items) => sum + items.price * items.quantity);
  }

  Future<void> clearCartFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    clearCart(); // Local Provider clear
  }

  Future<void> increment(String cartId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(cartId)
        .update({"quantity": FieldValue.increment(1)});
    await getCart();
  }

  Future<void> decrement(String cartId, int quantity) async {
    if (quantity <= 1) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(cartId)
        .update({"quantity": FieldValue.increment(-1)});

    await getCart();
  }

  Future<void> getCart() async {
    isLoading = true;
    notifyListeners();
    try {
      cart.clear();
      final user = FirebaseAuth.instance.currentUser;

      final document = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("cart")
          .get();

      cart = document.docs
          .map((e) => CartModel.fromMap(e.data(), e.id))
          .toList();
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> remvoveCart(String cartId) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("cart")
          .doc(cartId)
          .delete();

      await getCart();
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
