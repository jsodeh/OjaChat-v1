import 'package:flutter/foundation.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'English';
  
  String get currentLanguage => _currentLanguage;
  
  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }
} 