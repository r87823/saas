import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/api/erp_next_service.dart';
import '../../../shared/themes/app_colors.dart';
import '../../orders/screens/orders_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final erpService = context.read<ERPNextService>();
    final success = await erpService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrdersScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.background),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'فشل تسجيل الدخول. يرجى التحقق من بياناتك.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error.withOpacity(0.95),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // حقل اسم المستخدم المحسّن
          TextFormField(
            controller: _usernameController,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: 'اسم المستخدم',
              labelStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              hintText: 'أدخل اسم المستخدم',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                (states) => const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
              filled: true,
              fillColor: AppColors.backgroundSecondary.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال اسم المستخدم';
              }
              if (value.length < 3) {
                return 'يجب أن يكون اسم المستخدم 3 أحرف على الأقل';
              }
              return null;
            },
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          // حقل كلمة المرور المحسّن
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              labelStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              hintText: 'أدخل كلمة المرور',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                (states) => const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: AppColors.backgroundSecondary.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              if (value.length < 6) {
                return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
              }
              return null;
            },
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),

          // زر نسيت كلمة المرور
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('سيتم توجيهك إلى صفحة استعادة كلمة المرور'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 28),

          // زر تسجيل الدخول المحسّن
          Consumer<ERPNextService>(
            builder: (context, erpService, child) {
              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: erpService.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    elevation: 0,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: erpService.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.background,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.background.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Transform.flip(
                                flipX: true,
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 300.ms);
            },
          ),
        ],
      ),
    );
  }
}
