class NoteEntity {
  final String id;
  final String userId;
  final String title;
  final String? subject;
  final String rawText;
  final String? cleanText;
  final String? summary;
  final List<String> tags;
  final String? fileUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.subject,
    required this.rawText,
    this.cleanText,
    this.summary,
    this.tags = const [],
    this.fileUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteEntity.fromJson(Map<String, dynamic> json) {
    return NoteEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? 'Sin título',
      subject: json['subject'] as String?,
      rawText: json['raw_text'] as String? ?? '',
      cleanText: json['clean_text'] as String?,
      summary: json['summary'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      fileUrl: json['file_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'subject': subject,
      'raw_text': rawText,
      'clean_text': cleanText,
      'summary': summary,
      'tags': tags,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayText => cleanText ?? rawText;
  String get displaySubject => subject ?? 'Sin materia';
}
