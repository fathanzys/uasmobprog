import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uas/main.dart';
import 'package:uas/providers/auth_provider.dart';
import 'package:uas/providers/event_provider.dart';

void main() {
  testWidgets('Login screen shows correctly after splash screen', (WidgetTester tester) async {
    // Bangun aplikasi kita, lengkap dengan semua provider yang dibutuhkan.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Tunggu hingga semua frame dan animasi (seperti splash screen) selesai.
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verifikasi bahwa widget-widget penting di halaman login sudah muncul.
    expect(find.text('Selamat Datang di HackVerse'), findsOneWidget);

    // REVISI: Menggunakan label teks yang benar sesuai dengan UI.
    expect(find.widgetWithText(TextFormField, 'Nomor Mahasiswa'), findsOneWidget);

    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'LOGIN'), findsOneWidget);
  });
}
