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

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      // Add user message
      _messageHistory.add({
        'role': 'user',
        'content': message,
        'products': [],
      });
      notifyListeners();

      _isLoadingResponse = true;
      notifyListeners();

      // Extract product keywords from message
      final keywords = message.toLowerCase().split(' ');
      
      // Query products before AI response
      final matchingProducts = await _firebaseService.queryProducts(message);
      print('Found matching products: $matchingProducts'); // Debug print

      // Get AI response
      final response = await _openAIService.sendMessage(
        message, 
        matchingProducts,
        previousMessages: _messageHistory,
      );

      // Add assistant message with products
      _messageHistory.add({
        'role': 'assistant',
        'content': response,
        'products': matchingProducts, // Include matched products
      });

    } catch (e) {
      print('Error in sendMessage: $e');
      _messageHistory.add({
        'role': 'assistant',
        'content': 'Sorry, I encountered an error. Please try again.',
        'products': [],
      });
    }
    
    _isLoadingResponse = false;
    notifyListeners();
  }

  void clearChat() {
    _messageHistory.clear();
    notifyListeners();
  }
}
