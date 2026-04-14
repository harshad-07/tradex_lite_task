import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradex_lite/core/utils/globals.dart';

import '../../../core/app_enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/provider/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  ///
  void _handleSignOut(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.read<AuthProvider>();

    final bioIcon = auth.availableBiometric == AppBiometricType.fingerprint ? Icons.fingerprint_rounded : Icons.face_rounded;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.loss.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, size: 32, color: AppColors.loss),
              ),
              const SizedBox(height: 18),

              ///
              Text(
                'Sign Out',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              ///
              Text(
                auth.biometricEnabled
                    ? 'You will need to verify your identity to sign out securely.'
                    : 'Are you sure you want to sign out? You\'ll need to enter your credentials again to log back in.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              ///
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _executeSignOut(context, auth);
                  },
                  icon: auth.biometricEnabled ? Icon(bioIcon, size: 20, color: Colors.white) : const SizedBox.shrink(),
                  label: Text(auth.biometricEnabled ? 'Verify & Sign Out' : 'Sign Out', style: const TextStyle(fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.loss,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              ///
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executeSignOut(BuildContext context, AuthProvider auth) async {
    if (auth.biometricEnabled) {
      final verified = await auth.verifyIdentity(reason: 'Verify to sign out of TradeX Lite');

      if (!verified) {
        if (context.mounted) {
          showToast(
            context,
            "Verification failed — sign out cancelled",
            icon: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
            bgColor: AppColors.loss.withValues(alpha: 0.9),
          );
        }
        return;
      }
    }

    await auth.logout();
  }

  ///
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ///
          _sectionHeader(label: 'Appearance', color: secondary),
          const SizedBox(height: 8),
          _settingTile(
            theme: theme,
            cardColor: cardColor,
            borderColor: borderColor,
            leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.primary),
            title: 'Dark Mode',
            subtitle: isDark ? 'On' : 'Off',
            trailing: Switch.adaptive(value: themeProvider.isDark, activeColor: AppColors.primary, onChanged: (_) => themeProvider.toggle()),
          ),
          const SizedBox(height: 24),

          ///
          _sectionHeader(label: 'Security', color: secondary),
          const SizedBox(height: 8),
          _biometricSettingTile(cardColor: cardColor, borderColor: borderColor, secondary: secondary),

          const SizedBox(height: 24),

          ///
          _sectionHeader(label: 'Account', color: secondary),
          const SizedBox(height: 8),
          _settingTile(
            theme: theme,
            cardColor: cardColor,
            borderColor: borderColor,
            leading: const Icon(Icons.logout_rounded, color: AppColors.loss),
            title: 'Sign Out',
            titleColor: AppColors.loss,
            onTap: () => _handleSignOut(context),
          ),
        ],
      ),
    );
  }

  ///
  Widget _sectionHeader({required String label, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _settingTile({
    required ThemeData theme,
    required Color cardColor,
    required Color borderColor,
    required Widget leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 0.5),
      ),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: titleColor),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))
            : null,
        trailing: trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _biometricSettingTile({required Color cardColor, required Color borderColor, required Color secondary}) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final theme = Theme.of(context);
        final bioType = auth.availableBiometric;

        if (bioType == AppBiometricType.none) {
          return _settingTile(
            theme: theme,
            cardColor: cardColor,
            borderColor: borderColor,
            leading: Icon(Icons.fingerprint_rounded, color: secondary),
            title: 'Biometric Login',
            subtitle: 'Not available on this device',
          );
        }

        final icon = bioType == AppBiometricType.fingerprint ? Icons.fingerprint_rounded : Icons.face_rounded;
        final label = bioType == AppBiometricType.fingerprint ? 'Fingerprint Login' : 'Face ID Login';
        return _settingTile(
          theme: theme,
          cardColor: cardColor,
          borderColor: borderColor,
          leading: Icon(icon, color: AppColors.primary),
          title: label,
          subtitle: auth.biometricEnabled ? 'Enabled' : 'Disabled',
          trailing: Switch.adaptive(
            value: auth.biometricEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) async {
              if (val) {
                await auth.enableBiometric();
              } else {
                await auth.disableBiometric();
              }
            },
          ),
        );
      },
    );
  }
}
