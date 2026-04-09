import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/order.dart';
import '../../../core/models/user.dart';
import '../../../shared/themes/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  final Order order;

  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _amountController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.order.remainingAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processPayment() {
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال مبلغ صحيح'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (amount > widget.order.remainingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('المبلغ يتجاوز المبلغ المتبقي'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final newPaidAmount = widget.order.paidAmount + amount;
    context.read<OrderProvider>().updatePayment(widget.order.id, newPaidAmount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تسجيل الدفعة: $amount ريال'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سند قبض'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطلب
            _buildOrderInfo(),
            const SizedBox(height: 24),

            // ملخص الدفع
            _buildPaymentSummary(),
            const SizedBox(height: 24),

            // نموذج الدفع
            _buildPaymentForm(),
            const SizedBox(height: 24),

            // تاريخ المدفوعات
            _buildPaymentHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب #${widget.order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                _buildStatusChip(widget.order.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.order.customerName,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              widget.order.customerPhone,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص الدفع',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('المبلغ الكلي', widget.order.totalAmount),
            _buildSummaryRow('المدفوع مسبقاً', widget.order.paidAmount),
            const Divider(),
            _buildSummaryRow(
              'المتبقي',
              widget.order.remainingAmount,
              isBold: true,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} ريال',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    if (widget.order.remainingAmount == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'تم سداد المبلغ بالكامل',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text('لا يوجد مبلغ مستحق'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تسجيل دفعة جديدة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // المبلغ
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'المبلغ',
                suffixText: 'ريال',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // طريقة الدفع
            const Text(
              'طريقة الدفع:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: PaymentMethod.values.map((method) {
                return RadioListTile<PaymentMethod>(
                  title: Text(method.arabicName),
                  value: method,
                  groupValue: _selectedMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value!;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // زر الإرسال
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'تسجيل الدفعة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'سجل المدفوعات',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.order.paidAmount > 0)
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.success,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text('${widget.order.paidAmount.toStringAsFixed(2)} ريال'),
                subtitle: Text(_formatDate(widget.order.createdAt)),
                trailing: Text(PaymentMethod.cash.arabicName),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'لا توجد مدفوعات مسجلة بعد',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
          ],
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
    return '${date.day}/${date.month}/${date.year}';
  }
}
