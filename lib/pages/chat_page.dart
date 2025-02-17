import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import '../styles/app_theme.dart';
import '../widgets/hover_effect.dart';
import '../pages/profile_page.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  String selectedMarket = 'Mile 12';
  final List<String> hintTexts = [
    'Buy foodstuff from Mile 12 Market',
    'I need ingredients for jollof rice',
    'Get me fresh tomatoes and pepper',
    'Compare prices of rice in different markets',
    'Find the best deals on palm oil',
    'Order fresh fish from Mile 12',
  ];
  int currentHintIndex = 0;

  // Add new list for update messages
  final List<String> updateMessages = [
    'Weekend Deliveries from Mile 12, Oyingbo, and Kara markets',
    'Shop in Groups for wholesale discounts',
  ];
  int currentUpdateIndex = 0;

  // Add state variable to track input
  String _inputText = '';

  // Add this variable to control animation duration
  static const updateAnimationDuration = Duration(seconds: 5);
  static const updatePauseDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _inputText = _controller.text;
      });
    });
    _startHintAnimation();
    _startUpdateAnimation();
  }

  void _startHintAnimation() {
    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          currentHintIndex = (currentHintIndex + 1) % hintTexts.length;
        });
        _startHintAnimation();
      }
    });
  }

  void _startUpdateAnimation() {
    if (!mounted) return;

    Future.delayed(updateAnimationDuration + updatePauseDuration, () {
      if (mounted) {
        setState(() {
          currentUpdateIndex = (currentUpdateIndex + 1) % updateMessages.length;
        });
        _startUpdateAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: _buildAppBar(),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) => _buildBody(chatProvider),
      ),
    );
  }

  Widget _buildBody(ChatProvider chatProvider) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: chatProvider.messageHistory.isEmpty
          ? _buildLovableLikeWelcome()
          : _buildChatView(chatProvider),
    );
  }

  Widget _buildLovableLikeWelcome() {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 768 ? 32 : 16,
              vertical: 64,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo above updates
                Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Image.asset(
                    'assets/OjaChat Logo.png',
                    height: 48,
                    width: 48,
                  ),
                ),
                
                // Replace the old updates container with the new widget
                _buildUpdatesWidget(),
                SizedBox(height: 32),

                // Heading
                Text('Market runs, powered by AI',
                  style: AppTheme.headingStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                
                Text('Ojachat is your personal shopper for market runs',
                  style: AppTheme.subtitleStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),

                // Input area with exact Lovable styling
                _buildLovableInput(),
                
                SizedBox(height: 32),
                
                // Quick access suggestions
                _buildQuickAccessSuggestions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdatesWidget() {
    return Container(
      constraints: BoxConstraints(maxWidth: 320),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.campaign, size: 16, color: Colors.white70),
          ),
          SizedBox(width: 12),
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: SingleChildScrollView(
                key: ValueKey<int>(currentUpdateIndex),
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 20), // Force single line
                  child: Text(
                    updateMessages[currentUpdateIndex],
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: false, // Prevent wrapping to next line
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLovableInput() {
    return Container(
      width: MediaQuery.of(context).size.width > 768 ? 720 : double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Increased vertical padding
      decoration: AppTheme.enhancedInputDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text input with animated hints
          TextField(
            controller: _controller,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            minLines: 2, // Added this
            maxLines: 4, // Added this
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8), // Added vertical padding
              hintText: _inputText.isEmpty ? hintTexts[currentHintIndex] : null,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ),

          SizedBox(height: 12),

          // Bottom row with icons and actions
          Row(
            children: [
              // Left side icons
              IconButton(
                icon: Icon(Icons.image_outlined, 
                  color: Colors.white70,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.mic_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {},
              ),
              
              Spacer(),
              
              // Language selector
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language,
                    color: Colors.white70,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  DropdownButton<String>(
                    value: 'English',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    underline: SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, 
                      color: Colors.white70,
                      size: 18,
                    ),
                    items: ['English', 'Hausa', 'Igbo', 'Yoruba']
                      .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      )).toList(),
                    onChanged: (value) {},
                  ),
                ],
              ),
              
              SizedBox(width: 12),
              
              // Send button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _inputText.isEmpty 
                    ? Colors.white.withOpacity(0.1) 
                    : AppTheme.primaryColor,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_upward,
                    color: _inputText.isEmpty 
                      ? Colors.white38 
                      : Colors.white,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: _inputText.isEmpty ? null : () async {
                    if (_inputText.isNotEmpty) {
                      final chatProvider = context.read<ChatProvider>();
                      await chatProvider.sendMessage(_inputText);
                      _controller.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
  final isDesktop = MediaQuery.of(context).size.width > 768;
  
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leadingWidth: 200,
    leading: Padding(
      padding: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Image.asset(
            'assets/OjaChat Logo.png',
            height: 24,  // Increased from 24
            width: 24,   // Increased from 24
          ),
          SizedBox(width: 12),
          Text('OjaChat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
    actions: [
      if (!isDesktop) // Only show in mobile view
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _showMobileMenu(context),
        ),
      if (isDesktop) ...[
        TextButton(
          onPressed: () {},
          child: HoverEffect(
            child: Text('Support', style: TextStyle(color: Colors.white70)),
          ),
        ),
        HoverEffect(
          child: TextButton(
            onPressed: () {},
            child: HoverEffect(
              child: Text('Blog', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ),
        HoverEffect(
          child: IconButton(
            icon: FaIcon(FontAwesomeIcons.twitter, size: 18),
            color: Colors.white70,
            onPressed: () {},
          ),
        ),
        HoverEffect(
          child: IconButton(
            icon: FaIcon(FontAwesomeIcons.discord, size: 18),
            color: Colors.white70,
            onPressed: () {},
          ),
        ),
        SizedBox(width: 8),
        HoverEffect(child: _buildUserMenu()),
        SizedBox(width: 16),
      ],
    ],
  );
}

  Widget _buildChatView(ChatProvider chatProvider) {
  print('Building chat view:');
  print('Message history length: ${chatProvider.messageHistory.length}');
  
  return Column(
    children: [
      Expanded(
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: chatProvider.messageHistory.length,
          itemBuilder: (context, index) {
            final message = chatProvider.messageHistory[index];
            print('Message $index:');
            print('- Role: ${message['role']}');
            print('- Content: ${message['content']}');
            print('- Products: ${message['products']}');
            
            return ChatBubble(
              message: message['content'],
              isUser: message['role'] == 'user',
              products: message['products'],
            );
          },
        ),
      ),
      _buildInputArea(),
    ],
  );
}

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: hintTexts[currentHintIndex],
                border: InputBorder.none,
              ),
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  final chatProvider = context.read<ChatProvider>();
                  await chatProvider.sendMessage(value);
                  _controller.clear();
                }
              },
            ),
          ),
          _buildLanguageDropdown(),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButton<String>(
      value: 'English',
      icon: Row(
        children: [
          Icon(Icons.language),
          Icon(Icons.arrow_drop_down),
        ],
      ),
      items: ['English', 'Hausa', 'Igbo', 'Yoruba']
          .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang),
              ))
          .toList(),
      onChanged: (value) {
        // Implement language change
      },
    );
  }

  Widget _buildUserMenu() {
    return PopupMenuButton(
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.person),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          child: Text('Profile'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          ),
        ),
        PopupMenuItem(child: Text('Settings')),
        PopupMenuItem(
          child: Text('Logout'),
          onTap: () async {
            await context.read<AuthService>().signOut();
          },
        ),
      ],
    );
  }

  void _showMobileMenu(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Provider<AuthService>.value(
        value: authService,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person_outline, color: Colors.white70),
                title: Text('Profile', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_outlined, color: Colors.white70),
                title: Text('Settings', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout_outlined, color: Colors.white70),
                title: Text('Sign Out', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await authService.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMenuItem(IconData icon, String text, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(text, style: TextStyle(color: Colors.white)),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      leading: Icon(Icons.language),
      title: Text('Language'),
      trailing: DropdownButton<String>(
        value: 'English',
        items: ['English', 'Hausa', 'Igbo', 'Yoruba']
            .map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                ))
            .toList(),
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildQuickAccessSuggestions() {
    final suggestions = [
      'Buy ingredients for soup',
      'Get fresh vegetables',
      'Price of rice',
      'Compare tomato prices',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: suggestions.map((text) => Padding(
          padding: EdgeInsets.only(right: 12),
          child: HoverEffect(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
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

// Example of creating a message with product data
final productData = {
  'imageUrl': 'https://example.com/tomatoes.jpg',
  'name': 'Fresh Tomatoes',
  'price': 500.0,
  'unit': 'kg',
};

// Example of creating a message with product data
void exampleChatBubble() {
  final productData = {
    'imageUrl': 'https://example.com/tomatoes.jpg',
    'name': 'Fresh Tomatoes',
    'price': 500.0,
    'unit': 'kg',
  };

  ChatBubble(
    message: "The current price for tomatoes at Mile 12 market is about N500 per kilogram.",
    isUser: false,
    products: [productData],
  );
}