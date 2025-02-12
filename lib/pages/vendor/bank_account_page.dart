import 'package:flutter/material.dart';
import '../../models/vendor_bank_account.dart';
import '../../services/firebase_service.dart';
import '../../services/payout_service.dart';
import '../../config/config.dart';

class BankAccountPage extends StatefulWidget {
  final String vendorId;

  const BankAccountPage({
    Key? key,
    required this.vendorId,
  }) : super(key: key);

  @override
  State<BankAccountPage> createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBank;
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bank Account')),
      body: StreamBuilder<VendorBankAccount?>(
        stream: FirebaseService().getVendorBankAccountStream(widget.vendorId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return _buildAccountForm();
          }

          final account = snapshot.data;
          return account == null
              ? _buildAccountForm()
              : _buildAccountDetails(account);
        },
      ),
    );
  }

  Widget _buildAccountForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _selectedBank,
            decoration: InputDecoration(labelText: 'Select Bank'),
            items: Config.bankCodes.keys.map((bank) {
              return DropdownMenuItem(
                value: bank,
                child: Text(bank),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedBank = value),
            validator: (value) =>
                value == null ? 'Please select a bank' : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _accountNumberController,
            decoration: InputDecoration(labelText: 'Account Number'),
            keyboardType: TextInputType.number,
            maxLength: 10,
            validator: (value) =>
                value?.length != 10 ? 'Enter valid account number' : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _accountNameController,
            decoration: InputDecoration(labelText: 'Account Name'),
            textCapitalization: TextCapitalization.words,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Enter account name' : null,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
                ? CircularProgressIndicator()
                : Text('Add Bank Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetails(VendorBankAccount account) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              title: Text(account.bankName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.accountName),
                  Text('**** ${account.accountNumber.substring(6)}'),
                  Text(
                    account.isVerified ? 'Verified' : 'Pending Verification',
                    style: TextStyle(
                      color: account.isVerified ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!account.isVerified) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _verifyAccount(account),
              child: Text('Verify Account'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final account = VendorBankAccount(
        id: '',
        vendorId: widget.vendorId,
        bankName: _selectedBank!,
        accountNumber: _accountNumberController.text,
        accountName: _accountNameController.text,
        createdAt: DateTime.now(),
      );

      await FirebaseService().addVendorBankAccount(account);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bank account added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAccount(VendorBankAccount account) async {
    setState(() => _isLoading = true);
    try {
      await PayoutService().verifyBankAccount(account);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account verified successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
} 