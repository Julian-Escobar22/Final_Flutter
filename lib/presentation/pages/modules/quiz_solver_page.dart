import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/domain/entities/question_entity.dart';
import 'package:todo/domain/entities/quiz_entity.dart';
import 'package:todo/presentation/controllers/quiz_controller.dart';

class QuizSolverPage extends StatefulWidget {
  final String quizId;

  const QuizSolverPage({super.key, required this.quizId});

  @override
  State<QuizSolverPage> createState() => _QuizSolverPageState();
}

class _QuizSolverPageState extends State<QuizSolverPage> {
  int currentQuestionIndex = 0;
  Map<int, String> userAnswers = {};
  bool showResults = false;

  QuizEntity? get quiz {
    final controller = Get.find<QuizController>();
    return controller.getQuizById(widget.quizId);
  }

  @override
  Widget build(BuildContext context) {
    if (quiz == null || quiz!.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz no encontrado')),
        body: const Center(child: Text('No se pudo cargar el cuestionario')),
      );
    }

    if (showResults) {
      return _buildResultsPage();
    }

    return _buildQuizPage();
  }

  Widget _buildQuizPage() {
    final question = quiz!.questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / quiz!.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pregunta ${currentQuestionIndex + 1} de ${quiz!.questions.length}',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de pregunta badge
                    _buildQuestionTypeBadge(question.type),
                    const SizedBox(height: 16),

                    // Pregunta
                    Text(
                      question.question,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),

                    // Opciones según tipo
                    _buildQuestionOptions(question),
                  ],
                ),
              ),
            ),

            // Botones de navegación
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTypeBadge(QuestionType type) {
    IconData icon;
    String label;
    Color color;

    switch (type) {
      case QuestionType.multipleChoice:
        icon = Icons.radio_button_checked;
        label = 'Opción múltiple';
        color = Colors.blue;
        break;
      case QuestionType.trueFalse:
        icon = Icons.check_box;
        label = 'Verdadero/Falso';
        color = Colors.green;
        break;
      case QuestionType.fillBlank:
        icon = Icons.edit;
        label = 'Completar';
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionOptions(QuestionEntity question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        return Column(
          children: question.options.map((option) {
            final isSelected = userAnswers[currentQuestionIndex] == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    userAnswers[currentQuestionIndex] = option;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );

      case QuestionType.fillBlank:
        return TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Escribe tu respuesta...',
          ),
          onChanged: (value) {
            userAnswers[currentQuestionIndex] = value;
          },
          controller: TextEditingController(
            text: userAnswers[currentQuestionIndex] ?? '',
          ),
        );
    }
  }

  Widget _buildNavigationButtons() {
    final isLastQuestion = currentQuestionIndex == quiz!.questions.length - 1;
    final hasAnswer = userAnswers.containsKey(currentQuestionIndex);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => currentQuestionIndex--);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
              ),
            ),
          if (currentQuestionIndex > 0) const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: hasAnswer
                  ? () {
                      if (isLastQuestion) {
                        _finishQuiz();
                      } else {
                        setState(() => currentQuestionIndex++);
                      }
                    }
                  : null,
              icon: Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
              label: Text(isLastQuestion ? 'Finalizar' : 'Siguiente'),
            ),
          ),
        ],
      ),
    );
  }

  void _finishQuiz() {
    setState(() => showResults = true);
  }

  Widget _buildResultsPage() {
    int correctAnswers = 0;

    for (int i = 0; i < quiz!.questions.length; i++) {
      final question = quiz!.questions[i];
      final userAnswer = userAnswers[i] ?? '';

      if (_isAnswerCorrect(userAnswer, question.correctAnswer, question.type)) {
        correctAnswers++;
      }
    }

    final percentage = (correctAnswers / quiz!.questions.length * 100).round();
    final passed = percentage >= 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: passed
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: passed ? Colors.green : Colors.orange,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.celebration : Icons.emoji_events_outlined,
                    size: 64,
                    color: passed ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    passed ? '¡Excelente!' : '¡Sigue practicando!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correctAnswers de ${quiz!.questions.length} correctas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: passed ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Detalle de respuestas
            ...List.generate(quiz!.questions.length, (index) {
              return _buildAnswerReview(index);
            }),

            const SizedBox(height: 32),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex = 0;
                        userAnswers.clear();
                        showResults = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerReview(int index) {
    final question = quiz!.questions[index];
    final userAnswer = userAnswers[index] ?? 'Sin respuesta';
    final isCorrect = _isAnswerCorrect(
      userAnswer,
      question.correctAnswer,
      question.type,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pregunta ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(question.question),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Tu respuesta: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Expanded(
                  child: Text(
                    userAnswer,
                    style: TextStyle(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Respuesta correcta: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Expanded(
                    child: Text(
                      question.correctAnswer,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (question.explanation != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(question.explanation!)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isAnswerCorrect(
    String userAnswer,
    String correctAnswer,
    QuestionType type,
  ) {
    // Normaliza ambas respuestas
    final userNormalized = userAnswer.trim().toLowerCase();
    final correctNormalized = correctAnswer.trim().toLowerCase();

    if (type == QuestionType.fillBlank) {
      // Para completar espacios, acepta si contiene la palabra clave
      return userNormalized.contains(correctNormalized) ||
          correctNormalized.contains(userNormalized);
    }

    // Para opción múltiple y V/F, compara exactamente
    return userNormalized == correctNormalized;
  }
}
