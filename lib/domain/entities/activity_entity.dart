enum ActivityType {
  noteCreated,
  noteEdited,
  quizGenerated,
  quizCompleted,
}

class ActivityEntity {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String? description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ActivityEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    required this.timestamp,
    this.metadata,
  });

  factory ActivityEntity.fromJson(Map<String, dynamic> json) {
    return ActivityEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseActivityType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static ActivityType _parseActivityType(String? type) {
    switch (type) {
      case 'note_created':
        return ActivityType.noteCreated;
      case 'note_edited':
        return ActivityType.noteEdited;
      case 'quiz_generated':
        return ActivityType.quizGenerated;
      case 'quiz_completed':
        return ActivityType.quizCompleted;
      default:
        return ActivityType.noteCreated;
    }
  }

  String get typeLabel {
    switch (type) {
      case ActivityType.noteCreated:
        return 'Nota creada';
      case ActivityType.noteEdited:
        return 'Nota editada';
      case ActivityType.quizGenerated:
        return 'Quiz generado';
      case ActivityType.quizCompleted:
        return 'Quiz completado';
    }
  }
}
