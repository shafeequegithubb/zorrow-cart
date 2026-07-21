import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/core/constants/app_spacing.dart';

class CartSummarySection extends StatelessWidget {
  final int subtotal;
  final VoidCallback onProceedToCheckout;

  const CartSummarySection({
    super.key,
    required this.subtotal,
    required this.onProceedToCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.currency_rupee_sharp,
                      color: ColorConstant.primaryYellow,
                      size: 25,
                    ),

                    Text(
                      subtotal.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: ColorConstant.primaryYellow,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AppSpacing.height15,
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstant.mainblack.withOpacity(.2),
                      blurRadius: 05,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: ColorConstant.primaryYellow,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onProceedToCheckout,
                    child: Center(
                      child: Text(
                        "Proceed to Checkout",
                        style: TextStyle(
                          color: ColorConstant.mainWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
