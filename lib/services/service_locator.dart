import 'package:get_it/get_it.dart';
import 'firebase_service.dart';
import 'openai_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<OpenAIService>(() => OpenAIService());
} 