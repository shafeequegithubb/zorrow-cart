import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentHistoryModel {
  final String id;
  final String userId;

  final String productId;
  final String productName;
  final String productImage;

  final int amount;

  final String paymentMethod;
  final String paymentStatus;
  final String paymentId;

  final Timestamp paidAt;

  PaymentHistoryModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentId,
    required this.paidAt,
  });

  factory PaymentHistoryModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return PaymentHistoryModel(
      id: id,
      userId: map["userId"] ?? "",

      productId: map["productId"] ?? "",
      productName: map["productName"] ?? "",
      productImage: map["productImage"] ?? "",

      amount: map["totalPrice"] ?? 0,

      paymentMethod: map["paymentMethod"] ?? "",
      paymentStatus: map["paymentStatus"] ?? "",
      paymentId: map["paymentId"] ?? "",

      paidAt: map["orderedAt"] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,

      "productId": productId,
      "productName": productName,
      "productImage": productImage,

      "totalPrice": amount,

      "paymentMethod": paymentMethod,
      "paymentStatus": paymentStatus,
      "paymentId": paymentId,

      "orderedAt": paidAt,
    };
  }
}
