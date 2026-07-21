import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zorrow_cart/features/presentation/checkout%20screen/model/address_model.dart';
import 'package:zorrow_cart/features/presentation/profile/model/my_orders_model.dart';

class CheckoutProvider extends ChangeNotifier {
  int selectedIndex = 0;
  bool isLoading = false;
  AddressModel? address;
  int deliveryFee = 45;
  List<MyOrdersModel> myOrders = [];
  Future<void> getMyOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      log("hoellloooooo");
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where("userId", isEqualTo: user.uid)
          .orderBy("orderedAt", descending: true)
          .get();

      myOrders = snapshot.docs
          .map((doc) => MyOrdersModel.fromMap(doc.data(), id: doc.id))
          .toList();
      log(myOrders.length.toString());
    } catch (e) {
      debugPrint(e.toString());
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> placeOrder({required MyOrdersModel myOrder}) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      await FirebaseFirestore.instance.collection("orders").add({
        "userId": user.uid,

        "productId": myOrder.productId,
        "productName": myOrder.productName,
        "productImage": myOrder.productImage,

        "quantity": myOrder.quantity,
        "productPrice": myOrder.productPrice,

        "totalPrice": myOrder.totalPrice,

        "paymentMethod": myOrder.paymentMethod,
        "paymentStatus": myOrder.paymentStatus,
        "paymentId": myOrder.paymentId,

        "orderStatus": myOrder.orderStatus,

        "orderedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectedPaymentMethod(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> addAddress(AddressModel address) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("address")
          .doc("primary") // Fixed document id
          .set(address.toMap());
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAddress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("address")
          .doc("primary")
          .get();

      if (doc.exists) {
        address = AddressModel.fromMap(doc.data()!, doc.id);
      } else {
        address = null;
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
