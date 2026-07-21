import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/core/constants/app_spacing.dart';
import 'package:zorrow_cart/core/services/razorpay_services.dart';
import 'package:zorrow_cart/core/widgets/address_form.dart';
import 'package:zorrow_cart/core/widgets/cart_peoduct.dart';
import 'package:zorrow_cart/core/widgets/payment_method.dart';
import 'package:zorrow_cart/features/presentation/cart/provider/cart_provider.dart';
import 'package:zorrow_cart/features/presentation/checkout%20screen/model/address_model.dart';
import 'package:zorrow_cart/features/presentation/checkout%20screen/presentation/order_status_screen.dart';
import 'package:zorrow_cart/features/presentation/checkout%20screen/provider/checkout_provider.dart';
import 'package:zorrow_cart/features/presentation/home/model/cart_model.dart';
import 'package:zorrow_cart/features/presentation/home/model/product_model.dart';
import 'package:zorrow_cart/features/presentation/profile/model/my_orders_model.dart';
import 'package:zorrow_cart/features/presentation/profile/model/payment_hostory_model.dart';
import 'package:zorrow_cart/features/presentation/profile/provider/payment_history_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final String title;

  final ProductModel? product;

  final List<CartModel>? cartItems;

  final int subtotal;

  final bool isCartCheckout;

  const CheckoutScreen({
    super.key,
    required this.title,
    required this.subtotal,
    this.product,
    this.cartItems,
    this.isCartCheckout = false,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late RazorpayService razorpayService;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CheckoutProvider>().getAddress();

      razorpayService = RazorpayService();

      razorpayService.init(
        onSuccess: handlePaymentSuccess,
        onFailure: handlePaymentFailure,
        onExternalWallet: handleExternalWallet,
      );
    });
  }

  @override
  void dispose() {
    razorpayService.dispose();
    super.dispose();
  }

  Future<void> handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    final checkoutProvider = context.read<CheckoutProvider>();
    final address = checkoutProvider.address;
    final finalPrice = widget.subtotal + checkoutProvider.deliveryFee;

    if (address == null) return;
    if (widget.isCartCheckout) {
      for (final item in widget.cartItems!) {
        await checkoutProvider.placeOrder(
          myOrder: MyOrdersModel(
            id: "",
            userId: user!.uid,
            productId: item.productId,
            productName: item.title,
            productImage: item.imageUrl,
            quantity: item.quantity,
            productPrice: item.price,
            totalPrice: item.price * item.quantity,
            paymentMethod: "Online",
            paymentStatus: "Success",
            paymentId: response.paymentId ?? "",
            orderStatus: "Pending",
            orderedAt: Timestamp.now(),
          ),
        );
      }

      await context.read<PaymentHistoryProvider>().saveTransactions(
        PaymentHistoryModel(
          id: "",
          userId: user!.uid,
          productId: "",
          productName: "Cart Checkout",
          productImage: "",
          amount: finalPrice,
          paymentMethod: "Online",
          paymentStatus: "Success",
          paymentId: response.paymentId ?? "",
          paidAt: Timestamp.now(),
        ),
      );

      await context.read<CartProvider>().clearCartFromFirestore();
    } else {
      await checkoutProvider.placeOrder(
        myOrder: MyOrdersModel(
          id: "",
          userId: user!.uid,
          productId: widget.product!.id ?? "",
          productName: widget.product!.title,
          productImage: widget.product!.imageUrl,
          quantity: 1,
          productPrice: widget.product!.price,
          totalPrice: finalPrice,
          paymentMethod: "Online",
          paymentStatus: "Success",
          paymentId: response.paymentId ?? "",
          orderStatus: "Pending",
          orderedAt: Timestamp.now(),
        ),
      );

      await context.read<PaymentHistoryProvider>().saveTransactions(
        PaymentHistoryModel(
          id: "",
          userId: user.uid,
          productId: widget.product!.id ?? "",
          productName: widget.product!.title,
          productImage: widget.product!.imageUrl,
          amount: finalPrice,
          paymentMethod: "Online",
          paymentStatus: "Success",
          paymentId: response.paymentId ?? "",
          paidAt: Timestamp.now(),
        ),
      );
      // Existing Buy Now Logic
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const OrderStatusScreen(status: OrderStatusType.success),
      ),
    );
  }

  void handlePaymentFailure(PaymentFailureResponse response) {
    final user = FirebaseAuth.instance.currentUser;
    final checkoutProvider = context.read<CheckoutProvider>();

    final finalPrice = widget.subtotal + checkoutProvider.deliveryFee;
    context.read<PaymentHistoryProvider>().saveTransactions(
      PaymentHistoryModel(
        id: "",
        userId: user!.uid,
        productId: widget.product!.id ?? "",
        productName: widget.product!.title,
        productImage: widget.product!.imageUrl,
        amount: finalPrice,
        paymentMethod: "Online",
        paymentStatus: "Failed",
        paymentId: "",
        paidAt: Timestamp.now(),
      ),
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OrderStatusScreen(status: OrderStatusType.failed),
      ),
    );
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("WALLET : ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    final _formkey = GlobalKey<FormState>();

    final checkoutProvider = context.watch<CheckoutProvider>();
    final totalPrice = widget.subtotal + checkoutProvider.deliveryFee;
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController cityController = TextEditingController();
    TextEditingController stateController = TextEditingController();
    TextEditingController pincodeController = TextEditingController();
    void showAddressBottomSheet({
      required BuildContext context,
      AddressModel? address,
    }) {
      // If edit mode, prefill controllers
      if (address != null) {
        nameController.text = address.fullName;
        phoneController.text = address.phone;
        addressController.text = address.address;
        cityController.text = address.city;
        stateController.text = address.state;
        pincodeController.text = address.pincode;
      } else {
        // Add mode
        nameController.clear();
        phoneController.clear();
        addressController.clear();
        cityController.clear();
        stateController.clear();
        pincodeController.clear();
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Form(
            key: _formkey,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Delivery Address",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    AppSpacing.height20,

                    AddressFormField(
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your full name";
                        }
                        if (value.trim().length < 3) {
                          return "Name must be at least 3 characters";
                        }
                        return null;
                      },
                      controller: nameController,
                      icons: Icons.person,
                      title: "Full name",
                    ),
                    const SizedBox(height: 15),
                    AddressFormField(
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your phone number";
                        }

                        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
                          return "Enter a valid 10-digit phone number";
                        }

                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                      icons: Icons.phone,
                      title: "phone",
                    ),

                    const SizedBox(height: 15),
                    AddressFormField(
                      controller: addressController,
                      icons: Icons.home,
                      title: "Address (House no, Street area)",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your address";
                        }

                        if (value.trim().length < 10) {
                          return "Address is too short";
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: AddressFormField(
                            controller: cityController,
                            icons: Icons.location_city_outlined,
                            title: "City",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your city";
                              }

                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 5),

                        Expanded(
                          child: AddressFormField(
                            controller: stateController,
                            icons: Icons.table_rows_outlined,
                            title: "State",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your state";
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    AddressFormField(
                      keyboardType: TextInputType.phone,
                      controller: pincodeController,
                      icons: Icons.location_on_outlined,
                      title: "pincode",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your pincode";
                        }

                        if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
                          return "Enter a valid 6-digit pincode";
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Consumer<CheckoutProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                ColorConstant.primaryYellow,
                              ),
                            ),
                            onPressed: () async {
                              if (_formkey.currentState!.validate()) {
                                await context
                                    .read<CheckoutProvider>()
                                    .addAddress(
                                      AddressModel(
                                        id: "",
                                        fullName: nameController.text,
                                        phone: phoneController.text,
                                        address: addressController.text,
                                        city: cityController.text,
                                        state: stateController.text,
                                        pincode: pincodeController.text,
                                      ),
                                    );
                                await context
                                    .read<CheckoutProvider>()
                                    .getAddress();
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              } else {}
                            },
                            child: provider.isLoading
                                ? Center(
                                    child: SizedBox(
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.black,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Save Address",
                                    style: TextStyle(
                                      color: ColorConstant.mainWhite,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    final List<Map<String, dynamic>> _paymentMethods = [
      {"title": "Cash on Delivery", "icon": Icons.money_rounded},
      {"title": "Credit / Debit Card", "icon": Icons.credit_card_rounded},
      {"title": "UPI / Wallet", "icon": Icons.account_balance_wallet_rounded},
    ];
    return Scaffold(
      backgroundColor: ColorConstant.mainWhite,
      appBar: AppBar(
        backgroundColor: ColorConstant.mainWhite,
        title: Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Consumer<CheckoutProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delivery Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                AppSpacing.height10,

                /////////--------------------------/////////

                ///// add delivery Addressv
                InkWell(
                  onTap: () {
                    showAddressBottomSheet(context: context);
                  },
                  child: provider.address == null
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            border: BoxBorder.all(
                              color: ColorConstant.primaryYellow,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade100,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: ColorConstant.primaryYellow
                                    .withOpacity(.2),
                                child: Icon(
                                  Icons.location_on,
                                  color: ColorConstant.primaryYellow,
                                ),
                              ),
                              AppSpacing.width10,

                              Text(
                                "Add Delivery Address",
                                style: TextStyle(
                                  color: ColorConstant.mainblack,

                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey,
                                size: 17,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ColorConstant.primaryYellow,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: ColorConstant.primaryYellow
                                        .withOpacity(.15),
                                    child: Icon(
                                      Icons.location_on,
                                      color: ColorConstant.primaryYellow,
                                    ),
                                  ),
                                  SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      "Delivery Address",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  InkWell(
                                    onTap: () {
                                      showAddressBottomSheet(
                                        context: context,
                                        address: provider.address,
                                      );
                                      // Open Edit Bottom Sheet
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColorConstant.primaryYellow
                                            .withOpacity(.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Edit",
                                        style: TextStyle(
                                          color: ColorConstant.primaryYellow,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              Text(
                                provider.address!.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                provider.address!.phone,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                "${provider.address!.address},\n"
                                "${provider.address!.city}, "
                                "${provider.address!.state} - "
                                "${provider.address!.pincode}",
                                style: TextStyle(
                                  height: 1.5,
                                  color: Colors.grey.shade800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                if (widget.isCartCheckout)
                  Text(
                    "Products",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 10),

                if (widget.isCartCheckout)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.cartItems!.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems![index];

                      return CartProductCard(cart: item);
                    },
                  )
                else
                  AppSpacing.height20,
                ///// payment section
                Text(
                  "Payment Method",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(_paymentMethods.length, (index) {
                          final payment = _paymentMethods[index];
                          return PaymentMethod(
                            isSelected: provider.selectedIndex == index,
                            onTap: () {
                              provider.selectedPaymentMethod(index);
                              log(provider.selectedIndex.toString());
                            },
                            icon: payment["icon"],
                            title: payment["title"],
                          );
                        }),

                        AppSpacing.height20,
                        Text(
                          "Order Summary",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.height10,

                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade200,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Subtotal"),
                                  Spacer(),

                                  Icon(Icons.currency_rupee, size: 15),
                                  Text(widget.subtotal.toString()),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text("Shipping fee"),
                                  Spacer(),

                                  Icon(Icons.currency_rupee, size: 15),
                                  Text(provider.deliveryFee.toString()),
                                ],
                              ),
                              SizedBox(height: 5),
                              Divider(),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    "Total",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Spacer(),
                                  Icon(Icons.currency_rupee, size: 17),
                                  Text(
                                    "${widget.subtotal + provider.deliveryFee}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100,
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,

                              fontSize: 19,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 05),
                          Row(
                            children: [
                              Icon(Icons.currency_rupee, size: 15),

                              Text(
                                totalPrice.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 50),

                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final provider = context.read<CheckoutProvider>();

                            if (provider.address == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please add a delivery address.",
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            if (provider.selectedIndex == 0) {
                              final finalPrice =
                                  widget.subtotal +
                                  checkoutProvider.deliveryFee;

                              final user = FirebaseAuth.instance.currentUser!;

                              if (widget.isCartCheckout) {
                                // Cart Checkout
                                for (final item in widget.cartItems!) {
                                  await context
                                      .read<CheckoutProvider>()
                                      .placeOrder(
                                        myOrder: MyOrdersModel(
                                          id: "",
                                          userId: user.uid,
                                          productId: item.productId,
                                          productName: item.title,
                                          productImage: item.imageUrl,
                                          quantity: item.quantity,
                                          productPrice: item.price,
                                          totalPrice:
                                              item.price * item.quantity,
                                          paymentMethod: "Cash On Delivery",
                                          paymentStatus: "Pending",
                                          paymentId: "",
                                          orderStatus: "Pending",
                                          orderedAt: Timestamp.now(),
                                        ),
                                      );
                                }

                                await context
                                    .read<PaymentHistoryProvider>()
                                    .saveTransactions(
                                      PaymentHistoryModel(
                                        id: "",
                                        userId: user.uid,
                                        productId: "",
                                        productName: "Cart Checkout",
                                        productImage: "",
                                        amount: finalPrice,
                                        paymentMethod: "Cash On Delivery",
                                        paymentStatus: "Pending",
                                        paymentId: "",
                                        paidAt: Timestamp.now(),
                                      ),
                                    );

                                await context
                                    .read<CartProvider>()
                                    .clearCartFromFirestore();
                              } else {
                                // Buy Now
                                await context
                                    .read<CheckoutProvider>()
                                    .placeOrder(
                                      myOrder: MyOrdersModel(
                                        id: "",
                                        userId: user.uid,
                                        productId: widget.product!.id ?? "",
                                        productName: widget.product!.title,
                                        productImage: widget.product!.imageUrl,
                                        quantity: 1,
                                        productPrice: widget.product!.price,
                                        totalPrice: finalPrice,
                                        paymentMethod: "Cash On Delivery",
                                        paymentStatus: "Pending",
                                        paymentId: "",
                                        orderStatus: "Pending",
                                        orderedAt: Timestamp.now(),
                                      ),
                                    );

                                await context
                                    .read<PaymentHistoryProvider>()
                                    .saveTransactions(
                                      PaymentHistoryModel(
                                        id: "",
                                        userId: user.uid,
                                        productId: widget.product!.id ?? "",
                                        productName: widget.product!.title,
                                        productImage: widget.product!.imageUrl,
                                        amount: finalPrice,
                                        paymentMethod: "Cash On Delivery",
                                        paymentStatus: "Pending",
                                        paymentId: "",
                                        paidAt: Timestamp.now(),
                                      ),
                                    );
                              }

                              if (!mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OrderStatusScreen(
                                    status: OrderStatusType.success,
                                  ),
                                ),
                              );
                              // COD Flow
                            } else {
                              razorpayService.openCheckout(
                                key: "rzp_test_Re0j3JX6m8vsmt",
                                amount: totalPrice,
                                name: "Zorrow Cart",
                                description: "Order Payment",
                                contact: provider.address!.phone,
                                email: "customer@example.com",
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 2),
                                  color: ColorConstant.primaryYellow
                                      .withOpacity(.5),
                                  blurRadius: 5,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                              color: ColorConstant.primaryYellow,
                            ),

                            child: Center(
                              child: Text(
                                "Place order",
                                style: TextStyle(
                                  color: ColorConstant.mainWhite,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
