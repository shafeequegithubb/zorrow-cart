
import 'package:flutter/material.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/core/constants/app_spacing.dart';

class PaymentMethod extends StatelessWidget {
  final bool isSelected;
  final void Function()? onTap;
  final IconData icon;
  final String title;
  const PaymentMethod({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: WidgetStateProperty.all(Colors.transparent),

      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? ColorConstant.primaryYellow
                : Colors.transparent,
          ),
          color: isSelected
              ? ColorConstant.primaryYellow.withOpacity(.1)
              : Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? ColorConstant.primaryYellow : Colors.grey,
              size: 25,
            ),
            AppSpacing.width10,
            Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
            Spacer(),
            isSelected
                ? Icon(Icons.check_circle, color: ColorConstant.primaryYellow)
                : Icon(Icons.circle_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
