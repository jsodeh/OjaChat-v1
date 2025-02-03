import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyCY7diV4rZPQF3mIdiOnJhK2qs9kqlkjxA',
      appId: '1:191846798545:web:c4af73febcd4c3b40121f0',
      messagingSenderId: '191846798545',
      projectId: 'jastacks',
      authDomain: 'jastacks.firebaseapp.com',
      storageBucket: 'jastacks.appspot.com',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCY7diV4rZPQF3mIdiOnJhK2qs9kqlkjxA',
    authDomain: 'jastacks.firebaseapp.com',
    projectId: 'jastacks',
    storageBucket: 'jastacks.appspot.com',
    messagingSenderId: '191846798545',
    appId: '1:191846798545:web:c4af73febcd4c3b40121f0',
  );

  // Add configurations for other platforms here
} 