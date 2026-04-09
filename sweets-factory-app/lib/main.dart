import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/erp_next_service.dart';
import 'core/models/order.dart';
import 'core/models/product.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SweetsFactoryApp());
}

class SweetsFactoryApp extends StatelessWidget {
  const SweetsFactoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ERPNextService()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'مصنع الحلويات',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE91E63),
          ),
          useMaterial3: true,
          fontFamily: 'Cairo',
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
