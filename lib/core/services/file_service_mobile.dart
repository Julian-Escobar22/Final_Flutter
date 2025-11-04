import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'file_service_base.dart';

class FileService extends FileServiceBase {
  SupabaseClient get client => Supabase.instance.client;
  
  final ImagePicker _picker = ImagePicker();
  final String _bucket = 'notes-files';

  FileService();

  @override
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

  @override
  Future<(Uint8List?, String?)> pickAnyFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return (null, null);

      final file = result.files.first;
      
      // ✅ ARREGLADO: Usa bytes en lugar de xFile
      final bytes = file.bytes;
      if (bytes == null) {
        // Si bytes es null (en iOS a veces), lee desde path
        final path = file.path;
        if (path == null) return (null, null);
        
        // Usa dart:io para leer el archivo
        final ioFile = File(path);
        final fileBytes = await ioFile.readAsBytes();
        final extension = file.extension?.toLowerCase() ?? '';
        return (fileBytes, extension);
      }
      
      final extension = file.extension?.toLowerCase() ?? '';
      return (bytes, extension);
    } catch (e) {
      throw Exception('Error seleccionando archivo: $e');
    }
  }

  @override
  String getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'pdf':
        return 'pdf';
      default:
        return 'unknown';
    }
  }

  @override
  Future<String> uploadFile(Uint8List bytes, String extension) async {
    final user = client.auth.currentUser;
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

  @override
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
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
