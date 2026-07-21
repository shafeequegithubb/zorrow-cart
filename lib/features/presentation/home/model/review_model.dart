import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String review;
  final int rating;
  final Timestamp createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.review,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "userName": userName,
      "userImage": userImage,
      "review": review,
      "rating": rating,
      "createdAt": createdAt,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      userId: map["userId"] ?? "",
      userName: map["userName"] ?? "",
      userImage: map["userImage"] ?? "",
      review: map["review"] ?? "",
      rating: map["rating"] ?? 0,
      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }
}
