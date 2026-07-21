import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/core/constants/app_spacing.dart';
import 'package:zorrow_cart/core/widgets/review_card.dart';
import 'package:zorrow_cart/features/presentation/cart/presentation/cart_screen.dart';
import 'package:zorrow_cart/features/presentation/checkout%20screen/presentation/checkout_screen.dart';
import 'package:zorrow_cart/features/presentation/home/model/cart_model.dart';
import 'package:zorrow_cart/features/presentation/home/model/product_model.dart';
import 'package:zorrow_cart/features/presentation/home/model/review_model.dart';
import 'package:zorrow_cart/features/presentation/home/presentation/add_product_screen.dart';
import 'package:zorrow_cart/features/presentation/home/provider/product_details_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel products;
  ProductDetailsScreen({super.key, required this.products});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ProductDetailsProvider>().checkCartItems(
        widget.products.id.toString(),
      );
      context.read<ProductDetailsProvider>().getReviews(
        productId: widget.products.id!,
      );
      context.read<ProductDetailsProvider>().resetQuantity();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController reviewController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.mainWhite,
        actions: [
          InkWell(
            onTap: () {
              log(widget.products.id.toString());
              log(widget.products.imageUrl.toString());

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(
                    id: widget.products.id,
                    product: ProductModel(
                      title: widget.products.title,
                      titleLower: widget.products.title,
                      desc: widget.products.desc,
                      price: widget.products.price,
                      imageUrl: widget.products.imageUrl,
                    ),
                    isEdit: true,
                  ),
                ),
              );
            },
            child: Icon(Icons.edit),
          ),
          AppSpacing.width10,
          // Icon(Icons.favorite_border),
          AppSpacing.width20,
        ],
      ),
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: Consumer<ProductDetailsProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 350,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: ColorConstant.mainWhite,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(25),
                              child: CachedNetworkImage(
                                imageUrl: widget.products.imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.products.title,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 12),

                                Row(
                                  children: const [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "4.9",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "(254 Reviews)",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.currency_rupee,
                                      color: ColorConstant.primaryYellow,
                                      size: 30,
                                    ),
                                    Text(
                                      widget.products.price.toString(),

                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: ColorConstant.primaryYellow,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                const Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  widget.products.desc,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    height: 1.6,
                                    fontSize: 15,
                                  ),
                                ),
                                AppSpacing.height20,
                                if (provider.reviews.isNotEmpty)
                                  ...List.generate(provider.reviews.length, (
                                    index,
                                  ) {
                                    final reviews = provider.reviews[index];
                                    return ReviewCard(
                                      userImage: reviews.userImage,
                                      reviews: reviews.review,
                                      username: reviews.userName,
                                      date: reviews.createdAt.toDate(),
                                    );
                                  }),

                                AppSpacing.height10,
                                ReviewTextField(
                                  controller: reviewController,
                                  onSubmit: () async {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (reviewController.text.isNotEmpty) {
                                      provider.saveReview(
                                        productId: widget.products.id ?? "",
                                        review: ReviewModel(
                                          userImage: user!.photoURL ?? "",
                                          id: "",
                                          userId: user.uid,
                                          userName: user.displayName!,
                                          review: reviewController.text,
                                          rating: 4,
                                          createdAt: Timestamp.now(),
                                        ),
                                      );
                                      await provider.getReviews(
                                        productId: widget.products.id ?? "",
                                      );
                                      reviewController.clear();
                                    }
                                  },
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(blurRadius: 15, color: Colors.black12),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () async {
                              if (provider.isCheckCart) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CartScreen(),
                                  ),
                                );
                                return; // 👈 ഇതാണ് missing
                              }

                              try {
                                await context
                                    .read<ProductDetailsProvider>()
                                    .addCart(
                                      CartModel(
                                        productId: widget.products.id
                                            .toString(),
                                        title: widget.products.title,
                                        imageUrl: widget.products.imageUrl,
                                        price: widget.products.price,
                                        quantity: provider.quantity,
                                      ),
                                    );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "Product added to cart",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Color(
                                      0xFF16A34A,
                                    ), // Premium Green
                                    behavior: SnackBarBehavior.floating,
                                    elevation: 12,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                await context
                                    .read<ProductDetailsProvider>()
                                    .checkCartItems(
                                      widget.products.id.toString(),
                                    );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text("Failed to add product"),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              provider.isCheckCart
                                  ? "Go to Cart"
                                  : "Add to Cart",
                              style: TextStyle(color: ColorConstant.mainblack),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SizedBox(
                            height: 58,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorConstant.primaryYellow,
                                foregroundColor: Colors.white,
                                elevation: 6,
                                shadowColor: ColorConstant.primaryYellow
                                    .withOpacity(0.35),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutScreen(
                                      subtotal: widget.products.price,
                                      title: widget.products.title,
                                      product: widget.products,
                                    ),
                                  ),
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.flash_on_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Buy Now",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ReviewTextField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const ReviewTextField({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailsProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Write a Review",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: "Share your experience with this product...",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterText: "",
            ),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading ? null : onSubmit,
            icon: const Icon(Icons.send_rounded),
            label: provider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("Submit Review"),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstant.primaryYellow,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
