import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  AiService({
    String? apiKey,
    String? baseUrl,
    this.model = 'llama-3.1-8b-instant',
  })  : _apiKey = apiKey ?? dotenv.env['GROQ_API_KEY'] ?? '',
        _baseUrl = baseUrl ??
            dotenv.env['GROQ_BASE_URL'] ??
            'https://api.groq.com/openai/v1';

  final String _apiKey;
  final String _baseUrl;
  final String model;

  Future<String> askOnText({
    required String text,
    required String question,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/chat/completions');
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content':
                'Responde en español, breve y SOLO con base en el texto dado. Si no está en el texto, dilo explícitamente.',
          },
          {'role': 'user', 'content': 'TEXTO:\n$text\n\nPREGUNTA:\n$question'},
        ],
        'temperature': 0.2,
        'max_tokens': 300,
      });

      final res = await http.post(url, headers: headers, body: body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return (data['choices'][0]['message']['content'] as String?)?.trim() ??
            'Sin respuesta';
      } else {
        debugPrint('AI error ${res.statusCode}: ${res.body}');
        return 'No se pudo obtener respuesta de la IA.';
      }
    } catch (e) {
      debugPrint('AI exception: $e');
      return 'Error interno al consultar la IA.';
    }
  }

  Future<List<Map<String, dynamic>>> generateQuiz({
    required String text,
    int questionCount = 5,
    String difficulty = 'medium',
  }) async {
    try {
      final prompt = '''
Eres un generador de cuestionarios. Responde ÚNICAMENTE con un JSON válido.

TEXTO BASE:
$text

TAREA: Genera $questionCount preguntas en español.

FORMATO (usa EXACTAMENTE esta estructura):
[
  {
    "type": "multiple_choice",
    "question": "pregunta",
    "options": ["opción1", "opción2", "opción3", "opción4"],
    "answer": "respuesta completa",
    "explanation": "explicación",
    "difficulty": "$difficulty"
  }
]

REGLAS CRÍTICAS:
- "answer" debe contener la respuesta COMPLETA, NO letras como "A", "B", "C"
- Tipos válidos: multiple_choice, true_false, fill_blank
- Responde SOLO con el JSON array
- NO agregues texto explicativo

JSON:
''';

      final url = Uri.parse('$_baseUrl/chat/completions');
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content':
                'Eres un asistente que SOLO responde con JSON válido. Nunca agregas texto adicional.'
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 2500,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        var content = data['choices'][0]['message']['content'] as String;

        // Limpieza agresiva
        content = content.trim();

        // Elimina markdown
        content = content.replaceAll('```json', '');
        content = content.replaceAll('```', '');

        // Busca el inicio y fin del JSON
        final jsonStart = content.indexOf('[');
        if (jsonStart != -1) {
          content = content.substring(jsonStart);
        }

        final jsonEnd = content.lastIndexOf(']');
        if (jsonEnd != -1) {
          content = content.substring(0, jsonEnd + 1);
        }

        content = content.trim();

        // Debug para ver qué se va a parsear
        debugPrint(
            'JSON a parsear (primeros 200 chars): ${content.substring(0, content.length > 200 ? 200 : content.length)}');

        final questions = jsonDecode(content) as List<dynamic>;
        return questions.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Quiz error: $e');
      rethrow;
    }
  }
}
