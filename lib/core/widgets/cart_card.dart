import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/core/constants/app_spacing.dart';
import 'package:zorrow_cart/core/widgets/custom_snackbar.dart';
import 'package:zorrow_cart/features/presentation/cart/presentation/cart_screen.dart';
import 'package:zorrow_cart/features/presentation/cart/provider/cart_provider.dart';

class CartCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  final int price;
  final int quantity;
  const CartCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.quantity,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey.shade100,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      title,
                      style: TextStyle(
                        color: ColorConstant.mainblack,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    AppSpacing.height15,
                    Row(
                      children: [
                        IncrimentButton(
                          icon: Icons.remove,
                          onTap: () {
                            provider.decrement(id, quantity);

                            ///decrimnt
                          },
                        ),
                        SizedBox(width: 10),
                        Text(quantity.toString()),
                        SizedBox(width: 10),

                        IncrimentButton(
                          icon: Icons.add,
                          onTap: () {
                            provider.increment(id);

                            ///incriment
                          },
                        ),
                      ],
                    ),
                    AppSpacing.height10,

                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          size: 16,
                          color: ColorConstant.primaryYellow,
                        ),

                        Text(
                          "${price * quantity}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,

                            fontSize: 16,
                            color: ColorConstant.primaryYellow,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),

              InkWell(
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  try {
                    await context.read<CartProvider>().remvoveCart(id);

                    messenger.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Item removed from cart",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        elevation: 12,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (_) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(
                              Icons.error_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Failed to remove product",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        elevation: 12,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: ColorConstant.mainWhite,
                    child: Icon(
                      Icons.close_rounded,
                      color: ColorConstant.mainblack,
                      size: 24,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }
}
