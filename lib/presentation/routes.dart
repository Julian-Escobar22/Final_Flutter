import 'package:get/get.dart';
import 'package:todo/presentation/pages/home/landing_page.dart';

// (placeholder) cuando hagamos Login de verdad, apunta aquí
import 'package:flutter/material.dart';
class _LoginPlaceholder extends StatelessWidget {
  const _LoginPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Login (pendiente)')),
  );
}

class AppRoutes {
  static const landing = '/';
  static const login = '/login';
  static List<GetPage<dynamic>> pages = [
    GetPage(name: landing, page: () => const LandingPage()),
    GetPage(name: login, page: () => const _LoginPlaceholder(key: ValueKey('login_placeholder'))),
  ];
}
