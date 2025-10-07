import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/presentation/widgets/app_navbar.dart';
import 'package:todo/presentation/widgets/particle_background.dart';
import 'package:todo/presentation/widgets/lottie_header.dart';
import 'package:todo/presentation/widgets/tilt_card.dart';
import 'package:todo/presentation/widgets/app_footer.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final isSmall = w < 700;                  // móvil / pantallas estrechas
        final isLandscapePhone = w > 700 && h < 560; // móvil en horizontal
        final maxContent = isSmall ? w : 1100.0;  // ancho máximo del contenido
        final heroMax = isSmall
            ? 240.0
            : isLandscapePhone
                ? 320.0
                : 420.0;                          // tamaño máximo del Lottie

        return Scaffold(
          extendBodyBehindAppBar: false,
          appBar: const AppNavbar(transparent: false),
          body: Stack(
            children: [
              // Fondo de partículas (más lento)
              const ParticleBackground(
                count: 60,
                alpha: 0.14,
                speed: 0.1,
                sizeMin: 1.0,
                sizeMax: 3.0,
              ),

              // Contenido + footer
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 14 : 20,
                          vertical: isSmall ? 20 : 40,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxContent),
                            child: Column(
                              children: [
                                // Header / Hero
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: isSmall ? 8 : 16,
                                    bottom: isSmall ? 16 : 24,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Tu Asistente Personal de Estudio con IA',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.displaySmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          height: 1.1,
                                          fontSize: isSmall ? 28 : null,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Escanea apuntes, resume, genera quizzes y chatea dudas. Todo en una app offline-first con sync.',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: isSmall ? 14 : null,
                                        ),
                                      ),
                                      const SizedBox(height: 22),
                                      // Lottie hero con tamaño máximo responsivo
                                      LottieHeader(
                                        asset: 'assets/lottie/study.json',
                                        maxWidth: heroMax,
                                      ),
                                    ],
                                  ),
                                ),

                                // Features (fluye por ancho)
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _FeatureCard(
                                      icon: Icons.document_scanner_outlined,
                                      title: 'OCR Offline',
                                      desc: 'Reconoce texto con ML Kit sin gastar datos.',
                                      tiltEnabled: !isSmall,
                                      width: isSmall ? w - 28 : 260,
                                    ),
                                    _FeatureCard(
                                      icon: Icons.quiz_outlined,
                                      title: 'Quizzes automáticos',
                                      desc: 'Preguntas tipo test, V/F y completar.',
                                      tiltEnabled: !isSmall,
                                      width: isSmall ? w - 28 : 260,
                                    ),
                                    _FeatureCard(
                                      icon: Icons.chat_bubble_outline,
                                      title: 'Chat con IA',
                                      desc: 'Explicaciones en lenguaje sencillo.',
                                      tiltEnabled: !isSmall,
                                      width: isSmall ? w - 28 : 260,
                                    ),
                                    _FeatureCard(
                                      icon: Icons.sync_outlined,
                                      title: 'Sync con Supabase',
                                      desc: 'Multi-dispositivo y respaldo seguro.',
                                      tiltEnabled: !isSmall,
                                      width: isSmall ? w - 28 : 260,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // CTA final
                                Card(
                                  elevation: 0,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(isSmall ? 16 : 20),
                                    child: Column(
                                      children: [
                                        Text(
                                          '¿Listo para estudiar mejor?',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Crea tu cuenta y empieza a escanear y practicar en minutos.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            fontSize: isSmall ? 14 : null,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        FilledButton(
                                          onPressed: () => Get.toNamed('/login'),
                                          child: const Text('Crear cuenta'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Footer como sección final
                  const AppFooter(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool tiltEnabled;
  final double width;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
    this.tiltEnabled = true,
    this.width = 260,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width, // ancho responsivo
      child: TiltCard(
        enabled: tiltEnabled,
        maxTilt: 8,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 34, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
