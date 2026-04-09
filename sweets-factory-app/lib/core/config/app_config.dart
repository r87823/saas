/// إعدادات التطبيق - يمكن تعديلها حسب بيئة الإنتاج
class AppConfig {
  AppConfig._();

  // إعدادات ERPNext
  static const String erpBaseUrl = 'https://r87823.k.frappe.cloud';
  static const String erpApiKey = '0ceab97662a582d';
  static const String erpApiSecret = '7377c26dac05cf8';

  // استخدام API Key بدلاً من تسجيل الدخول بالاسم وكلمة المرور
  static const bool useApiKeyAuth = true;

  // إعدادات عامة
  static const int defaultOrdersLimit = 20;
  static const int defaultProductsLimit = 100;

  // تفعيل وضع الاختبار
  static const bool isDevelopment = true;
}
