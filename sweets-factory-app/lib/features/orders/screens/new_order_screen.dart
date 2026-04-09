import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/models/product.dart';
import '../../../core/models/order.dart';
import '../../../core/api/erp_next_service.dart';
import '../../../shared/themes/app_colors.dart';
import '../../orders/screens/orders_screen.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _addressController = TextEditingController();

  Product? _selectedProduct;
  int _quantity = 1;
  DateTime? _deliveryDate;
  TimeOfDay? _deliveryTime;
  List<String> _attachments = [];
  final List<OrderItem> _items = [];

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachments.addAll(result.files.map((file) => file.path ?? ''));
      });
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _deliveryDate = date;
          _deliveryTime = time;
        });
      }
    }
  }

  void _addItem() {
    if (_selectedProduct == null) return;

    setState(() {
      _items.add(OrderItem(
        id: '${_items.length + 1}',
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        quantity: _quantity,
        unitPrice: _selectedProduct!.price,
        totalPrice: _selectedProduct!.price * _quantity,
        prepTime: _selectedProduct!.prepTime,
      ));
      _selectedProduct = null;
      _quantity = 1;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate() || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول وإضافة منتج واحد على الأقل')),
      );
      return;
    }

    final erpService = context.read<ERPNextService>();

    final orderData = {
      'customer': 'CUST-001', // يمكن استبداله برمز العميل من ERPNext
      'customer_name': _customerNameController.text,
      'customer_phone': _customerPhoneController.text,
      'delivery_date': _deliveryDate?.toIso8601String(),
      'delivery_address': _addressController.text,
      'items': _items.map((item) => item.toJson()).toList(),
      'attachments': _attachments,
    };

    final success = await erpService.createSalesOrder(orderData);

    if (success && mounted) {
      // إنشاء الطلب محلياً
      final order = Order(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        erpSalesOrderId: 'SO-${DateTime.now().millisecondsSinceEpoch}',
        customerName: _customerNameController.text,
        customerPhone: _customerPhoneController.text,
        deliveryAddress: _addressController.text,
        status: OrderStatus.pending,
        totalAmount: _totalAmount,
        paidAmount: 0,
        remainingAmount: _totalAmount,
        deliveryDate: _deliveryDate ?? DateTime.now().add(const Duration(hours: 3)),
        items: _items,
        attachmentUrls: _attachments,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<OrderProvider>().addOrder(order);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الطلب بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل إنشاء الطلب. يرجى المحاولة مرة أخرى.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أمر عمل جديد'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بيانات العميل
            _buildSectionTitle('بيانات العميل'),
            TextFormField(
              controller: _customerNameController,
              decoration: _inputDecoration('اسم العميل', Icons.person),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('رقم الهاتف', Icons.phone),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: _inputDecoration('عنوان التوصيل', Icons.location_on),
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 24),

            // وقت التسليم
            _buildSectionTitle('وقت التسليم'),
            InkWell(
              onTap: _selectDateTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _deliveryDate != null && _deliveryTime != null
                          ? '${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year} - ${_deliveryTime!.hour}:${_deliveryTime!.minute.toString().padLeft(2, '0')}'
                          : 'اختر وقت التسليم',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // إضافة المنتجات
            _buildSectionTitle('المنتجات'),
            DropdownButtonFormField<Product>(
              decoration: _inputDecoration('اختر المنتج', Icons.cake),
              value: _selectedProduct,
              items: Product.sampleProducts.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child: Row(
                    children: [
                      Text(product.name),
                      const Spacer(),
                      Text('${product.price} ريال'),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('الكمية: '),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('إضافة للطلب'),
              ),
            ),
            const SizedBox(height: 16),

            // قائمة المنتجات المضافة
            if (_items.isNotEmpty) ...[
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(item.productName),
                    subtitle: Text('الكمية: ${item.quantity} × ${item.unitPrice} ريال'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${item.totalPrice} ريال'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // المرفقات
            _buildSectionTitle('المرفقات'),
            ElevatedButton.icon(
              onPressed: _pickAttachment,
              icon: const Icon(Icons.attach_file),
              label: const Text('إرفاق صور أو ملفات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (_attachments.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _attachments.map((url) {
                  return Chip(
                    label: Text(url.split('/').last),
                    onDeleted: () {
                      setState(() {
                        _attachments.remove(url);
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // المجموع
            if (_items.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المجموع:', style: TextStyle(fontSize: 18)),
                    Text(
                      '${_totalAmount.toStringAsFixed(2)} ريال',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // زر الإرسال
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'حفظ الطلب',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
