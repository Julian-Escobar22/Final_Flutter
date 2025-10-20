// lib/presentation/middlewares/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/presentation/controllers/auth_controller.dart';
import 'package:todo/presentation/routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;
    final logged = auth?.isLoggedIn ?? false;

    // rutas públicas
    final public = {AppRoutes.landing, AppRoutes.login, AppRoutes.register, AppRoutes.reset};

    if (!logged && !public.contains(route)) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (logged && (route == AppRoutes.login || route == AppRoutes.register)) {
      return const RouteSettings(name: AppRoutes.home);
    }
    return null; // permite continuar
  }
}
