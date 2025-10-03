import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/presentation/widgets/app_navbar.dart';
import 'package:todo/presentation/widgets/particle_background.dart';
import 'package:todo/presentation/widgets/lottie_header.dart';
import 'package:todo/presentation/widgets/tilt_card.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppNavbar(transparent: true),
      body: Stack(
        children: [
          const ParticleBackground(count: 50),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  // Hero / Header
                  Padding(
                    padding: const EdgeInsets.only(top: 60, bottom: 24),
                    child: Column(
                      children: [
                        Text(
                          'Tu Asistente Personal de Estudio con IA',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Escanea apuntes, resume, genera quizzes y chatea dudas. Todo en una app offline-first con sync.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
                          children: [
                            FilledButton.tonal(
                              onPressed: () => Get.toNamed('/login'),
                              child: const Text('Comenzar gratis'),
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Ver demo'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const LottieHeader(asset: 'assets/lottie/study.json'),
                      ],
                    ),
                  ),

                  // Features (tilt cards)
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: const [
                      _FeatureCard(
                        icon: Icons.document_scanner_outlined,
                        title: 'OCR Offline',
                        desc: 'Reconoce texto con ML Kit sin gastar datos.',
                      ),
                      _FeatureCard(
                        icon: Icons.quiz_outlined,
                        title: 'Quizzes automáticos',
                        desc: 'Preguntas tipo test, V/F y completar.',
                      ),
                      _FeatureCard(
                        icon: Icons.chat_bubble_outline,
                        title: 'Chat con IA',
                        desc: 'Explicaciones en lenguaje sencillo.',
                      ),
                      _FeatureCard(
                        icon: Icons.sync_outlined,
                        title: 'Sync con Supabase',
                        desc: 'Multi-dispositivo y respaldo seguro.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),
                  // CTA final
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Listo para estudiar mejor?', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Text(
                            'Crea tu cuenta y empieza a escanear y practicar en minutos.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 14),
                          FilledButton(onPressed: () => Get.toNamed('/login'), child: const Text('Crear cuenta')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 260,
      child: TiltCard(
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
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(desc, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
