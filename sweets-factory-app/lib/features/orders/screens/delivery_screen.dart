import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/order.dart';
import '../../../shared/themes/app_colors.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التوصيل'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final readyOrders = orderProvider.readyOrders
              .where((o) => o.status == OrderStatus.ready || o.status == OrderStatus.onDelivery)
              .toList();

          if (readyOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delivery_dining,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد طلبات للتوصيل',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: readyOrders.length,
            itemBuilder: (context, index) {
              return _buildDeliveryCard(readyOrders[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildDeliveryCard(Order order) {
    final isOnDelivery = order.status == OrderStatus.onDelivery;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
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
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 12),

            // بيانات العميل
            _buildInfoRow(Icons.person_outline, order.customerName),
            _buildInfoRow(Icons.phone, order.customerPhone),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, order.deliveryAddress),
            const SizedBox(height: 12),

            // تفاصيل الطلب
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تفاصيل الطلب:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(item.productName),
                        const Spacer(),
                        Text('×${item.quantity}'),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // الدفع
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: order.remainingAmount > 0
                    ? AppColors.warning.withOpacity(0.2)
                    : AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المبلغ المستحق:'),
                  Text(
                    '${order.remainingAmount.toStringAsFixed(2)} ريال',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: order.remainingAmount > 0
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // أزرار الإجراءات
            if (order.status == OrderStatus.ready)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _updateOrderStatus(order, OrderStatus.onDelivery);
                  },
                  icon: const Icon(Icons.directions_bike),
                  label: const Text('بدء التوصيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else if (order.status == OrderStatus.onDelivery)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showCallDialog(order);
                      },
                      icon: const Icon(Icons.call),
                      label: const Text('اتصال'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showNavigationDialog(order);
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('الموقع'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showDeliveryConfirmation(order);
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('تم التوصيل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(status.value).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.arabicName,
        style: TextStyle(
          color: AppColors.getStatusColor(status.value),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
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

  void _showCallDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اتصال بالعميل'),
        content: Text('الرقم: ${order.customerPhone}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // يمكن إضافة منطق الاتصال الفعلي هنا
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('جاري الاتصال بـ ${order.customerPhone}')),
              );
            },
            child: const Text('اتصال'),
          ),
        ],
      ),
    );
  }

  void _showNavigationDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فتح الموقع'),
        content: Text('العنوان: ${order.deliveryAddress}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // يمكن إضافة فتح خرائط Google هنا
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري فتح الخرائط...')),
              );
            },
            child: const Text('فتح الخرائط'),
          ),
        ],
      ),
    );
  }

  void _showDeliveryConfirmation(Order order) {
    if (order.remainingAmount > 0) {
      // طلب تأكيد تحصيل المبلغ
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تحصيل المبلغ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المبلغ المستحق: ${order.remainingAmount.toStringAsFixed(2)} ريال'),
              const SizedBox(height: 12),
              const Text('هل تم تحصيل المبلغ؟'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لا'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _completeDelivery(order);
              },
              child: const Text('نعم، تم التحصيل'),
            ),
          ],
        ),
      );
    } else {
      _completeDelivery(order);
    }
  }

  void _completeDelivery(Order order) {
    _updateOrderStatus(order, OrderStatus.delivered);

    // يمكن إضافة منطق التوقيع الإلكتروني هنا
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم التوصيل بنجاح!'),
        content: const Text('تم إغلاق الطلب وتحديث الفاتورة في النظام.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
