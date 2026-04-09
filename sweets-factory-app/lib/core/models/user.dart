enum UserRole {
  staff('staff', 'موظف'),
  kitchen('kitchen', 'مطبخ'),
  delivery('delivery', 'سائق'),
  admin('admin', 'مدير');

  final String value;
  final String arabicName;
  const UserRole(this.value, this.arabicName);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.staff,
    );
  }
}

class User {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;
  final List<String> permissions;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.permissions = const [],
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['name'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: UserRole.fromString(json['role'] ?? 'staff'),
      permissions: List<String>.from(json['permissions'] ?? []),
      isActive: json['enabled'] != 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role.value,
      'permissions': permissions,
      'enabled': isActive ? 1 : 0,
    };
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission) || role == UserRole.admin;
  }
}

class Payment {
  final String id;
  final String orderId;
  final double amount;
  final PaymentMethod paymentMethod;
  final String? erpPaymentEntryId;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    this.erpPaymentEntryId,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['name'] ?? '',
      orderId: json['order_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.fromString(json['payment_method'] ?? 'cash'),
      erpPaymentEntryId: json['erp_payment_entry_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'amount': amount,
      'payment_method': paymentMethod.value,
      'erp_payment_entry_id': erpPaymentEntryId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum PaymentMethod {
  cash('cash', 'نقداً'),
  card('card', 'بطاقة'),
  erpCredit('erp_credit', 'رصيد ERP');

  final String value;
  final String arabicName;
  const PaymentMethod(this.value, this.arabicName);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}
