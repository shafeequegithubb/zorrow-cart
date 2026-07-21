import 'package:flutter/material.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';

class AddressFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String title;
  final IconData icons;
  final TextInputType? keyboardType;
  const AddressFormField({
    super.key,
    required this.icons,
    required this.title,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType ?? TextInputType.name,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: ColorConstant.primaryYellow),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),

        fillColor: Colors.grey.shade200,
        filled: true,
        prefixIcon: Icon(icons),
        hintText: title,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
