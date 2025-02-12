import 'package:flutter/material.dart';
import '../../models/product_variant.dart';

class VariantFormDialog extends StatefulWidget {
  final ProductVariant? variant;

  const VariantFormDialog({Key? key, this.variant}) : super(key: key);

  @override
  State<VariantFormDialog> createState() => _VariantFormDialogState();
}

class _VariantFormDialogState extends State<VariantFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.variant != null) {
      _unitController.text = widget.variant!.unit;
      _priceController.text = widget.variant!.price.toString();
      _stockController.text = widget.variant!.stock?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.variant != null ? 'Edit Variant' : 'New Variant'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: 'Unit (e.g., kg, basket)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price (₦)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (double.tryParse(v!) == null) return 'Invalid number';
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              decoration: InputDecoration(
                labelText: 'Stock (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty ?? true) return null;
                if (int.tryParse(v!) == null) return 'Invalid number';
                return null;
              },
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                ProductVariant(
                  id: widget.variant?.id,
                  unit: _unitController.text,
                  price: double.parse(_priceController.text),
                  stock: _stockController.text.isEmpty
                      ? null
                      : int.parse(_stockController.text),
                ),
              );
            }
          },
        ),
      ],
    );
  }
} 