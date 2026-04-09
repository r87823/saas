import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // لون الذهبي الأساسي - إلهام من تصميم "رؤية"
  static const Color primary = Color(0xFFD4A043);
  static const Color primaryDark = Color(0xFFA07830);
  static const Color primaryLight = Color(0xFFF0C96E);

  // ألوان ثانوية
  static const Color secondary = Color(0xFF8A8477);
  static const Color secondaryDark = Color(0xFF6B665C);
  static const Color secondaryLight = Color(0xFFB8B3AB);

  // خلفية داكنة - نمط "رؤية"
  static const Color background = Color(0xFF0A0A0A);
  static const Color backgroundSecondary = Color(0xFF121212);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceHover = Color(0xFF252525);
  static const Color border = Color(0xFF2A2520);

  // ألوان النص
  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFF8A8477);
  static const Color textMuted = Color(0xFF5C5852);

  // ألوان الحالة
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // حالات الطلب
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusConfirmed = Color(0xFF2196F3);
  static const Color statusKitchen = Color(0xFF9C27B0);
  static const Color statusReady = Color(0xFF4CAF50);
  static const Color statusDelivered = Color(0xFF009688);
  static const Color statusCancelled = Color(0xFFF44336);

  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return statusPending;
      case 'confirmed':
        return statusConfirmed;
      case 'in_kitchen':
        return statusKitchen;
      case 'ready':
        return statusReady;
      case 'on_delivery':
        return info;
      case 'delivered':
        return statusDelivered;
      case 'cancelled':
        return statusCancelled;
      default:
        return textSecondary;
    }
  }
}
