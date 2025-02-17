import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;

  OpenAIService._internal();

  final _client = http.Client();
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const timeout = Duration(seconds: 30);

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> sendMessage(
    String message,
    List<Map<String, dynamic>> products, {
    required List<Map<String, dynamic>> previousMessages,
  }) async {
    try {
      final systemPrompt = _createSystemPrompt(products);
      final messages = _formatMessages(previousMessages, message, systemPrompt);

      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-turbo-preview',
          'messages': messages,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode != 200) {
        throw OpenAIException(
          'API request failed with status ${response.statusCode}',
          response.statusCode,
        );
      }

      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } catch (e) {
      throw OpenAIException('Failed to get response: $e');
    }
  }

  List<Map<String, dynamic>> _formatMessages(
    List<Map<String, dynamic>> previousMessages,
    String newMessage,
    String systemPrompt,
  ) {
    return [
      {'role': 'system', 'content': systemPrompt},
      ...previousMessages.map((msg) => {
            'role': msg['role'],
            'content': msg['content'],
          }),
      {'role': 'user', 'content': newMessage},
    ];
  }

  String _createSystemPrompt(List<Map<String, dynamic>> products) {
    final hasProducts = products.isNotEmpty;
    final productContext = hasProducts 
        ? '\nAvailable products and current prices:\n${_formatProducts(products)}\n'
        : '';

    return '''
You are a helpful market assistant for Mile 12 market in Lagos.
Your role is to help customers with market information and prices.
$productContext
Keep responses natural and friendly.
When discussing products, always mention current prices from the available products list.
For general queries, provide helpful market information.
Respond in a conversational tone and keep responses concise.
Use Naira symbol ₦ when mentioning prices.
''';
  }

  String _formatProducts(List<Map<String, dynamic>> products) {
    if (products.isEmpty) return '';
    return products.map((item) => 
      '- ${item['name']}: ₦${item['price']} per ${item['unit'] ?? 'unit'}'
    ).join('\n');
  }
}

class OpenAIException implements Exception {
  final String message;
  final int? statusCode;

  OpenAIException(this.message, [this.statusCode]);

  @override
  String toString() => 'OpenAIException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}