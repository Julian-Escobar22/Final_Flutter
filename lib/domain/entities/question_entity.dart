enum QuestionType {
  multipleChoice,
  trueFalse,
  fillBlank,
}

class QuestionEntity {
  final String id;
  final String quizId;
  final QuestionType type;
  final String question;
  final List<String> options; // Para multiple choice
  final String correctAnswer;
  final String? explanation;
  final String? difficulty;

  QuestionEntity({
    required this.id,
    required this.quizId,
    required this.type,
    required this.question,
    this.options = const [],
    required this.correctAnswer,
    this.explanation,
    this.difficulty,
  });

  factory QuestionEntity.fromJson(Map<String, dynamic> json) {
    return QuestionEntity(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String? ?? '',
      type: _parseQuestionType(json['type'] as String?),
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.cast<String>() ?? [],
      correctAnswer: json['answer'] as String? ?? '',
      explanation: json['explanation'] as String?,
      difficulty: json['difficulty'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'type': _questionTypeToString(type),
      'question': question,
      'options': options,
      'answer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
    };
  }

  static QuestionType _parseQuestionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'fill_blank':
        return QuestionType.fillBlank;
      default:
        return QuestionType.multipleChoice;
    }
  }

  static String _questionTypeToString(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'multiple_choice';
      case QuestionType.trueFalse:
        return 'true_false';
      case QuestionType.fillBlank:
        return 'fill_blank';
    }
  }
}
