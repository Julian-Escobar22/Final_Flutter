import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:todo/presentation/bindings/auth_bindings.dart';
import 'package:todo/presentation/bindings/note_bindings.dart'; 
import 'package:todo/presentation/middlewares/auth_middleware.dart';

import 'package:todo/presentation/pages/home/landing_page.dart';
import 'package:todo/presentation/pages/home/home_shell.dart';
import 'package:todo/presentation/pages/auth/login_page.dart';
import 'package:todo/presentation/pages/auth/register_page.dart';
import 'package:todo/presentation/pages/auth/reset_password_page.dart';
import 'package:todo/presentation/bindings/quiz_bindings.dart'; 

class AppRoutes {
  static const landing = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const reset = '/reset';

  static final pages = <GetPage>[
    // Público
    GetPage(name: landing, page: () => const LandingPage()),
    GetPage(name: reset, page: () => const ResetPasswordPage()), 
    
    // Autenticado
    GetPage(
      name: home,
      page: () => const HomeShell(),
      bindings: [
        AuthBindings(),
        NoteBindings(),
        QuizBindings(), 
      ],
      middlewares: [AuthMiddleware()],
    ),

    // Auth
    GetPage(
      name: login,
      page: () => const LoginPage(),
      bindings: [AuthBindings()],
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      bindings: [AuthBindings()],
      middlewares: [AuthMiddleware()],
    ),
  ];

  static final unknownRoute = GetPage(
    name: '/404',
    page: () => const _NotFoundPage(),
  );
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Ruta no encontrada')));
  }
}
