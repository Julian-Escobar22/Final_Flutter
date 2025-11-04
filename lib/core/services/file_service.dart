import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class FileService {
  // 👇 Getter lazy para obtener el cliente cuando se necesita
  SupabaseClient get client => Supabase.instance.client;
  
  final ImagePicker _picker = ImagePicker();
  final String _bucket = 'notes-files';

  // 👇 Constructor vacío
  FileService();

  /// Seleccionar imagen desde galería (web y móvil)
  Future<Uint8List?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;
      return await image.readAsBytes();
    } catch (e) {
      throw Exception('Error al seleccionar imagen: $e');
    }
  }

  /// Subir bytes a Supabase Storage
  Future<String> uploadFile(Uint8List bytes, String extension) async {
    final user = client.auth.currentUser; // 👈 Usa client (el getter)
    if (user == null) throw Exception('Usuario no autenticado');

    final fileName = '${user.id}/${const Uuid().v4()}.$extension';

    await client.storage.from(_bucket).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            upsert: false,
            contentType: _getContentType(extension),
          ),
        );

    final publicUrl = client.storage.from(_bucket).getPublicUrl(fileName);
    return publicUrl;
  }

  /// Eliminar archivo de Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      final path = uri.pathSegments.skip(4).join('/');
      await client.storage.from(_bucket).remove([path]);
    } catch (e) {
      // Ignorar si el archivo no existe
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
