import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

String? emailValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email is required';
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
    return 'Enter a valid email';
  }
  return null;
}

String? passValidator(String? v) {
  if (v == null || v.isEmpty) return 'Password is required';
  if (v.length < 6) return 'Minimum 6 characters';
  return null;
}

showToast(context, String message, {Widget? icon, Color? bgColor, int? durationInSec}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        spacing: 10,
        children: [
          if (icon != null) icon,
          Text(message, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        ],
      ),
      backgroundColor: bgColor ?? (isDark ? AppColors.darkCard : AppColors.lightCard),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: Duration(seconds: durationInSec ?? 2),
    ),
  );
}
