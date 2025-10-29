import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/presentation/controllers/quiz_controller.dart';
import 'package:todo/presentation/controllers/note_controller.dart';
import 'package:todo/domain/entities/note_entity.dart';

class GenerateQuizDialog extends StatefulWidget {
  final NoteController noteController;

  const GenerateQuizDialog({super.key, required this.noteController});

  @override
  State<GenerateQuizDialog> createState() => _GenerateQuizDialogState();
}

class _GenerateQuizDialogState extends State<GenerateQuizDialog> {
  NoteEntity? selectedNote;
  int questionCount = 5;
  String difficulty = 'medium';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizController>();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? double.infinity : 500, // 👈 Responsive
          maxHeight:
              MediaQuery.of(context).size.height * 0.9, // 👈 Evita overflow
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          // 👈 Scroll en móviles
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Generar Cuestionario',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Selector de nota
              Text(
                'Selecciona una nota',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Obx(() {
                final notes = widget.noteController.notes;
                if (notes.isEmpty) {
                  return const Text('No hay notas disponibles');
                }

                return DropdownButtonFormField<NoteEntity>(
                  value: selectedNote,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Elige una nota...',
                  ),
                  items: notes.map((note) {
                    return DropdownMenuItem(
                      value: note,
                      child: Text(note.title, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (note) {
                    setState(() => selectedNote = note);
                  },
                );
              }),
              const SizedBox(height: 20),

              // Cantidad de preguntas
              Text(
                'Cantidad de preguntas: $questionCount',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: questionCount.toDouble(),
                min: 3,
                max: 15,
                divisions: 12,
                label: questionCount.toString(),
                onChanged: (value) {
                  setState(() => questionCount = value.toInt());
                },
              ),
              const SizedBox(height: 12),

              // Dificultad
              Text('Dificultad', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'easy',
                    label: Text('Fácil'),
                    icon: Icon(Icons.sentiment_satisfied),
                  ),
                  ButtonSegment(
                    value: 'medium',
                    label: Text('Media'),
                    icon: Icon(Icons.sentiment_neutral),
                  ),
                  ButtonSegment(
                    value: 'hard',
                    label: Text('Difícil'),
                    icon: Icon(Icons.sentiment_dissatisfied),
                  ),
                ],
                selected: {difficulty},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => difficulty = newSelection.first);
                },
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => FilledButton.icon(
                      onPressed:
                          controller.generating.value || selectedNote == null
                          ? null
                          : () => _generateQuiz(controller),
                      icon: controller.generating.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        controller.generating.value
                            ? 'Generando...'
                            : 'Generar',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateQuiz(QuizController controller) async {
    if (selectedNote == null) return;

    final quiz = await controller.createQuizFromNote(
      noteId: selectedNote!.id,
      noteText: selectedNote!.rawText,
      questionCount: questionCount,
      difficulty: difficulty,
    );

    if (quiz != null && mounted) {
      Navigator.pop(context);
    }
  }
}
