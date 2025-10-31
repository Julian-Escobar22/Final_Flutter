import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:todo/core/services/file_service.dart';
import 'package:todo/domain/entities/note_entity.dart';
import 'package:todo/domain/usecases/create_note_usecase.dart';
import 'package:todo/domain/usecases/delete_note_usecase.dart';
import 'package:todo/domain/usecases/get_notes_usecase.dart';
import 'package:todo/presentation/controllers/history_controller.dart'; 

class NoteController extends GetxController {
  final GetNotesUseCase getNotes;
  final CreateNoteUseCase createNote;
  final DeleteNoteUseCase deleteNote;
  final FileService fileService;

  NoteController({
    required this.getNotes,
    required this.createNote,
    required this.deleteNote,
    required this.fileService,
  });

  final RxList<NoteEntity> notes = <NoteEntity>[].obs;
  final RxBool loading = false.obs;
  final RxString searchQuery = ''.obs;

  List<NoteEntity> get filteredNotes {
    if (searchQuery.isEmpty) return notes;
    final q = searchQuery.value.toLowerCase();
    return notes.where((n) {
      return n.title.toLowerCase().contains(q) ||
          (n.subject?.toLowerCase().contains(q) ?? false) ||
          n.rawText.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  Future<void> loadNotes() async {
    loading.value = true;
    try {
      final result = await getNotes();
      notes.value = result;
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<NoteEntity?> addNote({
    required String title,
    String? subject,
    required String rawText,
    Uint8List? imageBytes,
  }) async {
    loading.value = true;
    try {
      String? fileUrl;
      if (imageBytes != null) {
        fileUrl = await fileService.uploadFile(imageBytes, 'jpg');
      }

      final note = await createNote(
        title: title,
        subject: subject,
        rawText: rawText,
        fileUrl: fileUrl,
      );

      notes.insert(0, note);
      
      
      if (Get.isRegistered<HistoryController>()) {
        await Get.find<HistoryController>().loadData();
      }
      
      return note;
    } catch (e) {
      debugPrint('Error creating note: $e');
      return null;
    } finally {
      loading.value = false;
    }
  }

  Future<void> removeNote(String noteId) async {
    try {
      await deleteNote(noteId);
      notes.removeWhere((n) => n.id == noteId);
      
      
      if (Get.isRegistered<HistoryController>()) {
        await Get.find<HistoryController>().loadData();
      }
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }
}
