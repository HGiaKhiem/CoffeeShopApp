import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coffee_shop_app/ui/screens/login_screen.dart';
import 'package:flutter_coffee_shop_app/ui/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_preview_screenshot/device_preview_screenshot.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_coffee_shop_app/ui/screens/screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://rubeafovywlrgxblfmlr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1YmVhZm92eXdscmd4YmxmbWxyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2MjQ2ODMsImV4cCI6MjA3NDIwMDY4M30.AazzK3wmpprjV4zAylyX9wKG5tMASYBugPOGrehsCTQ',
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
      builder: (context) => const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior()
          .copyWith(dragDevices: {PointerDeviceKind.mouse}),
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(useMaterial3: false),
      home: const LoginScreen(),
    );
  }
}
