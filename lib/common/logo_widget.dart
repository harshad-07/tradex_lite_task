import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';

class Logo extends StatelessWidget {
  const Logo({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.candlestick_chart_rounded, size: 38, color: Colors.black),
        ),
        const SizedBox(height: 16),
        Text(
          'TRADEX',
          style: GoogleFonts.spaceMono(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 4, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
        const SizedBox(height: 4),
        Text(
          'LITE',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 6, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
