import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/presentation/controllers/auth_controller.dart';
import 'package:todo/presentation/widgets/app_footer.dart';
import 'package:todo/presentation/widgets/particle_background.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final theme = Theme.of(context);
    final email = auth.user.value?.email ?? 'usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyAI'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await auth.signOut();
              Get.offAllNamed('/'); // back to landing
            },
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const ParticleBackground(
            count: 60, alpha: 0.12, speed: 0.1, sizeMin: 1, sizeMax: 3),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded,
                              size: 64, color: theme.colorScheme.primary),
                          const SizedBox(height: 12),
                          Text('¡Hola, $email!',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text(
                            'Bienvenido a tu panel. Aquí añadiremos Notas, Escáner, Quiz y Chat.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const AppFooter(),
            ],
          ),
        ],
      ),
    );
  }
}
