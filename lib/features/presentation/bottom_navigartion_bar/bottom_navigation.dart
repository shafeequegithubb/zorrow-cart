import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/features/presentation/cart/provider/cart_provider.dart';
import 'package:zorrow_cart/features/presentation/home/provider/home_provider.dart';
import 'package:zorrow_cart/features/presentation/home/provider/product_details_provider.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) async {
          homeProvider.selectIndex(value);
          if (value == 1) {
            await context.read<CartProvider>().getCart();
          }
        },
        backgroundColor: ColorConstant.mainWhite,
        unselectedItemColor: Colors.grey,
        currentIndex: homeProvider.currentIndex,
        iconSize: 20,
        selectedItemColor: ColorConstant.mainblack,
        selectedFontSize: 18,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: ColorConstant.mainblack),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.cartShopping),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      backgroundColor: ColorConstant.mainWhite,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ColorConstant.mainWhite,

        title: const Text(
          "Zorrow Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: IndexedStack(
        index: homeProvider.currentIndex,
        children: homeProvider.pages,
      ),
    );
  }
}
