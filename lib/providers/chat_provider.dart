import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/openai_service.dart';
import '../services/firebase_service.dart';
import 'package:get_it/get_it.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

class ChatProvider extends ChangeNotifier {
  final OpenAIService _openAIService;
  final FirebaseService _firebaseService;

  List<Map<String, dynamic>> _messageHistory = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider({
    required OpenAIService openAIService,
    required FirebaseService firebaseService,
  }) : _openAIService = openAIService,
       _firebaseService = firebaseService {
    // Initialize any state here if needed
    _messageHistory = [];
  }

  List<Map<String, dynamic>> get messageHistory => List.unmodifiable(_messageHistory);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void addMessage(String content, MessageRole role, {Map<String, dynamic>? metadata}) {
    _messageHistory.add({
      'role': role.toString().split('.').last,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
      if (metadata != null) ...metadata,
    });
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _setLoading(true);
    _setError(null);

    try {
      addMessage(message, MessageRole.user);
      final matchingProducts = await _firebaseService.queryProducts(message);
      final response = await _openAIService.sendMessage(
        message,
        matchingProducts,
        previousMessages: _messageHistory,
      );

      addMessage(
        response, 
        MessageRole.assistant,
        metadata: {'products': matchingProducts},
      );
    } on OpenAIException catch (e) {
      _setError('AI Service Error: ${e.message}');
      addMessage(
        'Sorry, I encountered an error with the AI service. Please try again.',
        MessageRole.assistant,
      );
    } on FirebaseException catch (e) {
      _setError('Database Error: ${e.message}');
      addMessage(
        'Sorry, I encountered a database error. Please try again.',
        MessageRole.assistant,
      );
    } catch (e) {
      _setError('Unexpected Error: $e');
      addMessage(
        'Sorry, an unexpected error occurred. Please try again.',
        MessageRole.assistant,
      );
    } finally {
      _setLoading(false);
    }
  }

  void clearChat() {
    _messageHistory.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>> _getProductInfo(String productId) async {
    try {
      // Use the new method that includes variants
      return await _firebaseService.getProductWithVariants(productId);
    } catch (e) {
      print('Error getting product info: $e');
      return {
        'error': 'Product not found',
      };
    }
  }

  Future<void> _handleProductRecommendation(String productId) async {
    final productInfo = await _getProductInfo(productId);
    if (productInfo.containsKey('error')) {
      addMessage(
        'Sorry, I could not find that product. Please try another one.',
        MessageRole.assistant,
      );
      return;
    }

    // Include variant information in the message
    final variants = productInfo['variants'] as List;
    String variantsText = '';
    if (variants.isNotEmpty) {
      variantsText = '\n\nAvailable variants:\n' + 
        variants.map((v) => '• ${v['description']}').join('\n');
    }

    addMessage(
      'I found ${productInfo['name']} at ${productInfo['market']}. '
      'The base price is ₦${productInfo['basePrice']} per ${productInfo['unit'] ?? 'unit'}.'
      '$variantsText\n\n'
      'Would you like to add this to your cart?',
      MessageRole.assistant,
      metadata: {
        'type': 'product_recommendation',
        'productInfo': productInfo,
      },
    );
  }

  Future<void> _handleVariantFiltering(String userInput, String productId) async {
    final productInfo = await _getProductInfo(productId);
    if (productInfo.containsKey('error')) {
      addMessage(
        'Sorry, I could not find that product.',
        MessageRole.assistant,
      );
      return;
    }

    final variants = productInfo['variants'] as List;
    if (variants.isEmpty) {
      addMessage(
        'This product does not have any variants.',
        MessageRole.assistant,
      );
      return;
    }

    // Filter variants based on user input
    final lowercaseInput = userInput.toLowerCase();
    final filteredVariants = variants.where((v) {
      final name = v['name'].toString().toLowerCase();
      final description = v['description']?.toString().toLowerCase() ?? '';
      return name.contains(lowercaseInput) || description.contains(lowercaseInput);
    }).toList();

    if (filteredVariants.isEmpty) {
      addMessage(
        'I could not find any variants matching your criteria.',
        MessageRole.assistant,
      );
      return;
    }

    final variantsText = filteredVariants
        .map((v) => '• ${v['description'] ?? v['name']} at ₦${v['price']}')
        .join('\n');

    addMessage(
      'I found these variants for ${productInfo['name']}:\n\n$variantsText',
      MessageRole.assistant,
      metadata: {
        'type': 'product_recommendation',
        'productInfo': {
          ...productInfo,
          'variants': filteredVariants,
        },
      },
    );
  }
}
