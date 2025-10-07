import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/core/constants/app_colors.dart';
import 'package:todo/core/config/supabase_config.dart';
import 'package:todo/presentation/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await SupabaseConfig.initialize();
    runApp(const MyApp());
  } catch (e) {
    // If Supabase initialization fails, show error and run app anyway
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
      initialRoute: AppRoutes.landing,   // 👈 arranca en el landing
      getPages: AppRoutes.pages,         // 👈 rutas definidas
      unknownRoute: AppRoutes.unknownRoute, // opcional
      debugShowCheckedModeBanner: false,
    );
  }
}
