// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sweets_factory_app/main.dart';
import 'package:provider/provider.dart';
import 'package:sweets_factory_app/core/api/erp_next_service.dart';
import 'package:sweets_factory_app/core/models/order.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ERPNextService()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
        ],
        child: const MaterialApp(
          home: SweetsFactoryApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify app title
    expect(find.text('مصنع الحلويات'), findsOneWidget);
  });
}
