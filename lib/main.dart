import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/core/constants/app_colors.dart';
import 'package:todo/presentation/routes.dart';
import 'package:todo/presentation/bindings/auth_bindings.dart';
import 'package:todo/core/services/ai_service.dart';
import 'package:todo/core/services/file_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();
  runApp(const MyApp());
}

// Inicialización separada y síncrona
Future<void> initializeApp() async {
  try {
    await dotenv.load(fileName: ".env");

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );

    // Registrar servicios externos/singletons después de Supabase
    final groqKey = dotenv.env['GROQ_API_KEY'] ?? '';
    final groqBase = dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1';
    Get.put(AiService(apiKey: groqKey, baseUrl: groqBase), permanent: true);
    Get.put(FileService(), permanent: true); // 👈 SIN argumentos

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        Get.offAllNamed('/reset');
      }
    });
  } catch (e) {
    debugPrint('Error initializing app: $e');
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
