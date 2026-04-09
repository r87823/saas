import 'package:flutter/foundation.dart';

enum OrderStatus {
  pending('pending', 'قيد الانتظار'),
  confirmed('confirmed', 'مؤكد'),
  inKitchen('in_kitchen', 'في المطبخ'),
  ready('ready', 'جاهز'),
  onDelivery('on_delivery', 'في التوصيل'),
  delivered('delivered', 'تم التوصيل'),
  cancelled('cancelled', 'ملغي');

  final String value;
  final String arabicName;
  const OrderStatus(this.value, this.arabicName);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class Order {
  final String id;
  final String? erpSalesOrderId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final OrderStatus status;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime deliveryDate;
  final List<OrderItem> items;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    this.erpSalesOrderId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.status,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.deliveryDate,
    required this.items,
    this.attachmentUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['name'] ?? json['id'] ?? '',
      erpSalesOrderId: json['name'],
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      status: OrderStatus.fromString(json['status'] ?? 'pending'),
      totalAmount: (json['total'] ?? json['total_amount'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      deliveryDate: DateTime.parse(json['delivery_date'] ?? DateTime.now().toString()),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ?? [],
      attachmentUrls: (json['attachment_urls'] as List<dynamic>?)
              ?.map((url) => url.toString())
              .toList() ?? [],
      createdAt: DateTime.parse(json['creation'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['modified'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': erpSalesOrderId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      'status': status.value,
      'total': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'delivery_date': deliveryDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'attachment_urls': attachmentUrls,
    };
  }

  // حساب زمن التحضير المطلوب
  int getTotalPrepTime() {
    return items.fold(0, (sum, item) => sum + item.prepTime);
  }

  // هل الطلب بحاجة لتنبيه عاجل؟
  bool needsUrgentAlert() {
    final now = DateTime.now();
    final timeUntilDelivery = deliveryDate.difference(now);
    final prepTimeNeeded = Duration(hours: getTotalPrepTime());
    return timeUntilDelivery <= prepTimeNeeded && timeUntilDelivery > Duration.zero;
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? specialInstructions;
  final int prepTime; // بالساعات

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    required this.prepTime,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['name'] ?? '',
      productId: json['item_code'] ?? '',
      productName: json['item_name'] ?? '',
      quantity: json['qty'] ?? 1,
      unitPrice: (json['rate'] ?? 0).toDouble(),
      totalPrice: (json['amount'] ?? 0).toDouble(),
      specialInstructions: json['description'],
      prepTime: json['custom_prep_time'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': productId,
      'item_name': productName,
      'qty': quantity,
      'rate': unitPrice,
      'amount': totalPrice,
      'description': specialInstructions,
    };
  }
}

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;
  List<Order> get pendingOrders => _orders.where((o) => o.status == OrderStatus.pending).toList();
  List<Order> get kitchenOrders => _orders.where((o) =>
    o.status == OrderStatus.inKitchen ||
    o.status == OrderStatus.confirmed
  ).toList();
  List<Order> get readyOrders => _orders.where((o) => o.status == OrderStatus.ready).toList();
  List<Order> get deliveryOrders => _orders.where((o) =>
    o.status == OrderStatus.onDelivery
  ).toList();

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = Order(
        id: _orders[index].id,
        erpSalesOrderId: _orders[index].erpSalesOrderId,
        customerName: _orders[index].customerName,
        customerPhone: _orders[index].customerPhone,
        deliveryAddress: _orders[index].deliveryAddress,
        status: newStatus,
        totalAmount: _orders[index].totalAmount,
        paidAmount: _orders[index].paidAmount,
        remainingAmount: _orders[index].remainingAmount,
        deliveryDate: _orders[index].deliveryDate,
        items: _orders[index].items,
        attachmentUrls: _orders[index].attachmentUrls,
        createdAt: _orders[index].createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void updatePayment(String orderId, double paidAmount) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      final remaining = order.totalAmount - paidAmount;

      _orders[index] = Order(
        id: order.id,
        erpSalesOrderId: order.erpSalesOrderId,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        deliveryAddress: order.deliveryAddress,
        status: order.status,
        totalAmount: order.totalAmount,
        paidAmount: paidAmount,
        remainingAmount: remaining,
        deliveryDate: order.deliveryDate,
        items: order.items,
        attachmentUrls: order.attachmentUrls,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
