# خطوط Cairo

لتثبيت خط Cairo للتطبيق، قم بتنفيذ الخطوات التالية:

1. قم بتحميل خطوط Cairo من الرابط:
   https://github.com/Gue3bara/Cairo_Fonts/releases

2. ضع ملفات الخطوط في المجلد:
   ```
   sweets-factory-app/assets/fonts/
   ```

3. تأكد من وجود الملفات التالية:
   - Cairo-Regular.ttf
   - Cairo-Medium.ttf
   - Cairo-SemiBold.ttf
   - Cairo-Bold.ttf
   - Cairo-ExtraBold.ttf

4. بعد إضافة الخطوط، قم بتشغيل:
   ```bash
   flutter pub get
   flutter clean
   flutter run
   ```

## ملاحظة

إذا لم تكن الخطوط متوفرة حالياً، سيعمل التطبيق بخط الافتراضي الخاص بـ Flutter.
