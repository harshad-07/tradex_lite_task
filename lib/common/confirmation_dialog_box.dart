import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class ConfirmationDialogBox extends StatelessWidget {
  final String title;
  final String content;
  final String? elevatedButtonText;
  final String? textButtonText;
  final VoidCallback? onElevatedButtonPressed;
  final VoidCallback? onTextButtonPressed;
  final Color? elevatedBtnBgColor;
  const ConfirmationDialogBox({
    super.key,
    required this.title,
    required this.content,
    this.elevatedButtonText,
    this.textButtonText,
    this.onElevatedButtonPressed,
    this.onTextButtonPressed,
    this.elevatedBtnBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      title: Text(title),
      content: Text(content),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: elevatedBtnBgColor ?? AppColors.loss,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onElevatedButtonPressed ?? () => Navigator.pop(context, false),
          child: Text(
            elevatedButtonText ?? "No",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: onTextButtonPressed ?? () => Navigator.pop(context, true),
          child: Text(textButtonText ?? "Yes", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        ),
      ],
    );
  }
}
