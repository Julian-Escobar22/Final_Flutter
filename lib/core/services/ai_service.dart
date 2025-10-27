// lib/core/services/ai_service.dart
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
        _baseUrl = baseUrl ?? dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1';

  final String _apiKey;
  final String _baseUrl;
  final String model;

  /// Envía una pregunta sobre un texto dado y devuelve la respuesta en español.
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
                'Responde en español, breve y SOLO con base en el texto dado. Si no está en el texto, dilo explícitamente.'
          },
          {
            'role': 'user',
            'content': 'TEXTO:\n$text\n\nPREGUNTA:\n$question'
          }
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
}
