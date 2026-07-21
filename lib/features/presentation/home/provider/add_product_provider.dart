import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zorrow_cart/features/presentation/home/model/product_model.dart';

class AddProductProvider extends ChangeNotifier {
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();
  List<ProductModel> products = [];
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? selectedImage;

  void clearImage() {
    selectedImage = null;
    notifyListeners();
  }

  Future<void> addProducts(ProductModel product) async {
    try {
      isLoading = true;
      notifyListeners();
      final snapshot = await FirebaseFirestore.instance
          .collection("products")
          .add(product.toMap());

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  

  Future<void> updateProduct(ProductModel product) async {
    try {
      isLoading = true;
      notifyListeners();

      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection("products").doc(id).delete();

  
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;
    selectedImage = File(image.path);
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    try {
      isLoading = true;
      notifyListeners();

      if (selectedImage == null) {
        return null;
      }

      final storageRef = _storage.ref().child(
        'products/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final UploadTask uploadTask = storageRef.putFile(selectedImage!);

      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
