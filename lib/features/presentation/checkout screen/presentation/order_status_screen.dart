import 'package:flutter/material.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/features/presentation/bottom_navigartion_bar/bottom_navigation.dart';
import 'package:zorrow_cart/features/presentation/profile/presentation/my_orders.dart';

enum OrderStatusType { success, failed, cancelled }

class OrderStatusScreen extends StatelessWidget {
  final OrderStatusType status;
  final String? orderId;

  const OrderStatusScreen({super.key, required this.status, this.orderId});

  @override
  Widget build(BuildContext context) {
    late IconData icon;
    late Color color;
    late String title;
    late String subtitle;

    switch (status) {
      case OrderStatusType.success:
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        title = "Order Placed";
        subtitle =
            "Your order has been placed successfully and is being processed.";
        break;

      case OrderStatusType.failed:
        icon = Icons.cancel_rounded;
        color = Colors.red;
        title = "Payment Failed";
        subtitle = "We couldn't process your payment. Please try again.";
        break;

      case OrderStatusType.cancelled:
        icon = Icons.info_rounded;
        color = Colors.orange;
        title = "Payment Cancelled";
        subtitle = "Your payment was cancelled. You can try again anytime.";
        break;
    }

    return Scaffold(
      backgroundColor: ColorConstant.mainWhite,
      appBar: AppBar(
        
        backgroundColor: ColorConstant.mainWhite,

        title: const Text(
          "Order Status",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 90),

            const SizedBox(height: 25),

            Text(
              title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            if (orderId != null) ...[
              const SizedBox(height: 20),
              Text("Order ID", style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 5),
              Text(
                orderId!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],

            const SizedBox(height: 40),

            if (status == OrderStatusType.success)
              OrderStatusButton(
                text: "View More ",
                icon: Icons.view_compact_alt_outlined,
                color: ColorConstant.mainWhite,
                ontap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyOrderScreen()),
                  );
                },
              ),

            const SizedBox(height: 15),

            OrderStatusButton(
              text: "Continue Shopping",
              color: color,
              ontap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => BottomNavigation()),
                  (route) => false,
                );
              },
              icon: Icons.shopping_bag_rounded,
            ),

            if (status != OrderStatusType.success) ...[
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0xFF1C1C1E),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Try Again",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OrderStatusButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback ontap;
  OrderStatusButton({
    super.key,
    required this.text,
    required this.color,
    required this.ontap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: ontap,
        child: Ink(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(colors: [Color(0xFFE8C56A), color]),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFD4A63A).withOpacity(.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: ColorConstant.mainblack),
              SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  color: ColorConstant.mainblack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
