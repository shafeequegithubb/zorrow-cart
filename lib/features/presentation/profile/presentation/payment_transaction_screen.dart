import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/features/presentation/profile/provider/payment_history_provider.dart';

class PaymentTransactionScreen extends StatefulWidget {
  const PaymentTransactionScreen({super.key});

  @override
  State<PaymentTransactionScreen> createState() =>
      _PaymentTransactionScreenState();
}

class _PaymentTransactionScreenState extends State<PaymentTransactionScreen> {
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<PaymentHistoryProvider>().getPaymentHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.mainWhite,
      appBar: AppBar(
        backgroundColor: ColorConstant.mainWhite,
        title: const Text("Payment History"),
        centerTitle: true,
      ),
      body: Consumer<PaymentHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.paymentHistory.isEmpty) {
            return Center(child: Text("No Transactions"));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.paymentHistory.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final paymentHistory = provider.paymentHistory[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: paymentHistory.productImage,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CardLoading(
                          height: 70,
                          width: 70,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paymentHistory.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Payment ID",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),

                          Text(
                            paymentHistory.paymentId == ""
                                ? "*********"
                                : paymentHistory.paymentId,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  paymentHistory.paymentStatus,
                                  style: TextStyle(
                                    color:
                                        paymentHistory.paymentStatus == "Failed"
                                        ? Colors.red
                                        : paymentHistory.paymentStatus ==
                                              "Pending"
                                        ? Colors.orange
                                        : Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                paymentHistory.paymentMethod,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Text(
                                DateFormat(
                                  "dd MMM yyyy • hh:mm a",
                                ).format(paymentHistory.paidAt.toDate()),
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Spacer(),
                              Icon(
                                Icons.currency_rupee,
                                size: 18,
                                color: ColorConstant.mainblack,
                              ),

                              Text(
                                paymentHistory.amount.toString(),
                                style: TextStyle(
                                  color:
                                      paymentHistory.paymentStatus == "Failed"
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
