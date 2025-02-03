import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'firebase_options.dart';
import 'models/product_model.dart';
import 'package:shimmer/shimmer.dart';
import 'widgets/chat_bubble.dart';
import 'services/firebase_service.dart';
import 'pages/login_page.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qwen Chat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: ChatScreen(),
    );
  }
}

class MarketUpdate {
  final String item;
  final String price;
  final String trend;
  final String lastUpdated;

  MarketUpdate({
    required this.item,
    required this.price,
    required this.trend,
    required this.lastUpdated,
  });
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String selectedMarket = 'Mile 12';

  Widget _buildGreeting(User? user) {
    if (user != null) {
      return Text(
        'Hi there, ${user.displayName ?? 'User'}.\nWhat can I do for you?',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Text(
      'Hi there,\nhow can I help you today?',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInputField() {
    final chatProvider = Provider.of<ChatProvider>(context);
    
    return Container(
      margin: EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask whatever you want...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButton<String>(
                    value: selectedMarket,
                    underline: SizedBox(),
                    icon: Icon(Icons.expand_more, size: 16),
                    isDense: true,
                    menuMaxHeight: 200,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[800],
                    ),
                    items: [
                      'Mile 12',
                      'KETU',
                      'Ounje Eko Mushin',
                      'Oyingbo',
                      'Makoko',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => selectedMarket = newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.mic, size: 10),
                  label: Text(
                    'Voice to Cart',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                Spacer(),
                Text('0/1000', style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send_rounded, size: 20),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      chatProvider.sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  color: Theme.of(context).primaryColor,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSuggestionCard(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Buy Foodstuff\nfrom Markets',
                  ),
                  SizedBox(width: 12),
                  _buildSuggestionCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Schedule my\nMarket Runs',
                  ),
                  SizedBox(width: 12),
                  _buildSuggestionCard(
                    icon: Icons.trending_up_outlined,
                    title: 'Check latest\nprice updates',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Icon(icon, size: 24, color: Colors.grey[700]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final bool hasMessages = chatProvider.messageHistory.isNotEmpty;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.black12),
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/qwen_logo.png', height: 32),
                    Spacer(),
                    StreamBuilder<User?>(
                      stream: AuthService().authStateChanges,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(snapshot.data?.photoURL ?? ''),
                            backgroundColor: Colors.brown,
                          );
                        }
                        return TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          child: Text('Login'),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: hasMessages
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: chatProvider.messageHistory.length + (chatProvider.isLoadingResponse ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < chatProvider.messageHistory.length) {
                          return ChatBubble(message: chatProvider.messageHistory[index]);
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 120),
                        StreamBuilder<User?>(
                          stream: AuthService().authStateChanges,
                          builder: (context, snapshot) {
                            return _buildGreeting(snapshot.data);
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildSuggestionCards(),
                        _buildInputField(),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Price: \$${product.price.toStringAsFixed(2)}'),
            SizedBox(height: 8),
            Image.network(product.imageUrl, height: 100, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
