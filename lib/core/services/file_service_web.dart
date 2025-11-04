import 'dart:async'; 
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'file_service_base.dart';

class FileService extends FileServiceBase {
  SupabaseClient get client => Supabase.instance.client;
  
  final String _bucket = 'notes-files';

  FileService();

  @override
  Future<Uint8List?> pickImage() async {
    throw UnimplementedError(
      'pickImage() no está disponible en Web. Usa pickAnyFile() en su lugar.',
    );
  }

  @override
  Future<(Uint8List?, String?)> pickAnyFile() async {
    try {
     
      final input = html.FileUploadInputElement();
      input.accept = 'image/*,.pdf';
      input.click();

      // Esperar a que el usuario seleccione un archivo
      final completer = Completer<(Uint8List?, String?)>(); 
      
      input.onChange.listen((event) async {
        final files = input.files;
        if (files == null || files.isEmpty) {
          completer.complete((null, null));
          return;
        }

        final file = files.first;
        final reader = html.FileReader();
        
        reader.onLoad.listen((_) {
          final result = reader.result as List<int>;
          final bytes = Uint8List.fromList(result);
          final extension = file.name.split('.').last.toLowerCase();
          completer.complete((bytes, extension));
        });

        reader.readAsArrayBuffer(file);
      });

      return completer.future;
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
