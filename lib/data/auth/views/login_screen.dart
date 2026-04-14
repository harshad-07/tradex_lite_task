import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../common/cust_txt_field.dart';
import '../../../common/logo_widget.dart';
import '../../../core/app_enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/globals.dart';
import '../provider/auth_provider.dart';
import 'widgets/biometric_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _passCtrl = TextEditingController();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  ///
  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkBiometricAvailability();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  ///FUNCS
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;

    if (success) {
      if (auth.isPendingBiometric) {
        await _promptBiometricOptIn(auth);
      }
      if (mounted) await auth.completeLogin(email: _emailCtrl.text.trim());
    }
  }

  Future<void> _promptBiometricOptIn(AuthProvider auth) async {
    final bioType = auth.availableBiometric;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BiometricOptInDialog(type: bioType),
    );

    if (accepted == true) {
      await auth.enableBiometric();
    }
  }

  Future<void> _handleBiometricLogin() async {
    final auth = context.read<AuthProvider>();
    await auth.biometricLogin();
  }

  ///
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ///
                  Logo(isDark: isDark),
                  const SizedBox(height: 48),

                  ///
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustTextField(
                          controller: _emailCtrl,
                          label: 'Email',
                          hint: 'trader@xlite.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: emailValidator,
                        ),
                        const SizedBox(height: 16),
                        CustTextField(
                          controller: _passCtrl,
                          label: 'Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscure: auth.obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          validator: passValidator,
                          suffixIcon: IconButton(icon: Icon(auth.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 21), onPressed: auth.togglePasswordVisibility),
                        ),
                      ],
                    ),
                  ),

                  ///
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.loss.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.loss, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(auth.errorMessage!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.loss)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  ///
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: auth.isLoading ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                          : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),

                  ///
                  if (auth.biometricEnabled) ...[const SizedBox(height: 16), _biometricBtn(type: auth.availableBiometric, onTap: _handleBiometricLogin, isDark: isDark)],

                  const SizedBox(height: 32),

                  ///
                  _credHint(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _biometricBtn({required AppBiometricType type, required VoidCallback onTap, required bool isDark}) {
    final icon = type == AppBiometricType.fingerprint ? Icons.fingerprint_rounded : Icons.face_rounded;
    final label = type == AppBiometricType.fingerprint ? 'Use Fingerprint' : 'Use Face ID';

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.primary),
        label: Text(
          label,
          style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _credHint(bool isDark) {
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: (isDark ? AppColors.darkSurface : AppColors.lightBorder).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(
            'Demo Credentials',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: secondary),
          ),
          const SizedBox(height: 4),
          Text('trader@xlite.com  /  Xlite@123', style: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.primary)),
        ],
      ),
    );
  }
}
