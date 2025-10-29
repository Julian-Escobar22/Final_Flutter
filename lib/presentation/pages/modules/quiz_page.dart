import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/presentation/controllers/quiz_controller.dart';
import 'package:todo/presentation/controllers/note_controller.dart';
import 'package:todo/presentation/pages/modules/quiz_solver_page.dart';
import 'package:todo/presentation/widgets/generate_quiz_dialog.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizController>();
    final noteController = Get.find<NoteController>();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cuestionarios',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Genera quizzes automáticos desde tus notas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.quizzes.isEmpty) {
                return _buildEmptyState(context, noteController);
              }

              return RefreshIndicator(
                onRefresh: controller.loadQuizzes,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = controller.quizzes[index];
                    return _QuizCard(quiz: quiz);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateDialog(context, noteController),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Quiz'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, NoteController noteController) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay cuestionarios',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Genera tu primer quiz desde una nota para comenzar a estudiar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showGenerateDialog(context, noteController),
              icon: const Icon(Icons.add),
              label: const Text('Crear Cuestionario'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenerateDialog(BuildContext context, NoteController noteController) {
    showDialog(
      context: context,
      builder: (context) => GenerateQuizDialog(noteController: noteController),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final dynamic quiz;

  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Get.to(
            () => QuizSolverPage(quizId: quiz.id),
            transition: Transition.rightToLeft,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.quiz,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${quiz.totalQuestions} preguntas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                    if (quiz.lastScore != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Último intento: ${quiz.scoreText}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Botón eliminar
              IconButton(
                onPressed: () => _confirmDelete(context, controller, quiz.id),
                icon: const Icon(Icons.delete_outline),
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, QuizController controller, String quizId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuestionario'),
        content: const Text('¿Estás seguro de eliminar este cuestionario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              controller.removeQuiz(quizId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
