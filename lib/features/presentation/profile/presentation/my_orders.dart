import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/core/widgets/Product_card.dart';
import 'package:zorrow_cart/features/presentation/checkout%20screen/provider/checkout_provider.dart';
import 'package:zorrow_cart/features/presentation/profile/presentation/order_details_screen.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CheckoutProvider>().getMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.mainWhite,
      appBar: AppBar(
        backgroundColor: ColorConstant.mainWhite,
        title: const Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<CheckoutProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myOrders.isEmpty) {
            return const Center(child: Text("No orders found"));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.myOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final orders = provider.myOrders[index];

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(),
                    ),
                  );
                  // Navigate to Order Details
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: orders.productImage,
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 90,
                              width: 90,
                              color: Colors.grey.shade200,
                              child: ShimmerLoading(),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 90,
                              width: 90,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orders.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),

                            SizedBox(height: 8),

                            Text(
                              orders.productId,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),

                            SizedBox(height: 5),

                            Text(
                              orders.orderedAt.toString(),
                              style: TextStyle(color: Colors.grey.shade600),
                            ),

                            SizedBox(height: 10),

                            Row(
                              children: [
                                Text(
                                  orders.productPrice.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),

                                // Spacer(),

                                // _statusChip(order["status"]!),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
