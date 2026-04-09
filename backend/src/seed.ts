import { PrismaClient, UserRole, OrderStatus } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting seed...');

  // Create admin user
  const adminPassword = await bcrypt.hash('admin123', 10);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@sweetsfactory.com' },
    update: {},
    create: {
      email: 'admin@sweetsfactory.com',
      password: adminPassword,
      name: 'مدير النظام',
      phone: '0500000000',
      role: UserRole.ADMIN,
      isActive: true,
    },
  });

  console.log('✅ Admin user created:', admin.email);

  // Create categories
  const categories = [
    { name: 'Cakes', nameAr: 'كيكات', description: 'Various types of cakes' },
    { name: 'Pastries', nameAr: 'معجنات', description: 'Sweet pastries' },
    { name: 'Cookies', nameAr: 'بسكويت', description: 'Cookies and biscuits' },
    { name: 'Chocolates', nameAr: 'شوكولات', description: 'Chocolate treats' },
    { name: 'Bakery', nameAr: 'مخبوزات', description: 'Fresh bakery items' },
  ];

  for (const cat of categories) {
    await prisma.category.upsert({
      where: { name: cat.name },
      update: {},
      create: cat,
    });
  }

  console.log('✅ Categories created');

  // Create products
  const createdCategories = await prisma.category.findMany();

  const products = [
    {
      name: 'Chocolate Cake',
      nameAr: 'كيكة شوكولاتة',
      price: 120,
      costPrice: 60,
      description: 'Delicious chocolate cake with creamy filling',
      categoryId: createdCategories[0].id,
      prepTime: 2,
      stock: 50,
    },
    {
      name: 'Red Velvet Cake',
      nameAr: 'كيكة ريد فيلفت',
      price: 150,
      costPrice: 75,
      description: 'Classic red velvet with cream cheese frosting',
      categoryId: createdCategories[0].id,
      prepTime: 2,
      stock: 30,
    },
    {
      name: 'Croissant',
      nameAr: 'كرواسون',
      price: 15,
      costPrice: 5,
      description: 'Fresh butter croissant',
      categoryId: createdCategories[1].id,
      prepTime: 1,
      stock: 100,
    },
    {
      name: 'Danish Pastry',
      nameAr: 'معجونة دنماركية',
      price: 20,
      costPrice: 8,
      description: 'Sweet Danish pastry with fruit filling',
      categoryId: createdCategories[1].id,
      prepTime: 1,
      stock: 80,
    },
    {
      name: 'Chocolate Chip Cookies',
      nameAr: 'بسكويت شوكولاتة',
      price: 25,
      costPrice: 10,
      description: 'Soft chocolate chip cookies',
      categoryId: createdCategories[2].id,
      prepTime: 1,
      stock: 200,
    },
    {
      name: 'Macarons Box',
      nameAr: 'علبة ماكرون',
      price: 80,
      costPrice: 40,
      description: 'Box of assorted macarons',
      categoryId: createdCategories[3].id,
      prepTime: 2,
      stock: 25,
    },
    {
      name: 'Truffles',
      nameAr: 'ترافل شوكولاتة',
      price: 45,
      costPrice: 20,
      description: 'Premium chocolate truffles',
      categoryId: createdCategories[3].id,
      prepTime: 1,
      stock: 60,
    },
    {
      name: 'Artisan Bread',
      nameAr: 'خبز حرفي',
      price: 25,
      costPrice: 10,
      description: 'Freshly baked artisan bread',
      categoryId: createdCategories[4].id,
      prepTime: 1,
      stock: 40,
    },
    {
      name: 'Cheesecake',
      nameAr: 'تشيز كيك',
      price: 100,
      costPrice: 50,
      description: 'Creamy New York cheesecake',
      categoryId: createdCategories[0].id,
      prepTime: 2,
      stock: 35,
    },
    {
      name: 'Pain au Chocolat',
      nameAr: 'بان أو شوكولات',
      price: 18,
      costPrice: 7,
      description: 'Chocolate-filled croissant',
      categoryId: createdCategories[1].id,
      prepTime: 1,
      stock: 90,
    },
  ];

  for (const prod of products) {
    await prisma.product.upsert({
      where: { id: `seed-${prod.name.toLowerCase().replace(/\s+/g, '-')}` },
      update: {},
      create: {
        ...prod,
        id: `seed-${prod.name.toLowerCase().replace(/\s+/g, '-')}`,
      },
    });
  }

  console.log('✅ Products created');

  // Create sample orders
  const createdProducts = await prisma.product.findMany();

  const orders = [
    {
      customerName: 'سارة أحمد',
      customerPhone: '0501111111',
      deliveryAddress: 'الرياض، حي الملز، شارع التحلية',
      deliveryDate: new Date(Date.now() + 2 * 60 * 60 * 1000),
      totalAmount: 240,
      paidAmount: 240,
      status: OrderStatus.DELIVERED,
      notes: 'توصيل متأخر',
      userId: admin.id,
      items: [
        {
          productId: createdProducts[0].id,
          quantity: 2,
          unitPrice: 120,
          totalPrice: 240,
        },
      ],
    },
    {
      customerName: 'محمد علي',
      customerPhone: '0502222222',
      deliveryAddress: 'الرياض، حي الربوة',
      deliveryDate: new Date(Date.now() + 3 * 60 * 60 * 1000),
      totalAmount: 100,
      paidAmount: 50,
      status: OrderStatus.READY,
      notes: 'مهم جداً',
      userId: admin.id,
      items: [
        {
          productId: createdProducts[1].id,
          quantity: 1,
          unitPrice: 150,
          totalPrice: 100,
        },
      ],
    },
  ];

  for (const order of orders) {
    await prisma.order.upsert({
      where: { orderNumber: `SEED-${Math.random().toString(36).substring(7)}` },
      update: {},
      create: {
        ...order,
        orderNumber: `SEED-${Math.random().toString(36).substring(7)}`,
        items: {
          create: order.items,
        },
      },
    });
  }

  console.log('✅ Sample orders created');
  console.log('🎉 Seed completed!');
}

main()
  .catch((e) => {
    console.error('❌ Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
