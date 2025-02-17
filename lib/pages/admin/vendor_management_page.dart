import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/vendor_model.dart';
import '../../styles/app_theme.dart';

class VendorManagementPage extends StatefulWidget {
  @override
  _VendorManagementPageState createState() => _VendorManagementPageState();
}

class _VendorManagementPageState extends State<VendorManagementPage> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedFilter = 'all'; // all, active, inactive

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Vendor Management'),
        actions: [
          _buildFilterButton(),
        ],
      ),
      body: StreamBuilder<List<VendorModel>>(
        stream: _firebaseService.streamVendors(_selectedFilter),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final vendors = snapshot.data!;
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: vendors.length,
            itemBuilder: (context, index) {
              final vendor = vendors[index];
              return _buildVendorCard(vendor);
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.filter_list),
      onSelected: (value) {
        setState(() => _selectedFilter = value);
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'all',
          child: Text('All Vendors'),
        ),
        PopupMenuItem(
          value: 'active',
          child: Text('Active Vendors'),
        ),
        PopupMenuItem(
          value: 'inactive',
          child: Text('Inactive Vendors'),
        ),
      ],
    );
  }

  Widget _buildVendorCard(VendorModel vendor) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: vendor.isActive ? Colors.green : Colors.grey,
          child: Icon(Icons.store, color: Colors.white),
        ),
        title: Text(
          vendor.name,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          vendor.market,
          style: TextStyle(color: Colors.white70),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Phone', vendor.phone),
                _buildInfoRow('Email', vendor.email),
                _buildInfoRow('Products', vendor.products.join(', ')),
                _buildInfoRow('Joined', _formatDate(vendor.createdAt)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        vendor.isActive ? Icons.block : Icons.check_circle,
                        color: vendor.isActive ? Colors.red : Colors.green,
                      ),
                      label: Text(
                        vendor.isActive ? 'Deactivate' : 'Activate',
                        style: TextStyle(
                          color: vendor.isActive ? Colors.red : Colors.green,
                        ),
                      ),
                      onPressed: () => _toggleVendorStatus(vendor),
                    ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => _showDeleteConfirmation(vendor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _toggleVendorStatus(VendorModel vendor) async {
    try {
      await _firebaseService.updateVendorStatus(
        vendor.id,
        !vendor.isActive,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vendor.isActive
                ? 'Vendor deactivated successfully'
                : 'Vendor activated successfully',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(VendorModel vendor) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          'Delete Vendor',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${vendor.name}? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
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
                await _firebaseService.deleteVendor(vendor.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vendor deleted successfully')),
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
    );
  }
} 