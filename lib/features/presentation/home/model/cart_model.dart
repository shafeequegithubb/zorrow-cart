class CartModel {
  final String? id;
  final String productId;
  final String title;
  final String imageUrl;
  final int price;
  final int quantity;

  CartModel({
    this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "title": title,
      "imageUrl": imageUrl,
      "price": price,
      "quantity": quantity,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CartModel(
      id: documentId,
      productId: map["productId"] ?? "",
      title: map["title"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
      price: map["price"] ?? 0,
      quantity: map["quantity"] ?? 1,
    );
  }

  CartModel copyWith({
    String? id,
    String? productId,
    String? title,
    String? imageUrl,
    int? price,
    int? quantity,
  }) {
    return CartModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
