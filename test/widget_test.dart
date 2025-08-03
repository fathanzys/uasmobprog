import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uas/main.dart';
import 'package:uas/providers/auth_provider.dart';
import 'package:uas/providers/event_provider.dart';

void main() {
  testWidgets('Login screen shows correctly after splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('Selamat Datang di HackVerse'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'NIM'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'LOGIN'), findsOneWidget);
  });
}
