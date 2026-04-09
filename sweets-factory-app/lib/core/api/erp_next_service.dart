import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ERPNextService extends ChangeNotifier {
  // إعدادات الاتصال - تأخذ من AppConfig
  String get _baseUrl => AppConfig.erpBaseUrl;
  String get _apiKey => AppConfig.erpApiKey;
  String get _apiSecret => AppConfig.erpApiSecret;
  bool get _useApiKey => AppConfig.useApiKeyAuth;

  String? _sessionCookie;

  bool _isLoading = false;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  // الحصول على رؤوس المصادقة
  Map<String, String> get _authHeaders {
    if (_useApiKey) {
      return {
        'Authorization': 'token $_apiKey:$_apiSecret',
      };
    } else {
      return {
        if (_sessionCookie != null) 'Cookie': _sessionCookie!,
      };
    }
  }

  // تسجيل الدخول
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useApiKey) {
        // استخدام API Key - لا حاجة لتسجيل الدخول
        _isLoggedIn = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // تسجيل الدخول بالاسم وكلمة المرور
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

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          await prefs.setString('session_cookie', _sessionCookie ?? '');

          _isLoading = false;
          notifyListeners();
          return true;
        }
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
    if (_useApiKey) {
      _isLoggedIn = true;
      notifyListeners();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie');
      if (sessionCookie != null) {
        _sessionCookie = sessionCookie;
        _isLoggedIn = true;
        notifyListeners();
      }
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
          ..._authHeaders,
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
          ..._authHeaders,
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
          ..._authHeaders,
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

      request.headers.addAll(_authHeaders);

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
          ..._authHeaders,
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
          ..._authHeaders,
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
