import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/product_model.dart';
import '../../styles/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'product_form_page.dart';

class ProductManagementPage extends StatefulWidget {
  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedMarket = 'all';
  String _sortBy = 'name'; // name, price, date
  bool _sortAscending = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Product Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddProductDialog(context),
          ),
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Update Search Terms'),
                onTap: () async {
                  try {
                    await _firebaseService.updateAllProductsWithSearchTerms();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Search terms updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to filter products
              },
            ),
          ),
          SizedBox(width: 16),
          _buildFilterDropdown(
            value: _selectedCategory,
            items: ['all', 'fruits', 'vegetables', 'meat', 'fish'],
            label: 'Category',
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
          SizedBox(width: 16),
          _buildFilterDropdown(
            value: _selectedMarket,
            items: ['all', 'Mile 12', 'Oyingbo', 'Kara'],
            label: 'Market',
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedMarket = value);
              }
            },
          ),
          SizedBox(width: 16),
          _buildSortButton(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item == 'all' ? 'All $label' : item,
              style: TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        style: TextStyle(color: Colors.white),
        dropdownColor: Colors.black87,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.sort, color: Colors.white),
      color: Colors.black87,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'name',
          child: Row(
            children: [
              Icon(
                Icons.sort_by_alpha,
                color: _sortBy == 'name' ? AppTheme.primaryColor : Colors.white70,
              ),
              SizedBox(width: 8),
              Text(
                'Name',
                style: TextStyle(
                  color: _sortBy == 'name' ? AppTheme.primaryColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'price',
          child: Row(
            children: [
              Icon(
                Icons.attach_money,
                color: _sortBy == 'price' ? AppTheme.primaryColor : Colors.white70,
              ),
              SizedBox(width: 8),
              Text(
                'Price',
                style: TextStyle(
                  color: _sortBy == 'price' ? AppTheme.primaryColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'date',
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: _sortBy == 'date' ? AppTheme.primaryColor : Colors.white70,
              ),
              SizedBox(width: 8),
              Text(
                'Date Added',
                style: TextStyle(
                  color: _sortBy == 'date' ? AppTheme.primaryColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        setState(() {
          if (_sortBy == value) {
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = value;
            _sortAscending = true;
          }
        });
      },
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<List<ProductModel>>(
      stream: _firebaseService.streamProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var products = snapshot.data!;

        // Apply filters
        products = products.where((product) {
          final matchesSearch = product.name.toLowerCase()
              .contains(_searchController.text.toLowerCase());
          final matchesCategory = _selectedCategory == 'all' || 
              product.category == _selectedCategory;
          final matchesMarket = _selectedMarket == 'all' || 
              product.market == _selectedMarket;
          
          return matchesSearch && matchesCategory && matchesMarket;
        }).toList();

        // Apply sorting
        products.sort((a, b) {
          int comparison;
          switch (_sortBy) {
            case 'name':
              comparison = a.name.compareTo(b.name);
              break;
            case 'price':
              comparison = a.price.compareTo(b.price);
              break;
            case 'date':
              comparison = a.createdAt.compareTo(b.createdAt);
              break;
            default:
              comparison = 0;
          }
          return _sortAscending ? comparison : -comparison;
        });

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(products[index]),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: product.imageUrl != null && product.imageUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  product.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 50,
                height: 50,
                color: Colors.white10,
                child: Icon(Icons.image, color: Colors.white30),
              ),
        title: Text(
          product.name,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '₦${product.price} per ${product.unit ?? 'unit'}',
          style: TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white70),
              onPressed: () => _showEditProductDialog(context, product),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white70),
              onPressed: () => _showDeleteConfirmation(context, product.id!),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddProductDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final unitController = TextEditingController();
    final categoryController = TextEditingController();
    final marketController = TextEditingController();
    File? imageFile;
    List<ProductVariant> variants = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.black87,
          title: Text('Add Product', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() => imageFile = File(image.path));
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(imageFile!, fit: BoxFit.cover),
                          )
                        : Icon(Icons.add_photo_alternate, color: Colors.white70),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: priceController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Base Price',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: unitController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Unit (e.g., kg, piece)',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: categoryController.text.isEmpty ? null : categoryController.text,
                  items: ['fruits', 'vegetables', 'meat', 'fish']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => categoryController.text = value ?? '',
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  dropdownColor: Colors.black87,
                  style: TextStyle(color: Colors.white),
                ),
                DropdownButtonFormField<String>(
                  value: marketController.text.isEmpty ? null : marketController.text,
                  items: ['Mile 12', 'Oyingbo', 'Kara']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (value) => marketController.text = value ?? '',
                  decoration: InputDecoration(
                    labelText: 'Market',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  dropdownColor: Colors.black87,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                Text('Variants', style: TextStyle(color: Colors.white, fontSize: 16)),
                ...variants.map((variant) => ListTile(
                  title: Text(variant.name, style: TextStyle(color: Colors.white)),
                  subtitle: Text('₦${variant.price}', style: TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => variants.remove(variant));
                    },
                  ),
                )),
                TextButton(
                  child: Text('Add Variant'),
                  onPressed: () => _showAddVariantDialog(context, (variant) {
                    setState(() => variants.add(variant));
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                if (nameController.text.isEmpty || 
                    priceController.text.isEmpty ||
                    categoryController.text.isEmpty ||
                    marketController.text.isEmpty) {
                  return;
                }

                final data = {
                  'name': nameController.text,
                  'price': double.parse(priceController.text),
                  'unit': unitController.text,
                  'category': categoryController.text,
                  'market': marketController.text,
                  'variants': variants.map((v) => v.toJson()).toList(),
                };

                await _firebaseService.addProduct(data, imageFile);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddVariantDialog(
    BuildContext context,
    void Function(ProductVariant variant) onAdd,
  ) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text('Add Variant', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Variant Name',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: priceController,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                return;
              }

              onAdd(ProductVariant(
                name: nameController.text,
                price: double.parse(priceController.text),
              ));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProductDialog(BuildContext context, ProductModel product) async {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final unitController = TextEditingController(text: product.unit ?? '');
    File? imageFile;
    String? existingImageUrl = product.imageUrl;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.black87,
          title: Text('Edit Product', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        imageFile = File(image.path);
                        existingImageUrl = null; // Clear existing image when new one selected
                      });
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              imageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : existingImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  existingImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.add_photo_alternate, color: Colors.white70),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: priceController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: unitController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Unit (e.g., kg, piece)',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  return;
                }

                final data = {
                  'name': nameController.text,
                  'price': double.parse(priceController.text),
                  'unit': unitController.text,
                  if (existingImageUrl != null) 'imageUrl': existingImageUrl,
                };

                await _firebaseService.updateProduct(product.id!, data, imageFile);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String id) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                await _firebaseService.deleteProduct(id);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
} 