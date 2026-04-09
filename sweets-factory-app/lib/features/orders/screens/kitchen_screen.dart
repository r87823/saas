import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/order.dart';
import '../../../shared/themes/app_colors.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المطبخ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final activeOrders = orderProvider.kitchenOrders;

          // تصفية الطلبات حسب الأولوية
          final sortedOrders = [...activeOrders]..sort((a, b) {
            if (a.needsUrgentAlert() && !b.needsUrgentAlert()) return -1;
            if (!a.needsUrgentAlert() && b.needsUrgentAlert()) return 1;
            return a.deliveryDate.compareTo(b.deliveryDate);
          });

          if (sortedOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد طلبات نشطة',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // تحديث الطلبات من ERPNext
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedOrders.length,
              itemBuilder: (context, index) {
                return _buildKitchenOrderCard(sortedOrders[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildKitchenOrderCard(Order order) {
    final isUrgent = order.needsUrgentAlert();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isUrgent
              ? Border.all(color: AppColors.error, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر مع حالة الطوارئ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'عاجل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // وقت التسليم المتبقي
              _buildTimeRemaining(order.deliveryDate),
              const SizedBox(height: 12),

              // بيانات العميل
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    order.customerPhone,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // المرفقات
              if (order.attachmentUrls.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: order.attachmentUrls.take(3).map((url) {
                    return Chip(
                      avatar: const Icon(Icons.image, size: 18),
                      label: Text(
                        'صورة ${order.attachmentUrls.indexOf(url) + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
                if (order.attachmentUrls.length > 3)
                  const Text(
                    '+${} صور أخرى',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 12),
              ],

              // قائمة المنتجات
              const Text(
                'المنتجات:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.productName),
                    ),
                    Text('×${item.quantity}'),
                  ],
                ),
              )),
              const SizedBox(height: 12),

              // أزرار الإجراءات
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _updateOrderStatus(order, OrderStatus.inKitchen);
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('بدء التحضير'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _updateOrderStatus(order, OrderStatus.ready);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('جاهز'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRemaining(DateTime deliveryDate) {
    final now = DateTime.now();
    final difference = deliveryDate.difference(now);

    if (difference.isNegative) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.warning, color: AppColors.error, size: 16),
            SizedBox(width: 4),
            Text(
              'متأخر!',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    Color color;
    if (hours < 1) {
      color = AppColors.error;
    } else if (hours < 2) {
      color = AppColors.warning;
    } else {
      color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            'متبقي: $hours ساعة $minutes دقيقة',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(Order order, OrderStatus newStatus) {
    context.read<OrderProvider>().updateOrderStatus(order.id, newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث الطلب إلى ${newStatus.arabicName}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
