# خطة مشروع تطبيق إدارة مصنع حلويات وطرد

## 1. تحليل وظيفي للنظام

### أ. مدخل الطلبات (Order Entry)
**الوظائف الأساسية:**
- إدخال بيانات العميل والطلب
- رفع مرفقات (صور تصميم، مواقع)
- متابعة حالة الدفع (نقدًا أو آجل)
- عرض تاريخ الطلبات السابقة

**التفاعل مع ERPNext:** إنشاء `Sales Order` تلقائيًا

### ب. المطبخ (Kitchen Module)
**الوظائف الأساسية:**
- استعراض الطلبات النشطة
- إدارة ترتيب التحضير حسب وقت التسليم
- تحديث حالة الطلب (Pending → In Progress → Ready)
- التنبيهات الذكية حسب زمن التحضير

**التفاعل مع ERPNext:** قراءة `Production Plan` وتحديث `Work Order`

### ج. سائق الطرد (Delivery Module)
**الوظائف الأساسية:**
- استعراض الطلبات الجاهزة للتوصيل
- تحديث حالة التوصيل
- تحصيل المبالغ المتبقية
- التوقيع الإلكتروني عند الاستلام

**التفاعل مع ERPNext:** إغلاق `Sales Invoice`

### د. المدير (Admin Dashboard)
**الوظائف الأساسية:**
- مراقبة الأداء العام
- تقارير المبيعات والتكاليف
- إدارة الصلاحيات
- مزامنة البيانات مع ERPNext

---

## 2. هيكل قاعدة البيانات

### Schema المقترح

```sql
-- المنتجات
Products {
  id: UUID
  erp_product_id: String (FK to ERPNext Item)
  name: String
  category: String (كيك، حلويات، توصيل)
  prep_time: Integer (بالساعات)
  price: Decimal
  image_url: String
  is_active: Boolean
}

-- الطلبات
Orders {
  id: UUID
  erp_sales_order_id: String
  customer_id: UUID
  status: Enum (pending, confirmed, in_kitchen, ready, delivered, cancelled)
  total_amount: Decimal
  paid_amount: Decimal
  remaining_amount: Decimal
  delivery_date: DateTime
  delivery_address: String
  attachment_urls: JSON Array
  created_at: DateTime
  updated_at: DateTime
}

-- تفاصيل الطلب
OrderItems {
  id: UUID
  order_id: UUID (FK)
  product_id: UUID (FK)
  quantity: Integer
  unit_price: Decimal
  special_instructions: Text
}

-- المدفوعات
Payments {
  id: UUID
  order_id: UUID (FK)
  amount: Decimal
  payment_method: Enum (cash, card, erp_credit)
  erp_payment_entry_id: String
  created_at: DateTime
}

-- المستخدمين
Users {
  id: UUID
  erp_user_id: String
  username: String
  role: Enum (staff, kitchen, delivery, admin)
  permissions: JSON Array
}
```

### إدارة المرفقات

```
Attachments {
  id: UUID
  order_id: UUID (FK)
  file_type: Enum (image, document, location)
  file_url: String
  erp_file_id: String
  uploaded_at: DateTime
}
```

---

## 3. شاشات التطبيق الأساسية

### شاشة الدخول
- مصادقة عبر ERPNext API (`/api/method/login`)

### صفحة أمر عمل جديد
- اختيار المنتج، الكمية، السعر
- رفع المرفقات (صور، مستندات)
- اختيار وقت التسليم

### صفحة استلام المدفوعات
- تتبع المبلغ المستحق والمتبقي
- تحديث السجل المالي فوراً

### صفحة مراجعات الطلبات
- عرض الطلبات مع فلاتر متقدمة
- حالات الطلب: Pending, In Progress, Ready, Delivered

---

## 4. سيناريوهات العمل التفصيلية

### سيناريو 1: موظف الحجز
1. دخول النظام
2. اختيار "أمر عمل جديد"
3. اختيار المنتج وتفاصيل الطلب
4. رفع صورة التصميم المطلوب
5. تسجيل دفعة مقدم
6. حفظ → ترحيل تلقائي إلى ERPNext كـ Sales Order

### سيناريو 2: رئيس المطبخ
1. استلام إشعار بطلب جديد
2. مراجعة تفاصيل الطلب والتصميم
3. تغيير الحالة إلى "In Progress"
4. عند الاكتمال → "Ready"
5. إرسال إشعار للسائق

### سيناريو 3: سائق الطرد
1. استعراض الطلبات الجاهزة
2. تحديد الطلب والتوجه للتوصيل
3. تحديث الحالة إلى "On Delivery"
4. تحصيل المبلغ المتبقي
5. تحديث إلى "Delivered" → إغلاق الفاتورة في ERPNext

---

## 5. آلية إنذارات المطبخ الذكية

```javascript
// منطق التنبيهات
function generateKitchenAlerts(orders) {
  const alerts = [];

  orders.forEach(order => {
    const product = getProduct(order.product_id);
    const prepTimeHours = product.prep_time;
    const deliveryTime = new Date(order.delivery_date);
    const now = new Date();
    const timeUntilDelivery = (deliveryTime - now) / (1000 * 60 * 60);

    if (timeUntilDelivery <= prepTimeHours && timeUntilDelivery > 0) {
      alerts.push({
        order_id: order.id,
        product: product.name,
        urgency: 'HIGH',
        message: `${product.name} - بدء التحضير الآن!`
      });
    }
  });

  return alerts;
}
```

**أمثلة:**
- تورتة فراولة (3 ساعات تحضير) → تنبيه قبل 3 ساعات
- حلويات ساخنة (30 دقيقة) → تنبيه قبل 30 دقيقة

---

## 6. التوصيات التقنية

### منصة التطوير: **Flutter**
- تطبيق واحد لـ iOS و Android
- أداء ممتاز مع UI سلس
- دعم جيد للتكامل مع REST APIs
- سهولة الصيانة والتوسع

### آلية الربط مع ERPNext

```dart
class ERPNextService {
  final String baseUrl = 'https://your-erpnext.com';
  final String apiKey = 'YOUR_API_KEY';
  final String apiSecret = 'YOUR_API_SECRET';

  Future<void> createSalesOrder(Order order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/resource/Sales Order'),
      headers: {
        'Authorization': 'token $apiKey:$apiSecret',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'customer': order.customerId,
        'items': order.items,
        'delivery_date': order.deliveryDate,
      })
    );
  }
}
```

### التوسع
```
┌─────────────────────────────────┐
│         التطبيق (Flutter)       │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│      API Layer (Dart)           │
│  ┌─────────┬─────────┬────────┐ │
│  │  Sales  │ Kitchen │ Delivery│ │
│  └─────────┴─────────┴────────┘ │
└────────────┬────────────────────┘
             │ REST API
             ▼
┌─────────────────────────────────┐
│        ERPNext                   │
│  ┌─────────┬─────────┬────────┐ │
│  │Sales    │Produ-   │Invo-    │ │
│  │Order    │ction    │ice      │ │
│  └─────────┴─────────┴────────┘ │
└─────────────────────────────────┘
```

---

## 7. مخطط زمني MVP (6 أسابيع)

| الأسبوع | المهام |
|---------|--------|
| 1 | تصميم UI/UX + إعداد بيئة Flutter |
| 2 | تطوير شاشات الدخول والطلبات |
| 3 | تطوير شاشات المطبخ + التنبيهات |
| 4 | تطوير شاشات السائق والتوصيل |
| 5 | ربط API مع ERPNext + اختبار المرفقات |
| 6 | الاختبار الشامل + الإصلاح + الإطلاق |
