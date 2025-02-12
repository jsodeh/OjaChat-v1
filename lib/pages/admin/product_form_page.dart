import 'package:flutter/material.dart';
import '../../models/product_variant.dart';
import '../../services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductFormPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormPage({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<ProductVariant> _variants = [];
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'];
      _descriptionController.text = widget.product!['description'] ?? '';
      _variants = (widget.product!['variants'] as List? ?? [])
          .map((v) => ProductVariant.fromMap(v['id'] ?? '', v))
          .toList();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _addVariant() async {
    final variant = await showDialog<ProductVariant>(
      context: context,
      builder: (_) => VariantFormDialog(),
    );

    if (variant != null) {
      setState(() => _variants.add(variant));
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add at least one variant')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'variants': _variants.map((v) => v.toMap()).toList(),
      };

      if (widget.product != null) {
        await FirebaseService().updateProduct(
          widget.product!['id'],
          productData,
          _imageFile,
        );
      } else {
        await FirebaseService().addProduct(productData, _imageFile);
      }

      Navigator.pop(context);
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
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'New Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : widget.product?['imageUrl'] != null
                        ? Image.network(widget.product!['imageUrl'])
                        : Icon(Icons.add_photo_alternate, size: 64),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Variants',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add Variant'),
                  onPressed: _addVariant,
                ),
              ],
            ),
            ..._variants.map((variant) => Card(
              child: ListTile(
                title: Text(variant.unit),
                subtitle: Text('₦${variant.price}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() => _variants.remove(variant));
                  },
                ),
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? CircularProgressIndicator()
                : Text('Save Product'),
          ),
        ),
      ),
    );
  }
} 

class VariantFormDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Variant'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Size/Weight'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Add'),
        ),
      ],
    );
  }
}