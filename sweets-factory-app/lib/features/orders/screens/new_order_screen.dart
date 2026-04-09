import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/product.dart';
import '../../../core/models/order.dart';
import '../../../core/api/erp_next_service.dart';
import '../../../shared/themes/app_colors.dart';

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: AppColors.background,
                surface: AppColors.surface,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
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
        SnackBar(
          content: const Text('يرجى ملء جميع الحقول وإضافة منتج واحد على الأقل'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final erpService = context.read<ERPNextService>();

    final orderData = {
      'customer': 'CUST-001',
      'customer_name': _customerNameController.text,
      'customer_phone': _customerPhoneController.text,
      'delivery_date': _deliveryDate?.toIso8601String(),
      'delivery_address': _addressController.text,
      'items': _items.map((item) => item.toJson()).toList(),
      'attachments': _attachments,
    };

    final success = await erpService.createSalesOrder(orderData);

    if (success && mounted) {
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
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.background),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('تم إنشاء الطلب بنجاح'),
                ),
              ],
            ),
            backgroundColor: AppColors.success.withOpacity(0.95),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('فشل إنشاء الطلب. يرجى المحاولة مرة أخرى.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'أمر عمل جديد',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بيانات العميل
            _buildSectionHeader(Icons.person_outline_rounded, 'بيانات العميل'),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _customerNameController,
              label: 'اسم العميل',
              icon: Icons.person_outline_rounded,
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _customerPhoneController,
              label: 'رقم الهاتف',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _addressController,
              label: 'عنوان التوصيل',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 24),

            // وقت التسليم
            _buildSectionHeader(Icons.access_time_rounded, 'وقت التسليم'),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDateTime,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _deliveryDate != null && _deliveryTime != null
                            ? '${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year} - ${_deliveryTime!.hour}:${_deliveryTime!.minute.toString().padLeft(2, '0')}'
                            : 'اختر وقت التسليم',
                        style: TextStyle(
                          fontSize: 16,
                          color: _deliveryDate != null ? AppColors.textPrimary : AppColors.textMuted,
                          fontWeight: _deliveryDate != null ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (_deliveryDate != null)
                      Icon(Icons.check_circle_rounded, color: AppColors.success)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // إضافة المنتجات
            _buildSectionHeader(Icons.cake_outlined, 'المنتجات'),
            const SizedBox(height: 12),
            DropdownButtonFormField<Product>(
              decoration: InputDecoration(
                labelText: 'اختر المنتج',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.cake_outlined, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.backgroundSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              value: _selectedProduct,
              dropdownColor: AppColors.surface,
              items: Product.sampleProducts.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child: Row(
                    children: [
                      Text(product.name, style: const TextStyle(color: AppColors.textPrimary)),
                      const Spacer(),
                      Text('${product.price} ريال', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Text('الكمية:'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    color: AppColors.primary,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => _quantity++),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded),
                    const SizedBox(width: 8),
                    const Text('إضافة للطلب', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // قائمة المنتجات المضافة
            if (_items.isNotEmpty) ...[
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('الكمية: ${item.quantity} × ${item.unitPrice} ريال'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${item.totalPrice} ريال', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: AppColors.error),
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
            _buildSectionHeader(Icons.attach_file_rounded, 'المرفقات'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickAttachment,
              icon: const Icon(Icons.attach_file_rounded),
              label: const Text('إرفاق صور أو ملفات', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_attachments.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _attachments.map((url) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(url.split('/').last, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _attachments.remove(url);
                            });
                          },
                          child: const Icon(Icons.close, size: 16, color: AppColors.error),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // المجموع
            if (_items.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primaryLight.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المجموع:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    Text(
                      '${_totalAmount.toStringAsFixed(2)} ريال',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
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
              child: ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded),
                    const SizedBox(width: 12),
                    const Text('حفظ الطلب', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: validator,
    );
  }
}
