import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zorrow_cart/features/auth/provider/auth_provider.dart';
import 'package:zorrow_cart/features/presentation/cart/provider/cart_provider.dart';
import 'package:zorrow_cart/features/presentation/checkout%20screen/provider/checkout_provider.dart';
import 'package:zorrow_cart/features/presentation/home/provider/add_product_provider.dart';
import 'package:zorrow_cart/features/presentation/home/provider/home_provider.dart';
import 'package:zorrow_cart/features/presentation/home/provider/product_details_provider.dart';
import 'package:zorrow_cart/features/presentation/profile/provider/payment_history_provider.dart';
import 'package:zorrow_cart/features/presentation/profile/provider/profile_provider.dart';
import 'package:zorrow_cart/features/presentation/splash/splash_screen.dart';
import 'package:zorrow_cart/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => AddProductProvider()),
        ChangeNotifierProvider(create: (context) => ProductDetailsProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => CheckoutProvider()),
        ChangeNotifierProvider(create: (context) => PaymentHistoryProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
