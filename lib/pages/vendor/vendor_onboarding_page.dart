import 'package:flutter/material.dart';
import '../../models/vendor_model.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';

class VendorOnboardingPage extends StatefulWidget {
  @override
  State<VendorOnboardingPage> createState() => _VendorOnboardingPageState();
}

class _VendorOnboardingPageState extends State<VendorOnboardingPage> {
  int _currentStep = 0;
  String? _selectedMarket;
  List<String> _selectedCategories = [];
  List<String> _selectedProducts = [];
  bool _isLoading = false;

  final _markets = [
    'Mile 12',
    'KETU',
    'Ounje Eko Mushin',
    'Oyingbo',
    'Makoko',
  ];

  final _categories = [
    'Grains',
    'Vegetables',
    'Fruits',
    'Meat',
    'Fish',
    'Spices',
    'Tubers',
  ];

  Widget _buildMarketStep() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _markets.map((market) {
        final isSelected = _selectedMarket == market;
        return ChoiceChip(
          label: Text(market),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedMarket = selected ? market : null);
          },
        );
      }).toList(),
    );
  }

  Widget _buildCategoriesStep() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildProductsStep() {
    return FutureBuilder<List<String>>(
      future: FirebaseService().getProductsByCategories(_selectedCategories),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final products = snapshot.data!;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: products.map((product) {
            final isSelected = _selectedProducts.contains(product);
            return ChoiceChip(
              label: Text(product),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedProducts.add(product);
                  } else {
                    _selectedProducts.remove(product);
                  }
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not found');

      final vendor = VendorModel(
        id: '', // Will be set by Firestore
        userId: user.uid,
        market: _selectedMarket!,
        categories: _selectedCategories,
        products: _selectedProducts,
        createdAt: DateTime.now(),
      );

      await FirebaseService().createVendor(vendor);
      Navigator.of(context).pushReplacementNamed('/vendor/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Join as Vendor')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0 && _selectedMarket == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select a market')),
            );
            return;
          }
          if (_currentStep == 1 && _selectedCategories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select at least one category')),
            );
            return;
          }
          if (_currentStep == 2) {
            if (_selectedProducts.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select at least one product')),
              );
              return;
            }
            _completeOnboarding();
            return;
          }
          setState(() => _currentStep++);
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          Step(
            title: Text('Select Market'),
            content: _buildMarketStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text('Select Categories'),
            content: _buildCategoriesStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text('Select Products'),
            content: _buildProductsStep(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
} 