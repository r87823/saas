# Backend API - Sweets Factory

خادم API متكامل لمصنع الحلويات مبني باستخدام Node.js + Express + Prisma + PostgreSQL.

## الميزات

- ✅ نظام مصادقة JWT كامل
- ✅ إدارة المستخدمين والأدوار
- ✅ إدارة الطلبات والمنتجات والتصنيفات
- ✅ نظام صلاحيات مرن (Admin, Manager, Kitchen, Delivery, Customer)
- ✅ دعم PostgreSQL
- ✅ TypeScript للكتابة الآمنة

## هيكل المشروع

```
backend/
├── prisma/
│   └── schema.prisma      # نماذج قاعدة البيانات
├── src/
│   ├── controllers/        # منطق الأعمال
│   ├── routes/            # تعريف API endpoints
│   ├── middleware/        # برامج وسيطة (المصادقة)
│   ├── utils/            # أدوات مساعدة
│   ├── types/            # تعريف الأنواع
│   └── index.ts          # نقطة الدخول الرئيسية
└── .env                 # متغيرات البيئة
```

## التثبيت

### المتطلبات

- Node.js >= 18.x
- PostgreSQL

### خطوات التثبيت

1. استنساخ المستودع:
```bash
cd backend
```

2. تثبيت الاعتمادات:
```bash
npm install
```

3. إعداد قاعدة البيانات:

```bash
# إنشاء قاعدة البيانات
createdb sweets_factory

# تشغيل الهجرات
npm run prisma:migrate

# أو استخدام Prisma Studio
npm run prisma:studio
```

4. إعداد متغيرات البيئة:
```bash
cp .env.example .env
# عدل ملف .env بإعداداتك
```

5. تشغيل الخادم:

```bash
# وضع التطوير
npm run dev

# وضع الإنتاج
npm run build
npm start
```

## API Endpoints

### المصادقة (`/api/auth`)

| الطريقة | المسار | الوصف | المصادقة |
|---------|---------|--------|----------|
| POST | `/register` | تسجيل مستخدم جديد | لا |
| POST | `/login` | تسجيل الدخول | لا |
| GET | `/me` | معلومات المستخدم الحالي | نعم |

### الطلبات (`/api/orders`)

| الطريقة | المسار | الوصف | المصادقة |
|---------|---------|--------|----------|
| GET | `/` | الحصول على جميع الطلبات | نعم |
| GET | `/:id` | الحصول على طلب محدد | نعم |
| POST | `/` | إنشاء طلب جديد | نعم |
| PATCH | `/:id/status` | تحديث حالة الطلب | Admin, Manager |
| DELETE | `/:id` | حذف طلب | Admin, Manager |

### المنتجات (`/api/products`)

| الطريقة | المسار | الوصف | المصادقة |
|---------|---------|--------|----------|
| GET | `/` | الحصول على جميع المنتجات | نعم |
| GET | `/:id` | الحصول على منتج محدد | نعم |
| POST | `/` | إنشاء منتج جديد | Admin, Manager |
| PUT | `/:id` | تحديث منتج | Admin, Manager |
| DELETE | `/:id` | حذف منتج | Admin, Manager |

### التصنيفات (`/api/categories`)

| الطريقة | المسار | الوصف | المصادقة |
|---------|---------|--------|----------|
| GET | `/` | الحصول على جميع التصنيفات | نعم |
| GET | `/:id` | الحصول على تصنيف محدد | نعم |
| POST | `/` | إنشاء تصنيف جديد | Admin, Manager |
| PUT | `/:id` | تحديث تصنيف | Admin, Manager |
| DELETE | `/:id` | حذف تصنيف | Admin, Manager |

## الأدوار

- `ADMIN` - صلاحيات كاملة
- `MANAGER` - إدارة الطلبات والمنتجات
- `KITCHEN` - عرض الطلبات وتحديث الحالة
- `DELIVERY` - عرض الطلبات وتحديث الحالة
- `CUSTOMER` - إنشاء الطلبات

## مثال الاستخدام

### تسجيل الدخول

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password123"
  }'
```

### إنشاء طلب جديد

```bash
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "customerName": "أحمد محمد",
    "customerPhone": "0501234567",
    "deliveryAddress": "الرياض، حي الملز",
    "deliveryDate": "2026-04-10T14:00:00Z",
    "items": [
      {
        "productId": "product-id-here",
        "quantity": 2
      }
    ]
  }'
```

## البيانات الأولية

لإضافة بيانات أولية (مستخدم admin ومنتجات تجريبية):

```bash
npm run seed
```

## الترخيص

ISC
