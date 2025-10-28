// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo/core/constants/app_colors.dart';
import 'package:todo/core/config/supabase_config.dart';
import 'package:todo/presentation/routes.dart';
import 'package:todo/presentation/bindings/auth_bindings.dart';
import 'package:todo/core/services/ai_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1) Cargar .env (si falla en web, lo ignoramos para no romper).
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}

    // 2) Inicializar Supabase (tu SupabaseConfig.initialize() debe hacer await Supabase.initialize(...))
    await SupabaseConfig.initialize();

    // 3) Registrar servicio de IA con claves desde .env (o valores por defecto)
    final groqKey  = dotenv.env['GROQ_API_KEY'] ?? '';
    final groqBase = dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1';
    Get.put(AiService(apiKey: groqKey, baseUrl: groqBase), permanent: true);

    // 4) Enlaces mágicos (password recovery/confirm) – para web y mobile
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // En web normalmente llega con el query param, en mobile viene vía deep link
        Get.offAllNamed('/reset');
      }
    });

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
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
      initialBinding: AuthBindings(), // registra controladores al inicio
      debugShowCheckedModeBanner: false,
    );
  }
}
