class ProductModel {
  final String? id;
  final String title;
  final String titleLower;
  final String desc;
  final int price;
  final String imageUrl;

  ProductModel({
    this.id,
    required this.title,
    required this.titleLower,
    required this.desc,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'title_lower': titleLower,
      'description': desc,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory ProductModel.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    return ProductModel(
      id: id,
      title: map['title'] ?? '',
      titleLower: map['title_lower'] ?? '',
      desc: map['description'] ?? '',
      price: map['price'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? titleLower,
    String? desc,
    int? price,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleLower: titleLower ?? this.titleLower,
      desc: desc ?? this.desc,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}