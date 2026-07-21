import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/core/constants/app_spacing.dart';
import 'package:zorrow_cart/features/auth/provider/auth_provider.dart';
import 'package:zorrow_cart/features/presentation/bottom_navigartion_bar/bottom_navigation.dart';
import 'package:zorrow_cart/features/presentation/home/presentation/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 7,

                          offset: Offset(0, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          ColorConstant.primaryYellow,
                          ColorConstant.seconfaryYellow,
                        ],
                      ),
                    ),
                    child: Icon(Icons.diamond, color: Colors.white, size: 40),
                  ),
                  SizedBox(height: 20),

                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: ColorConstant.mainblack,
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Sign in to your account"),

                  AppSpacing.height20,

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 60),
                        Expanded(
                          child: Consumer<AuthenticationProvider>(
                            builder: (context, authprovider, child) {
                              if (authprovider.isLoading) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return InkWell(
                                onTap: () async {
                                  try {
                                    await authprovider.signInWithGoogle();

                                    if (context.mounted &&
                                        authprovider.user != null) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BottomNavigation(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Login failed"),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 7,

                                        offset: Offset(0, 7),
                                      ),
                                    ],
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(width: 1),
                                  ),
                                  height: 50,
                                  width: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.google,
                                        size: 22,
                                        color: Colors.green.shade700,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Google",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
