import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'product_form_page.dart';

class ProductManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductFormPage()),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Update Search Terms'),
                onTap: () async {
                  try {
                    await FirebaseService().updateAllProductsWithSearchTerms();
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
      body: StreamBuilder(
        stream: FirebaseService().streamProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;
          
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ExpansionTile(
                leading: product['imageUrl'] != null
                    ? Image.network(
                        product['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported),
                      )
                    : Icon(Icons.image_not_supported),
                title: Text(product['name']),
                subtitle: Text('${product['variants']?.length ?? 0} variants'),
                children: [
                  ListTile(
                    title: Text('Variants'),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        // TODO: Show variant form
                      },
                    ),
                  ),
                  if (product['variants'] != null)
                    ...List.generate(
                      product['variants'].length,
                      (i) => ListTile(
                        title: Text('${product['variants'][i]['unit']}'),
                        subtitle: Text('₦${product['variants'][i]['price']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // TODO: Show variant edit form
                          },
                        ),
                      ),
                    ),
                  ButtonBar(
                    children: [
                      TextButton(
                        child: Text('Edit'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductFormPage(product: product),
                            ),
                          );
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () {
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
                                      await FirebaseService().deleteProduct(product['id']);
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
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
} 