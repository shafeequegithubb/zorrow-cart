import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrdersModel {
  final String id;
  final String userId;

  // Product Details
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final int productPrice;
 
  final int totalPrice;

  // Payment
  final String paymentMethod;
  final String paymentStatus;
  final String paymentId;

  // Order
  final String orderStatus;
  final Timestamp orderedAt;

  MyOrdersModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.productPrice,

    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentId,
    required this.orderStatus,
    required this.orderedAt,
  });

  factory MyOrdersModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return MyOrdersModel(
      id: id,
      userId: map["userId"] ?? "",

      productId: map["productId"] ?? "",
      productName: map["productName"] ?? "",
      productImage: map["productImage"] ?? "",
      quantity: map["quantity"] ?? 1,
      productPrice: map["productPrice"] ?? 0,

      totalPrice: map["totalPrice"] ?? 0,

      paymentMethod: map["paymentMethod"] ?? "",
      paymentStatus: map["paymentStatus"] ?? "",
      paymentId: map["paymentId"] ?? "",

      orderStatus: map["orderStatus"] ?? "Pending",
      orderedAt: map["orderedAt"] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "productId": productId,
      "productName": productName,
      "productImage": productImage,
      "quantity": quantity,
      "productPrice": productPrice,

      "totalPrice": totalPrice,
      "paymentMethod": paymentMethod,
      "paymentStatus": paymentStatus,
      "paymentId": paymentId,
      "orderStatus": orderStatus,
      "orderedAt": orderedAt,
    };
  }
}
