import 'package:flutter/material.dart';

import '../../../../core/app_enums/app_enums.dart';
import '../../../../core/theme/app_colors.dart';

class BiometricOptInDialog extends StatelessWidget {
  final AppBiometricType type;

  const BiometricOptInDialog({super.key, required this.type});

  String get _title => type == AppBiometricType.fingerprint ? 'Enable Fingerprint Login?' : 'Enable Face ID Login?';

  String get _body => type == AppBiometricType.fingerprint ? 'Use your fingerprint for faster, secure access next time.' : 'Use Face ID for faster, secure access next time.';

  IconData get _icon => type == AppBiometricType.fingerprint ? Icons.fingerprint_rounded : Icons.face_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(_icon, size: 36, color: AppColors.primary),
            ),
            Text(
              _title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            Text(
              _body,
              style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Enable', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Maybe Later', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
