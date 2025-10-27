import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo/presentation/pages/modules/widgets.dart';
import 'package:todo/core/services/ai_service.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _sb = Supabase.instance.client;

  /// Última nota del usuario autenticado
  Future<Map<String, dynamic>?> _getLastNote() async {
    final user = _sb.auth.currentUser;
    if (user == null) return null;

    final res = await _sb
        .from('notes')
        .select('id, title, subject, raw_text, clean_text, summary, created_at')
        .eq('user_id', user.id)
        .eq('deleted', false)
        .order('created_at', ascending: false)
        .limit(1);

    if (res.isEmpty) return null;
    return res.first as Map<String, dynamic>;
  }

  /// Diálogo para crear una nota mínima (title, subject opcional, raw_text)
  Future<void> _createNoteDialog() async {
    final title = TextEditingController();
    final subject = TextEditingController();
    final raw = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva nota'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subject,
                decoration:
                    const InputDecoration(labelText: 'Materia (opcional)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: raw,
                minLines: 6,
                maxLines: 12,
                decoration: const InputDecoration(
                  labelText: 'Contenido (raw_text)',
                  hintText: 'Pega aquí tus apuntes…',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );

    if (ok != true) return;

    final user = _sb.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para crear notas')),
      );
      return;
    }

    await _sb.from('notes').insert({
      'user_id': user.id,
      'title': title.text.trim(),
      'subject': subject.text.trim().isEmpty ? null : subject.text.trim(),
      'raw_text': raw.text.trim(),
      'clean_text': null, // la dejaremos para un futuro preprocesado
      'summary': null,
      'tags': <dynamic>[],
      'deleted': false,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota guardada')),
    );
    setState(() {}); // refresca la vista (para IA sobre última nota)
  }

  /// Pregunta a la IA usando la última nota del usuario.
  Future<void> _askAiOnLastNote() async {
    final note = await _getLastNote();
    if (note == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes notas. Crea una primero.')),
      );
      return;
    }

    final question = TextEditingController();
    final ask = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Preguntar a la IA — ${note['title'] ?? '(sin título)'}'),
        content: TextField(
          controller: question,
          decoration: const InputDecoration(
            labelText: 'Tu pregunta sobre esta nota',
            hintText: 'Ej.: Resume los puntos clave…',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Preguntar')),
        ],
      ),
    );
    if (ask != true) return;

    final ai = Get.find<AiService>();
    final noteText =
        (note['clean_text'] ?? note['raw_text'] ?? '').toString().trim();

    if (noteText.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La nota no tiene texto para analizar (vacía).')),
      );
      return;
    }

    // Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final answer = await ai.askOnText(
      text: noteText,
      question: question.text.trim(),
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // cierra loader

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Respuesta de la IA'),
        content: SingleChildScrollView(child: Text(answer)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SectionScaffold(
      title: 'Notas / Archivos / IA Asistente',
      subtitle: 'Centraliza tus apuntes y consulta a la IA sobre ellos.',
      children: [
        TileCard(
          title: 'Crear nota',
          icon: Icons.note_add_outlined,
          onTap: _createNoteDialog,
        ),
        TileCard(
          title: 'Importar archivo',
          icon: Icons.upload_file_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pronto: subidas de archivos')),
            );
          },
        ),
        TileCard(
          title: 'Preguntar a la IA',
          icon: Icons.smart_toy_outlined,
          onTap: _askAiOnLastNote,
        ),
      ],
      footer: Text(
        'Próximamente: limpieza de texto, resumen automático y etiquetas.',
        style: t.textTheme.bodySmall
            ?.copyWith(color: t.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
