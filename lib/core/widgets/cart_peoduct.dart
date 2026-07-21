import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zorrow_cart/features/presentation/home/model/cart_model.dart';

class CartProductCard extends StatelessWidget {
  final CartModel cart;

  const CartProductCard({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: cart.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (context, url) => const SizedBox(
            width: 60,
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) =>
              const Icon(Icons.broken_image_outlined, size: 40),
        ),
      ),
      title: Text(cart.title),
      subtitle: Text("Qty: ${cart.quantity}"),
      trailing: Text("₹${cart.price}"),
    );
  }
}
