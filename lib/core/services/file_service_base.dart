import 'dart:typed_data';

abstract class FileServiceBase {
  Future<Uint8List?> pickImage();
  Future<(Uint8List?, String?)> pickAnyFile();
  String getFileType(String extension);
  Future<String> uploadFile(Uint8List bytes, String extension);
  Future<void> deleteFile(String fileUrl);
}
