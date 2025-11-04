class DocumentEntity {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final String fileType; // 'image' o 'pdf'
  final String? extractedText;
  final bool processed;
  final DateTime uploadedAt;

  DocumentEntity({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.extractedText,
    required this.processed,
    required this.uploadedAt,
  });

  factory DocumentEntity.fromJson(Map<String, dynamic> json) {
    return DocumentEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      extractedText: json['extracted_text'] as String?,
      processed: json['processed'] as bool,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'extracted_text': extractedText,
      'processed': processed,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
