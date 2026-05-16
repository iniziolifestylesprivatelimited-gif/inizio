import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late AddressService _addressService;
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    _addressService = AddressService(token: token);
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      final addresses = await _addressService.getAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _deleteAddress(String id) async {
    try {
      await _addressService.deleteAddress(id);
      _fetchAddresses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete address')),
      );
    }
  }

  void _showAddressForm([Address? address]) {
    final _formKey = GlobalKey<FormState>();
    String name = address?.name ?? '';
    String phone = address?.phone ?? '';
    String addressLine1 = address?.addressLine1 ?? '';
    String addressLine2 = address?.addressLine2 ?? '';
    String city = address?.city ?? '';
    String state = address?.state ?? '';
    String country = address?.country ?? '';
    String pincode = address?.pincode ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(address != null ? 'Edit Address' : 'Add Address'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (val) => name = val,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => phone = val,
                  validator: (val) => val!.length != 10 ? 'Enter 10 digits' : null,
                ),
                TextFormField(
                  initialValue: addressLine1,
                  decoration: const InputDecoration(labelText: 'Address Line 1'),
                  onChanged: (val) => addressLine1 = val,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: addressLine2,
                  decoration: const InputDecoration(labelText: 'Address Line 2'),
                  onChanged: (val) => addressLine2 = val,
                ),
                TextFormField(
                  initialValue: city,
                  decoration: const InputDecoration(labelText: 'City'),
                  onChanged: (val) => city = val,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: state,
                  decoration: const InputDecoration(labelText: 'State'),
                  onChanged: (val) => state = val,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: country,
                  decoration: const InputDecoration(labelText: 'Country'),
                  onChanged: (val) => country = val,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: pincode,
                  decoration: const InputDecoration(labelText: 'Pincode'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => pincode = val,
                  validator: (val) => val!.length != 6 ? 'Enter 6 digits' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newAddress = Address(
                  id: address?.id ?? '',
                  name: name,
                  phone: phone,
                  addressLine1: addressLine1,
                  addressLine2: addressLine2,
                  city: city,
                  state: state,
                  country: country,
                  pincode: pincode,
                );
                try {
                  if (address != null) {
                    await _addressService.updateAddress(address.id, newAddress);
                  } else {
                    await _addressService.addAddress(newAddress);
                  }
                  Navigator.pop(context);
                  _fetchAddresses();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(address.name),
                    subtitle: Text('${address.addressLine1}, ${address.city}, ${address.state} - ${address.pincode}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddressForm(address),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAddress(address.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
