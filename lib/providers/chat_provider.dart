import 'package:flutter/foundation.dart';
import '../services/openai_service.dart';
import '../services/firebase_service.dart';

class ChatProvider extends ChangeNotifier {
  final OpenAIService _openAIService = OpenAIService();
  final FirebaseService _firebaseService = FirebaseService();

  List<Map<String, dynamic>> _messageHistory = [];
  bool _isLoadingResponse = false;

  List<Map<String, dynamic>> get messageHistory => _messageHistory;
  bool get isLoadingResponse => _isLoadingResponse;

  Map<String, dynamic> _createMessage(String role, String content, [List<Map<String, dynamic>> products = const []]) {
    return {
      'role': role,
      'content': content,
      'products': products,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  void sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _messageHistory.add(_createMessage('user', message));
    notifyListeners();

    _isLoadingResponse = true;
    notifyListeners();

    try {
      // First check if OpenAI is configured
      if (!_openAIService.isConfigured) {
        throw Exception('OpenAI API is not configured');
      }

      final products = await _firebaseService.queryProducts(message);
      final recentMessages = _messageHistory
          .where((msg) => msg['timestamp'] != null)
          .toList()
          .reversed
          .take(5)
          .toList()
          .reversed
          .toList();

      final response = await _openAIService.sendMessage(
        message,
        products,
        previousMessages: recentMessages,
      );

      _messageHistory.add(_createMessage('assistant', response, products));
    } catch (e) {
      print('Chat Provider Error: $e');  // Add error logging
      String errorMessage = 'Sorry, I encountered an error. Please try again.';
      
      if (e.toString().contains('API is not configured')) {
        errorMessage = 'Chat service is not properly configured. Please contact support.';
      }
      
      _messageHistory.add(_createMessage('assistant', errorMessage));
    } finally {
      _isLoadingResponse = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messageHistory.clear();
    notifyListeners();
  }
}
