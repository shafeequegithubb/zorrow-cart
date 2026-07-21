import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/features/auth/presentation/logIn_screen.dart';
import 'package:zorrow_cart/features/auth/provider/auth_provider.dart';
import 'package:zorrow_cart/features/presentation/cart/provider/cart_provider.dart';
import 'package:zorrow_cart/features/presentation/home/provider/home_provider.dart';
import 'package:zorrow_cart/features/presentation/home/provider/product_details_provider.dart';
import 'package:zorrow_cart/features/presentation/profile/presentation/my_orders.dart';
import 'package:zorrow_cart/features/presentation/profile/presentation/payment_transaction_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FB),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      user!.photoURL ??
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNhWdv8dBDOh7IDV2kcbiN2V310-vH-Gx83ZUrnfhQhA&s=10",
                    ),
                    radius: 45,
                    backgroundColor: ColorConstant.primaryYellow.withOpacity(
                      .15,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    user!.displayName ?? "Guest User",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    user!.email ?? "",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _menuTile(
              icon: Icons.shopping_bag_outlined,
              title: "My Orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyOrderScreen()),
                );
                // Navigate Orders
              },
            ),

            const SizedBox(height: 15),

            _menuTile(
              icon: Icons.receipt_long_outlined,
              title: "Transaction History",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentTransactionScreen(),
                  ),
                );
                // Navigate Transactions
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 156, 2, 2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () async {
                  try {
                    await context.read<AuthenticationProvider>().signOut();

                    context.read<HomeProvider>().currentIndex = 0;
                    context.read<CartProvider>().clearCart();

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text("Log out failed"),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: ColorConstant.primaryYellow.withOpacity(.15),
                child: Icon(icon, color: ColorConstant.primaryYellow),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
