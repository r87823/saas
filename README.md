# تطبيق مصنع الحلويات 🍰

تطبيق إدارة متكامل لمصنع الحلويات يتضمن إدارة الطلبات، المطبخ، والتوصيل مع التكامل مع ERPNext.

## الميزات

### إدارة الطلبات
- ✅ إنشاء طلبات جديدة
- ✅ تصفية الطلبات حسب الحالة
- ✅ عرض تفاصيل الطلب
- ✅ إدارة الدفع والمبالغ المستحقة

### شاشة المطبخ
- 🔥 عرض الطلبات النشطة
- ⏰ تنبيهات الطلبات العاجلة
- 📋 قائمة المنتجات المطلوبة
- ✅ تحديث حالة التحضير

### شاشة التوصيل
- 📦 عرض الطلبات الجاهزة
- 📞 الاتصال بالعملاء
- 🗺️ فتح الموقع على الخرائط
- 💰 تحصيل المبالغ
- ✅ تأكيد التوصيل

## التثبيت

### المتطلبات
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### خطوات التثبيت

1. استنساخ المستودع:
```bash
git clone <repository-url>
cd sweets-factory-app
```

2. تثبيت الاعتمادات:
```bash
flutter pub get
```

3. تشغيل التطبيق:
```bash
flutter run
```

## الإعدادات

### تكوين ERPNext

عدل ملف `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  // إعدادات ERPNext
  static const String erpBaseUrl = 'https://your-instance.frappe.cloud';
  static const String erpApiKey = 'your-api-key';
  static const String erpApiSecret = 'your-api-secret';

  // استخدام API Key بدلاً من تسجيل الدخول
  static const bool useApiKeyAuth = true;
}
```

## هيكل المشروع

```
lib/
├── core/
│   ├── api/              # خدمات API
│   ├── config/           # الإعدادات
│   └── models/           # نماذج البيانات
├── features/
│   ├── auth/             # المصادقة
│   └── orders/           # إدارة الطلبات
└── shared/
    └── themes/           # السمات والألوان
```

## المكتبات المستخدمة

| المكتبة | الوصف |
|---------|-------|
| `provider` | إدارة الحالة |
| `http` | طلبات HTTP |
| `flutter_animate` | الرسوم المتحركة |
| `shared_preferences` | التخزين المحلي |
| `connectivity_plus` | فحص الاتصال |
| `image_picker` | اختيار الصور |
| `file_picker` | اختيار الملفات |
| `url_launcher` | فتح الروابط والخرائط |

## لقطات الشاشة

### شاشة تسجيل الدخول
![Login Screen](assets/screenshots/login.png)

### شاشة الطلبات
![Orders Screen](assets/screenshots/orders.png)

### شاشة المطبخ
![Kitchen Screen](assets/screenshots/kitchen.png)

### شاشة التوصيل
![Delivery Screen](assets/screenshots/delivery.png)

## المساهمة

نرحب بالمساهمات! يرجى اتباع الخطوات التالية:

1. عمل fork للمشروع
2. إنشاء فرع جديد (`git checkout -b feature/AmazingFeature`)
3. الالتزام بالتغييرات (`git commit -m 'Add some AmazingFeature'`)
4. الدفع للفرع (`git push origin feature/AmazingFeature`)
5. فتح Pull Request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT - راجع ملف LICENSE للتفاصيل.

## الدعم

إذا واجهت أي مشاكل، يرجى فتح issue على GitHub أو التواصل معنا.
