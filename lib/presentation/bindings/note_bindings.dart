import 'package:get/get.dart';
import 'package:todo/data/datasources/remote/note_remote_ds.dart';
import 'package:todo/data/repositories/note_repository_impl.dart';
import 'package:todo/domain/repositories/note_repository.dart';
import 'package:todo/domain/usecases/create_note_usecase.dart';
import 'package:todo/domain/usecases/get_notes_usecase.dart';
import 'package:todo/domain/usecases/delete_note_usecase.dart';
import 'package:todo/presentation/controllers/note_controller.dart';
import 'package:todo/core/services/file_service.dart';

class NoteBindings extends Bindings {
  @override
  void dependencies() {
    // DataSource
    Get.lazyPut<NoteRemoteDs>(
      () => NoteRemoteDs(),
      fenix: true,
    );

    // Repository
    Get.lazyPut<NoteRepository>(
      () => NoteRepositoryImpl(Get.find<NoteRemoteDs>()),
      fenix: true,
    );

    // UseCases
    Get.lazyPut(() => GetNotesUseCase(Get.find<NoteRepository>()), fenix: true);
    Get.lazyPut(() => CreateNoteUseCase(Get.find<NoteRepository>()), fenix: true);
    Get.lazyPut(() => DeleteNoteUseCase(Get.find<NoteRepository>()), fenix: true);

    // Service
    Get.lazyPut(() => FileService(), fenix: true);

    // Controller
    if (!Get.isRegistered<NoteController>()) {
      Get.put(
        NoteController(
          getNotes: Get.find<GetNotesUseCase>(),
          createNote: Get.find<CreateNoteUseCase>(),
          deleteNote: Get.find<DeleteNoteUseCase>(),
          fileService: Get.find<FileService>(),
        ),
        permanent: true,
      );
    }
  }
}
