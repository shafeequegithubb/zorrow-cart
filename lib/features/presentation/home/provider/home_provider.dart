import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zorrow_cart/features/presentation/cart/presentation/cart_screen.dart';
import 'package:zorrow_cart/features/presentation/home/model/product_model.dart';
import 'package:zorrow_cart/features/presentation/home/presentation/home_screen.dart';
import 'package:zorrow_cart/features/presentation/profile/presentation/profle_screen.dart';

class HomeProvider with ChangeNotifier {
  bool isLoading = false;
  int currentIndex = 0;
  int currentBanner = 0;
  String searchQuery = "";
  List<ProductModel> products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;

  bool isLoadingMore = false;

  final int pageSize = 6;
  Future<void> refreshProducts() async {
    products.clear();

    lastDocument = null;

    hasMore = true;

    isLoading = false;

    notifyListeners();

    await getProducts();
  }

  List<ProductModel> get bannerProducts {
    final list = List<ProductModel>.from(products);
    list.shuffle();
    return list.take(3).toList();
  }

  void changeBanner(int index) {
    currentBanner = index;
    notifyListeners();
  }

  final List<Widget> pages = const [
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void selectIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future<void> getProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("products")
        .orderBy("title_lower")
        .limit(pageSize)
        .get();
    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
    }
    products = snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), id: doc.id))
        .toList();

    notifyListeners();
  }

  Future<void> fetchNextPage() async {
    if (!hasMore || isLoadingMore || lastDocument == null) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("products")
          .orderBy("title_lower")
          .startAfterDocument(lastDocument!)
          .limit(pageSize)
          .get();

      products.addAll(
        snapshot.docs.map(
          (doc) => ProductModel.fromMap(doc.data(), id: doc.id),
        ),
      );

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      hasMore = snapshot.docs.length == pageSize;
    } catch (e) {
      debugPrint("Pagination Error: $e");
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    searchQuery = query.trim().toLowerCase();

    isLoading = true;
    notifyListeners();

    try {
      Query firestoreQuery = _firestore
          .collection("products")
          .orderBy("title_lower");

      if (searchQuery.isNotEmpty) {
        firestoreQuery = firestoreQuery.startAt([searchQuery]).endAt([
          "$searchQuery\uf8ff",
        ]);
      }

      final snapshot = await firestoreQuery.get();

      products = snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
