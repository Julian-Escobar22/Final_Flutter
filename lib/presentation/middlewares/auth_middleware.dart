// lib/presentation/middlewares/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:todo/presentation/routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final supabase = Supabase.instance.client;
    final hasSession = supabase.auth.currentSession != null;

    // Rutas públicas
    final public = {
      AppRoutes.landing,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.reset
    };

    // Si no hay sesión y la ruta NO es pública
    if (!hasSession && !public.contains(route)) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // Si hay sesión y está intentando ir a login/register
    if (hasSession && (route == AppRoutes.login || route == AppRoutes.register)) {
      return const RouteSettings(name: AppRoutes.home);
    }

    return null; // Permite continuar
  }
}
