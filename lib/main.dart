// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/core/constants/app_colors.dart';
import 'package:todo/core/config/supabase_config.dart';
import 'package:todo/presentation/routes.dart';
import 'package:todo/presentation/bindings/auth_bindings.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👈 necesario

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseConfig.initialize();

    // 👇 Captura enlaces mágicos / recuperación / confirmación
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // Redirige al formulario de reset
        Get.offAllNamed('/reset');
      }
    });

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'StudyAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryPurple),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      initialRoute: AppRoutes.landing,
      getPages: AppRoutes.pages,
      unknownRoute: AppRoutes.unknownRoute,
      initialBinding: AuthBindings(),
      debugShowCheckedModeBanner: false,
    );
  }
}
