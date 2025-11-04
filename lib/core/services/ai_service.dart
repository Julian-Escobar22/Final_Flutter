import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  AiService({
    String? apiKey,
    String? baseUrl,
    this.model = 'llama-3.1-8b-instant',
  }) : _apiKey = apiKey ?? dotenv.env['GROQ_API_KEY'] ?? '',
       _baseUrl = baseUrl ?? dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1';

  final String _apiKey;
  final String _baseUrl;
  final String model;

  /// ✅ PREGUNTA SOBRE TEXTO/PDF - OPTIMIZADO
  Future<String> askOnText({
    required String text,
    required String question,
  }) async {
    try {
      // Validar que no esté vacío
      if (text.isEmpty || question.isEmpty) {
        return 'Por favor proporciona texto y una pregunta válidos.';
      }

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
            'content': 'Responde en español, de forma clara y SOLO con base en el texto dado. '
                'Si la pregunta no se puede responder con el texto, dilo explícitamente.',
          },
          {
            'role': 'user',
            'content': 'DOCUMENTO:\n$text\n\n---\n\nPREGUNTA: $question\n\nResponde basándote SOLO en el documento anterior.',
          },
        ],
        'temperature': 0.3, // ✅ Aumentado para más consistencia
        'max_tokens': 500, // ✅ Aumentado para respuestas más largas
      });

      final res = await http.post(url, headers: headers, body: body).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout: La IA tardó demasiado en responder'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final content = data['choices'][0]['message']['content'] as String?;
        return content?.trim() ?? 'No se obtuvo respuesta';
      } else if (res.statusCode == 429) {
        return 'Demasiadas solicitudes. Espera unos segundos e intenta de nuevo.';
      } else {
        debugPrint('❌ AI error ${res.statusCode}: ${res.body}');
        return 'Error de la IA: ${res.statusCode}. Intenta de nuevo.';
      }
    } catch (e) {
      debugPrint('❌ AI exception: $e');
      return 'Error: ${e.toString()}';
    }
  }

  /// ✅ GENERAR QUIZ - MEJORADO
  Future<List<Map<String, dynamic>>> generateQuiz({
    required String text,
    int questionCount = 5,
    String difficulty = 'medium',
  }) async {
    try {
      if (text.isEmpty) {
        throw Exception('El texto no puede estar vacío');
      }

      final prompt = '''Eres un generador de cuestionarios educativos en español.

CONTENIDO:
$text

TAREA: Genera EXACTAMENTE $questionCount preguntas de dificultad $difficulty basadas SOLO en el contenido anterior.

FORMATO JSON (responde SOLO con esto, sin explicaciones):
[
  {
    "type": "multiple_choice",
    "question": "La pregunta aquí",
    "options": ["opción A", "opción B", "opción C", "opción D"],
    "answer": "opción correcta completa",
    "explanation": "Por qué esta es la respuesta correcta",
    "difficulty": "$difficulty"
  }
]

REGLAS:
1. Responde SOLO JSON, sin markdown
2. "answer" = texto COMPLETO de la opción correcta
3. Tipos: multiple_choice, true_false, fill_blank
4. Mínimo 4 opciones en multiple_choice
5. Las preguntas deben ser del contenido proporcionado''';

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
            'content': 'Eres un generador JSON. Responde ÚNICAMENTE con JSON válido, nunca con explicaciones.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 3000,
      });

      final response = await http.post(url, headers: headers, body: body).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var content = data['choices'][0]['message']['content'] as String;

        // ✅ LIMPIEZA MEJORADA
        content = content.trim();
        content = content.replaceAll('``````', '');
        content = content.replaceAll(RegExp(r'^``````'), '');

        final jsonStart = content.indexOf('[');
        final jsonEnd = content.lastIndexOf(']');

        if (jsonStart == -1 || jsonEnd == -1) {
          throw Exception('No se encontró JSON válido en la respuesta');
        }

        content = content.substring(jsonStart, jsonEnd + 1).trim();

        debugPrint('📝 Quiz JSON encontrado: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');

        final questions = jsonDecode(content) as List<dynamic>;
        return questions.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Quiz error: $e');
      rethrow;
    }
  }

  /// ✅ ANALIZAR PDF - CON FALLBACK
  Future<String> analyzePdfContent(Uint8List pdfBytes) async {
    try {
      final base64Pdf = base64Encode(pdfBytes);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.2-90b-vision-preview',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Analiza este PDF y proporciona:\n'
                      '1. Título principal\n'
                      '2. 3-5 puntos clave\n'
                      '3. Resumen en 2-3 párrafos\n'
                      'Responde en español, de forma clara.',
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:application/pdf;base64,$base64Pdf',
                  },
                },
              ],
            },
          ],
          'temperature': 0.3,
          'max_tokens': 1500,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final analysis = data['choices'][0]['message']['content'] as String;
        return analysis.trim();
      } else {
        debugPrint('⚠️ PDF analysis failed: ${response.statusCode}');
        return 'PDF cargado correctamente. Contenido disponible para análisis.';
      }
    } catch (e) {
      debugPrint('⚠️ PDF error: $e');
      return 'Documento cargado. Error en análisis automático: ${e.toString()}';
    }
  }

  /// ✅ OCR MEJORADO
  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.2-90b-vision-preview',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Extrae TODO el texto visible en esta imagen:\n'
                      '- Copia el texto tal como aparece\n'
                      '- Si hay tablas, usa formato markdown\n'
                      '- Si hay fórmulas, usa LaTeX\n'
                      '- Responde SOLO con el texto, sin explicaciones',
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                },
              ],
            },
          ],
          'temperature': 0.1,
          'max_tokens': 4000,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final extractedText = data['choices'][0]['message']['content'] as String;
        return extractedText.trim();
      } else {
        throw Exception('OCR error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ OCR error: $e');
      rethrow;
    }
  }

  /// ✅ PREGUNTA GENÉRICA
  Future<String> askQuestion(String question) async {
    try {
      if (question.isEmpty) {
        return 'Por favor proporciona una pregunta válida.';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': question},
          ],
          'temperature': 0.3,
          'max_tokens': 1000,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['choices'][0]['message']['content'] as String;
        return answer.trim();
      } else {
        return 'Error: No se pudo obtener respuesta (${response.statusCode})';
      }
    } catch (e) {
      debugPrint('❌ Question error: $e');
      return 'Error: ${e.toString()}';
    }
  }
}
