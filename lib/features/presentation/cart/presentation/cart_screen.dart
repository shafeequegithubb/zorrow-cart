import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/core/widgets/cart_card.dart';
import 'package:zorrow_cart/core/widgets/cart_summary.dart';
import 'package:zorrow_cart/features/presentation/cart/provider/cart_provider.dart';
import 'package:zorrow_cart/features/presentation/checkout%20screen/presentation/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: ColorConstant.mainWhite,
      body: cartProvider.cart.isEmpty
          ? cartProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : Center(
                    child: Text(
                      "Your cart is Empty, Shop now",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Consumer<CartProvider>(
                builder: (context, provider, child) {
                  // Calculate subtotal from cart items

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: provider.cart.length,
                          itemBuilder: (context, index) {
                            final cart = provider.cart[index];

                            return CartCard(
                              id: cart.id.toString(),
                              imageUrl: cart.imageUrl,
                              title: cart.title,
                              price: cart.price,
                              quantity: cart.quantity,
                            );
                          },
                        ),
                      ),
                      CartSummarySection(
                        subtotal: provider.Subtotal,
                        onProceedToCheckout: () {
                          
                            Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CheckoutScreen(
        title: "Checkout",
        subtotal: context.read<CartProvider>().Subtotal,
        cartItems: context.read<CartProvider>().cart,
        isCartCheckout: true,
      ),
    ),
  );
                          // Navigate to checkout screen
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

class IncrimentButton extends StatelessWidget {
  final IconData icon;
  final void Function()? onTap;
  const IncrimentButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 27,
          height: 27,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 2,
                offset: const Offset(-1, -1),
              ),
            ],
          ),
          child: Center(child: Icon(icon, size: 22, color: Colors.black87)),
        ),
      ),
    );
  }
}
