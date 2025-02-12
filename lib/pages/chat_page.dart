import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';
import '../pages/cart_page.dart';
import '../pages/order_history_page.dart';
import '../providers/cart_provider.dart';
import '../pages/admin/product_management_page.dart';
import '../models/user_role.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  String selectedMarket = 'Mile 12';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              _buildHeader(),
              Expanded(
                child: hasMessages
                    ? _buildChatList(chatProvider)
                    : _buildWelcomeScreen(),
              ),
              hasMessages 
                  ? _buildChatInputField() 
                  : _buildWelcomeInputField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(ChatProvider chatProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.messageHistory.length + 
                 (chatProvider.isLoadingResponse ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < chatProvider.messageHistory.length) {
          return ChatBubble(message: chatProvider.messageHistory[index]);
        }
        return _buildLoadingIndicator();
      },
    );
  }

  Widget _buildGreeting(User? user) {
    if (user != null) {
      return Text(
        'Hi there, ${user.displayName ?? 'User'}.\nWhat can I do for you?',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
    }
    return Text(
      'Hi there,\nhow can I help you today?',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSuggestionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
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
            Spacer(),
            Icon(icon, size: 24, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSuggestionCard(
              icon: Icons.shopping_cart_outlined,
              title: 'Buy Foodstuff\nfrom Markets',
              onTap: () => _controller.text = 'I want to buy foodstuff from $selectedMarket market',
            ),
            SizedBox(width: 12),
            _buildSuggestionCard(
              icon: Icons.calendar_today_outlined,
              title: 'Schedule my\nMarket Runs',
              onTap: () => _controller.text = 'Help me schedule my market runs',
            ),
            SizedBox(width: 12),
            _buildSuggestionCard(
              icon: Icons.trending_up_outlined,
              title: 'Check latest\nprice updates',
              onTap: () => _controller.text = 'What are the latest price updates?',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Image.asset('assets/qwen_logo.png', height: 32),
          Spacer(),
          AdminMenu(),
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  },
                ),
                if (cart.items.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.items.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8),
          StreamBuilder<User?>(
            stream: AuthService().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return PopupMenuButton(
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(snapshot.data?.photoURL ?? ''),
                    backgroundColor: Colors.brown,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.receipt_long_outlined),
                        title: Text('Order History'),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrderHistoryPage()),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                      ),
                      onTap: () async {
                        await AuthService().signOut();
                      },
                    ),
                  ],
                );
              }
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Login'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Column(
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
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
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

  Widget _buildChatInputField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask me something...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                Provider.of<ChatProvider>(context, listen: false)
                    .sendMessage(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeInputField() {
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
            padding: EdgeInsets.all(8),
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
            height: 40,
            padding: EdgeInsets.only(left: 8, right: 8, top: 4),
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
                    minimumSize: Size(0, 32),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Spacer(),
                Text('0/1000', style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send_rounded, size: 20),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      Provider.of<ChatProvider>(context, listen: false)
                          .sendMessage(_controller.text);
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
}

class AdminMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserRole>(
      stream: AuthService().userRoleStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        
        final role = snapshot.data!;
        if (!role.isAdmin) return SizedBox();

        return PopupMenuButton(
          icon: Icon(Icons.admin_panel_settings),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.inventory),
                title: Text('Manage Products'),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductManagementPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}