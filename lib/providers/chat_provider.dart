import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../services/firebase_service.dart';
import '../models/product_model.dart';

class ChatProvider extends ChangeNotifier {
  final OpenAIService _openAIService = OpenAIService();
  final FirebaseService _firebaseService = FirebaseService();

  List<Map<String, dynamic>> _messageHistory = [];
  List<Map<String, dynamic>> _productSearchResults = [];
  bool _isLoading = false;
  bool _isLoadingResponse = false;
  String? _errorMessage;
  List<ProductModel> _matchedProducts = [];

  List<Map<String, dynamic>> get messageHistory => _messageHistory;
  List<Map<String, dynamic>> get productSearchResults => _productSearchResults;
  bool get isLoading => _isLoading;
  bool get isLoadingResponse => _isLoadingResponse;
  String? get errorMessage => _errorMessage;
  List<ProductModel> get matchedProducts => _matchedProducts;

  void sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _messageHistory.add({
      'role': 'user',
      'content': message,
    });
    _isLoadingResponse = true;
    notifyListeners();

    try {
      print('Querying Firestore...'); // Debug log
      final products = await _firebaseService.queryProducts(message);
      print('Firestore data received: ${products.length} items'); // Debug log
      print('Calling OpenAI...'); // Debug log
      final response = await _openAIService.sendMessage(
        message, 
        products.map((p) => {
          'name': p['name'],
          'units': (p['units'] as List).map((u) => 
            '${u['quantity']} ${u['name']}: ₦${u['price']}'
          ).join(', '),
        }).toList()
      );
      print('OpenAI response received'); // Debug log
      
      _messageHistory.add({
        'role': 'assistant',
        'content': response,
        'products': products,
      });
    } catch (e) {
      print('Error in sendMessage: $e');
      _messageHistory.add({
        'role': 'assistant',
        'content': 'Sorry, I encountered an error. Please try again.',
      });
    } finally {
      _isLoadingResponse = false;
      notifyListeners();
    }
  }

  void handleProductSearch(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _productSearchResults = await _firebaseService.queryProducts(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to search products: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateChatState() {
    notifyListeners();
  }

  void clearChat() {
    _messageHistory.clear();
    notifyListeners();
  }

  Future<void> handleUserInput(String userInput) async {
    _matchedProducts = await _firebaseService.fetchMatchingProducts(userInput);
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
