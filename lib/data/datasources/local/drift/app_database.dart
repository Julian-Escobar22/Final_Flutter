import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Notes extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get title => text()();
  TextColumn get subject => text().nullable()();
  TextColumn get rawText => text()();        // texto OCR crudo
  TextColumn get cleanText => text().nullable()(); // limpieza/normalización
  TextColumn get summary => text().nullable()();   // resumen IA
  TextColumn get tags => text().withDefault(const Constant('[]'))(); // JSON string
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class NoteChunks extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().references(Notes, #id, onDelete: KeyAction.cascade)();
  IntColumn get order => integer()(); // para mantener secuencia
  TextColumn get textContent => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['UNIQUE(note_id, "order")'];
}

class QuizQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();       // 'mcq' | 'vf' | 'gap'
  TextColumn get difficulty => text()(); // 'easy' | 'medium' | 'hard'
  TextColumn get question => text()();
  TextColumn get options => text().withDefault(const Constant('[]'))(); // JSON string
  TextColumn get answer => text()();     // índice/valor correcto (string/json)
  TextColumn get explanation => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class QuizResults extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().references(Notes, #id, onDelete: KeyAction.setNull).nullable()();
  IntColumn get total => integer()();
  IntColumn get correct => integer()();
  RealColumn get score => real()(); 
  TextColumn get answers => text().withDefault(const Constant('[]'))(); // JSON
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()();    // 'user' | 'assistant'
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Attachments extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get noteId => text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get localPath => text()();           // path local de la imagen/pdf
  TextColumn get mimeType => text().withDefault(const Constant('image/jpeg'))();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('singleton'))();
  BoolColumn get onboardingSeen => boolean().withDefault(const Constant(false))();
  TextColumn get lastUserId => text().nullable()(); // supabase user id
  TextColumn get theme => text().withDefault(const Constant('system'))(); // 'light' | 'dark' | 'system'
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class SyncOps extends Table {
  TextColumn get id => text()(); // uuid de la operación
  TextColumn get entity => text()(); // 'note' | 'note_chunk' | 'quiz_question' | 'attachment' | 'chat_message'
  TextColumn get entityId => text()(); // id del registro afectado
  TextColumn get op => text()(); // 'create' | 'update' | 'delete'
  TextColumn get payload => text().withDefault(const Constant('{}'))(); // JSON con datos para push
  BoolColumn get processed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}



@DriftDatabase(
  tables: [Notes, NoteChunks, QuizQuestions, QuizResults, ChatMessages,
  Attachments, AppSettings, SyncOps
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Helpers de mantenimiento mínimos
  Future<int> clearAll() async {
    return transaction(() async {
      await delete(chatMessages).go();
      await delete(quizResults).go();
      await delete(quizQuestions).go();
      await delete(noteChunks).go();
      final res = await (delete(notes)..where((tbl) => const Constant(true))).go();
      return res;
    }).then((_) => 1);
  }

  // Toca updatedAt en updates de notes
  Future<void> touchNote(String noteId) async {
    await (update(notes)..where((t) => t.id.equals(noteId))).write(
      NotesCompanion(updatedAt: Value(DateTime.now())),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'study_assistant.db'));
    return NativeDatabase.createInBackground(file);
  });
}
