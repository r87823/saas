import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/order.dart';
import '../../../core/api/erp_next_service.dart';
import '../../../shared/themes/app_colors.dart';
import 'new_order_screen.dart';
import 'kitchen_screen.dart';
import 'delivery_screen.dart';
import 'payment_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _OrdersListScreen(),
    KitchenScreen(),
    DeliveryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<ERPNextService>(
            builder: (context, erpService, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  erpService.logout();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            selectedIcon: Icon(Icons.list_alt),
            label: 'الطلبات',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            selectedIcon: Icon(Icons.restaurant),
            label: 'المطبخ',
          ),
          NavigationDestination(
            icon: Icon(Icons.delivery_dining),
            selectedIcon: Icon(Icons.delivery_dining),
            label: 'التوصيل',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewOrderScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('طلب جديد', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}

class _OrdersListScreen extends StatefulWidget {
  const _OrdersListScreen();

  @override
  State<_OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<_OrdersListScreen> {
  OrderStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // فلاتر الحالة
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip(null, 'الكل'),
              _buildFilterChip(OrderStatus.pending, 'قيد الانتظار'),
              _buildFilterChip(OrderStatus.inKitchen, 'في المطبخ'),
              _buildFilterChip(OrderStatus.ready, 'جاهز'),
              _buildFilterChip(OrderStatus.delivered, 'تم'),
            ],
          ),
        ),
        // قائمة الطلبات
        Expanded(
          child: Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              var filteredOrders = orderProvider.orders;
              if (_selectedFilter != null) {
                filteredOrders = filteredOrders
                    .where((o) => o.status == _selectedFilter)
                    .toList();
              }

              if (filteredOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد طلبات',
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
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(filteredOrders[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(OrderStatus? status, String label) {
    final isSelected = _selectedFilter == status;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? status : null;
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.customerName,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.deliveryDate),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.totalAmount.toStringAsFixed(2)} ريال',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (order.remainingAmount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'متبقي: ${order.remainingAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
