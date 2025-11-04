import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/domain/entities/document_entity.dart';

class DocumentRemoteDs {
  SupabaseClient get client => Supabase.instance.client;

  DocumentRemoteDs();

  /// Obtener todos los documentos del usuario
  Future<List<DocumentEntity>> getDocuments() async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final res = await client
        .from('documents')
        .select()
        .eq('user_id', user.id)
        .order('uploaded_at', ascending: false);

    return (res as List).map((e) => DocumentEntity.fromJson(e)).toList();
  }

  /// Crear registro de documento
  Future<DocumentEntity> createDocument({
    required String fileName,
    required String fileUrl,
    required String fileType,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final data = {
      'user_id': user.id,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'processed': false,
      'uploaded_at': DateTime.now().toIso8601String(),
    };

    final res = await client.from('documents').insert(data).select().single();
    return DocumentEntity.fromJson(res);
  }

  /// Actualizar documento con texto extraído
  Future<DocumentEntity> updateDocument(
    String documentId,
    String extractedText,
  ) async {
    final res = await client
        .from('documents')
        .update({
          'extracted_text': extractedText,
          'processed': true,
        })
        .eq('id', documentId)
        .select()
        .single();

    return DocumentEntity.fromJson(res);
  }

  /// Eliminar documento
  Future<void> deleteDocument(String documentId) async {
    await client.from('documents').delete().eq('id', documentId);
  }
}
