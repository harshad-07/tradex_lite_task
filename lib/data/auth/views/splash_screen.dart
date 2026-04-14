import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../provider/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  late final AnimationController _textCtrl;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  bool _sessionCheckStarted = false;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut);
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );

    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.15, end: 0.4).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _checkSession();
  }

  Future<void> _checkSession() async {
    if (_sessionCheckStarted) return;
    _sessionCheckStarted = true;

    final auth = context.read<AuthProvider>();
    await auth.checkSavedSession();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? [AppColors.darkBg, const Color(0xFF0D1117), const Color(0xFF0B1420)] : [AppColors.lightBg, const Color(0xFFEEF1F8), const Color(0xFFE8EDF5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              ///
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: _pulseAnim.value), blurRadius: 40, spreadRadius: 2)],
                    ),
                    child: child,
                  );
                },
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.candlestick_chart_rounded, size: 50, color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              ///
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Column(
                    children: [
                      Text(
                        'TRADEX',
                        style: GoogleFonts.spaceMono(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: 6, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'LITE',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 8, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text('v1.0.0', style: TextStyle(fontSize: 11, color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withValues(alpha: 0.5))),
              const SizedBox(height: 32),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
