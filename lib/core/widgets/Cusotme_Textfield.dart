import 'package:flutter/material.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';

class CustomeTextfield extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? maxline;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  CustomeTextfield({
    super.key,
    required this.icon,
    required this.label,
    this.maxline,
    this.keyboardType,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: keyboardType ?? null,
      maxLines: maxline ?? 1,
      decoration: InputDecoration(
        fillColor: ColorConstant.mainWhite,
        filled: true,
        prefixIcon: Icon(icon, color: ColorConstant.seconfaryYellow),
        hint: Text(label),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
