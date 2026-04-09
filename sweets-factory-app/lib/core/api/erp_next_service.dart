import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ERPNextService extends ChangeNotifier {
  // إعدادات الاتصال - يجب تعديلها حسب بيئة ERPNext
  String get _baseUrl => 'https://your-erpnext.com';
  String _apiKey = '';
  String _apiSecret = '';
  String? _sessionCookie;

  bool _isLoading = false;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  // تسجيل الدخول
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/method/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usr': username,
          'pwd': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessionCookie = response.headers['set-cookie'];
        _isLoggedIn = true;

        // حفظ البيانات محلياً
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('session_cookie', _sessionCookie ?? '');

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    _isLoggedIn = false;
    notifyListeners();
    return false;
  }

  // التحقق من الجلسة المحفوظة
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie');
    if (sessionCookie != null) {
      _sessionCookie = sessionCookie;
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _sessionCookie = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // إنشاء طلب مبيعات جديد (Sales Order)
  Future<bool> createSalesOrder(Map<String, dynamic> orderData) async {
    if (!_isLoggedIn) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/resource/Sales Order'),
        headers: {
          'Content-Type': 'application/json',
          if (_sessionCookie != null) 'Cookie': _sessionCookie!,
        },
        body: jsonEncode(orderData),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Create Sales Order error: $e');
      return false;
    }
  }

  // جلب الطلبات
  Future<List<Map<String, dynamic>>> getSalesOrders({
    String? status,
    int limit = 20,
  }) async {
    if (!_isLoggedIn) return [];

    try {
      String url = '$_baseUrl/api/resource/Sales Order?limit=$limit';
      if (status != null) {
        url += '&filters=[["status","=","$status"]]';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (_sessionCookie != null) 'Cookie': _sessionCookie!,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Get Sales Orders error: $e');
    }

    return [];
  }

  // تحديث حالة الطلب
  Future<bool> updateSalesOrderStatus(
    String orderId,
    String status,
  ) async {
    if (!_isLoggedIn) return false;

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/resource/Sales Order/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          if (_sessionCookie != null) 'Cookie': _sessionCookie!,
        },
        body: jsonEncode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update status error: $e');
      return false;
    }
  }

  // رفع ملف (للمرفقات - صور، مستندات)
  Future<String?> uploadFile(String filePath) async {
    if (!_isLoggedIn) return null;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/method/upload_file'),
      );

      request.headers.addAll({
        if (_sessionCookie != null) 'Cookie': _sessionCookie!,
      });

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        return data['message']['file_url'];
      }
    } catch (e) {
      debugPrint('Upload file error: $e');
    }

    return null;
  }

  // إنشاء سند قبض (Payment Entry)
  Future<bool> createPaymentEntry(Map<String, dynamic> paymentData) async {
    if (!_isLoggedIn) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/resource/Payment Entry'),
        headers: {
          'Content-Type': 'application/json',
          if (_sessionCookie != null) 'Cookie': _sessionCookie!,
        },
        body: jsonEncode(paymentData),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Create Payment Entry error: $e');
      return false;
    }
  }

  // جلب المنتجات
  Future<List<Map<String, dynamic>>> getProducts() async {
    if (!_isLoggedIn) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/resource/Item?fields=["name","item_name","item_group","standard_rate","image","custom_preparation_time"]&limit_page_length=100'),
        headers: {
          'Content-Type': 'application/json',
          if (_sessionCookie != null) 'Cookie': _sessionCookie!,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Get Products error: $e');
    }

    return [];
  }
}
