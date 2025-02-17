import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/cart_provider.dart';
import 'services/auth_service.dart'; // Add this line to import AuthService
import 'firebase_options.dart';
import 'pages/chat_page.dart';
import 'pages/admin/admin_layout.dart';
import 'pages/admin/admin_dashboard.dart';
import 'pages/admin/product_management_page.dart';
import 'pages/admin/vendor_management_page.dart';
import 'pages/admin/delivery_management_page.dart';
import 'pages/admin/analytics_page.dart';
import 'services/service_locator.dart';
import 'services/firebase_service.dart';
import 'services/openai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Setup dependency injection
  setupServiceLocator();

  // Create services first
  final openAIService = getIt<OpenAIService>();
  final firebaseService = getIt<FirebaseService>();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            openAIService: openAIService,
            firebaseService: firebaseService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OjaChat - AI Chatbot for Market Runs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => ChatPage(),
        '/admin': (context) => AdminLayout(
          child: AdminDashboard(),
          currentPage: 'dashboard',
        ),
        '/admin/products': (context) => AdminLayout(
          child: ProductManagementPage(),
          currentPage: 'products',
        ),
        '/admin/vendors': (context) => AdminLayout(
          child: VendorManagementPage(),
          currentPage: 'vendors',
        ),
        '/admin/deliveries': (context) => AdminLayout(
          child: DeliveryManagementPage(),
          currentPage: 'deliveries',
        ),
        '/admin/analytics': (context) => AdminLayout(
          child: AnalyticsPage(),
          currentPage: 'analytics',
        ),
      },
    );
  }
}
