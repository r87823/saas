import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/api/erp_next_service.dart';
import '../../../shared/themes/app_colors.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ERPNextService>().checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // خلفية ديكورية
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.5),
                        radius: 1.2,
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ),

                // شعار التطبيق المحسّن
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(-1, -1),
                      end: Alignment(1, 1),
                      colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 60,
                        offset: const Offset(0, 20),
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cake,
                    size: 64,
                    color: AppColors.background,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .shimmer(
                      duration: 2000.ms,
                      color: AppColors.background.withOpacity(0.3),
                    )
                    .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02))
                    .then()
                    .animate()
                    .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                    .slideY(begin: -0.3, end: 0, curve: Curves.easeOutBack),
                const SizedBox(height: 40),

                // عنوان التطبيق مع نص فرعي
                Column(
                  children: [
                    Text(
                      'مصنع الحلويات',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .slideY(begin: -0.2, end: 0),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'نظام إدارة المصنع والتوصيل المتكامل',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 300.ms)
                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                  ],
                ),
                const SizedBox(height: 56),

                // نموذج الدخول المحسّن
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 50,
                        offset: const Offset(0, 24),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: const LoginForm(),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                const SizedBox(height: 32),

                // معلومات إضافية
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'نظام آمن ومحمي',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
