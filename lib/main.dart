import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:device_preview_screenshot/device_preview_screenshot.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // 👈 Quan trọng cho web URL không có #

import 'package:supabase_flutter/supabase_flutter.dart';

// 🔹 Import các màn hình
import 'package:flutter_coffee_shop_app/ui/screens/login_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/register_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/reset_password_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/ban_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/home_screen.dart';

// 🔹 Import controller
import 'package:flutter_coffee_shop_app/controllers/cart_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy(); // 👈 Bỏ hash (#) trong URL (bắt buộc cho Supabase web)
  GestureBinding.instance.resamplingEnabled = true;

  // ✅ Khởi tạo Supabase đúng chuẩn cho Flutter Web
  await Supabase.initialize(
    url: 'https://rubeafovywlrgxblfmlr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1YmVhZm92eXdscmd4YmxmbWxyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2MjQ2ODMsImV4cCI6MjA3NDIwMDY4M30.AazzK3wmpprjV4zAylyX9wKG5tMASYBugPOGrehsCTQ',
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
      detectSessionInUri: true,
    ),
  );

  runApp(
    DevicePreview(
      tools: [
        ...DevicePreview.defaultTools,
        DevicePreviewScreenshot(
          onScreenshot: screenshotAsFiles(Directory('/home/saul/Pictures/')),
        ),
      ],
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartController()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(useMaterial3: false),

      // ✅ Cho phép kéo/scroll bằng chuột, trackpad, cảm ứng
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),

      home: Builder(
        builder: (context) {
          final uri = Uri.base;
          final path = uri.path;
          final type = uri.queryParameters['type'];
          final token = uri.queryParameters['token'];

          // 🟤 Link reset password (email)
          // Supabase sẽ tự detect & exchange code nhờ detectSessionInUrl = true
          if (path == '/reset-password' || type == 'recovery') {
            return ResetPasswordScreen();
          }

          // 🟢 QR Bàn: VD: https://coffeeshop-app-bb920.web.app/ban?token=abc123
          if (path == '/ban' && token != null) {
            return BanScreen(token: token);
          }

          // 🔵 Mặc định: Login
          return const LoginScreen();
        },
      ),
    );
  }
}
