import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE91E63);
  static const Color primaryDark = Color(0xFFC2185B);
  static const Color primaryLight = Color(0xFFF48FB1);

  static const Color secondary = Color(0xFF9C27B0);
  static const Color secondaryDark = Color(0xFF7B1FA2);
  static const Color secondaryLight = Color(0xFFBA68C8);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static const Color success = Color(0xFF4CAF50);
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
