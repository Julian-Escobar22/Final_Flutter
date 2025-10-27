import 'package:flutter/material.dart';
import 'package:todo/presentation/pages/modules/widgets.dart';
class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SectionScaffold(
      title: 'Generador de cuestionarios',
      subtitle: 'Crea tests a partir de tus apuntes o archivos.',
      children: const [
        TileCard(title: 'Nuevo cuestionario', icon: Icons.quiz_outlined),
        TileCard(title: 'Banco de preguntas', icon: Icons.library_books_outlined),
        TileCard(title: 'Resultados / intento', icon: Icons.assessment_outlined),
      ],
      footer: Text(
        'Próximamente: niveles de dificultad, temporizador, exportación.',
        style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
