import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:todo/presentation/bindings/auth_bindings.dart';

// Pages
import 'package:todo/presentation/pages/home/landing_page.dart';
import 'package:todo/presentation/pages/auth/login_page.dart';
import 'package:todo/presentation/pages/auth/register_page.dart';


class AppRoutes {
  static const landing = '/';
  static const login = '/login';
  static const register = '/register';

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: landing, page: () => const LandingPage()),
    GetPage(name: login, page: () => const LoginPage(), bindings: [AuthBindings()]),
    GetPage(name: register, page: () => const RegisterPage(), bindings: [AuthBindings()]),
  ];

  // (Opcional) Ruta desconocida para evitar pantallas en blanco
  static final unknownRoute = GetPage(
    name: '/404',
    page: () => const _NotFoundPage(),
  );
}


class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Ruta no encontrada')),
    );
  }
}
