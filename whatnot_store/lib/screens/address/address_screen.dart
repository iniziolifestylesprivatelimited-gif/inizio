import 'dart:ui';

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

  Widget _buildField({
  required String label,
  required Function(String) onChanged,
  String? initialValue,
  TextInputType keyboard = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white30, width: 1),
        ),
        child: TextFormField(
          initialValue: initialValue,
          keyboardType: keyboard,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: InputBorder.none,
          ),
          onChanged: onChanged,
        ),
      ),
      const SizedBox(height: 14),
    ],
  );
}


  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    _addressService = AddressService(token: token);
    _fetchAddresses();
  }
  
  void showTopOverlayMessage(String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 2), () {
    entry.remove();
  });
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
      showTopOverlayMessage(e.toString());

    }
  }

  void _deleteAddress(String id) async {
    try {
      await _addressService.deleteAddress(id);
      _fetchAddresses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete address')),
      );
    }
  }

  // ================= SEARCHABLE BOTTOM SHEET FUNCTION =================
  Future<T?> _showSearchableBottomSheet<T>({
    required List<T> items,
    required String Function(T) label,
    required String title,
  }) {
    TextEditingController searchCtrl = TextEditingController();
    List<T> filtered = List.from(items);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: searchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setStateSheet(() {
                          filtered = items
                              .where((e) =>
                                  label(e).toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, index) {
                          return ListTile(
                            title: Text(label(filtered[index])),
                            onTap: () => Navigator.pop(context, filtered[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  

  // ================= SHOW ADDRESS FORM =================
 void _showAddressForm([Address? address]) {
  final _formKey = GlobalKey<FormState>();

  String name = address?.name ?? '';
  String phone = address?.phone ?? '';
  String addressLine1 = address?.addressLine1 ?? '';
  String addressLine2 = address?.addressLine2 ?? '';
  String pincode = address?.pincode ?? '';

  String? selectedCountryCode;
  String? selectedStateCode;
  String? selectedCity;

  List countries = [];
  List states = [];
  List cities = [];

  bool loadingCountries = true;
  bool loadingStates = false;
  bool loadingCities = false;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (context, animation1, __, child) {
      return Transform.scale(
        scale: animation1.value,
        child: Opacity(
          opacity: animation1.value,
          child: Center(
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                if (loadingCountries) {
                  _addressService.getCountries().then((value) {
                    setStateDialog(() {
                      countries = value;
                      loadingCountries = false;
                    });
                  });
                }

                return Material(
                  type: MaterialType.transparency,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.88,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: AnimatedPadding(
                            duration: const Duration(milliseconds: 200),
  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    address != null ? "Edit Address" : "Add Address",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                            
                                  _buildField(
                                    label: "Full Name",
                                    initialValue: name,
                                    keyboard: TextInputType.name,
                                    onChanged: (v) => name = v,
                                  ),
                                  _buildField(
                                    label: "Phone Number",
                                    initialValue: phone,
                                    keyboard: TextInputType.phone,
                                    onChanged: (v) => phone = v,
                                  ),
                                  _buildField(
                                    label: "Address Line 1",
                                    initialValue: addressLine1,
                                    onChanged: (v) => addressLine1 = v,
                                  ),
                                  _buildField(
                                    label: "Address Line 2",
                                    initialValue: addressLine2,
                                    onChanged: (v) => addressLine2 = v,
                                  ),
                                            
                                  _buildField(
                            label: "Pincode",
                            initialValue: pincode,
                            keyboard: TextInputType.number,
                            onChanged: (v) => pincode = v,
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // ============= COUNTRY PICKER =============
                          loadingCountries
                              ? const CircularProgressIndicator(color: Colors.white)
                              : InkWell(
                                  onTap: () async {
                                    final result = await _showSearchableBottomSheet(
                                      items: countries,
                                      label: (c) => c['name'],
                                      title: "Select Country",
                                    );
                                    if (result != null) {
                                      setStateDialog(() {
                                        selectedCountryCode = result['isoCode'];
                                        selectedStateCode = null;
                                        selectedCity = null;
                                        loadingStates = true;
                                      });
                          
                                      states = await _addressService.getStates(selectedCountryCode!);
                                      setStateDialog(() => loadingStates = false);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white30, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedCountryCode != null
                                              ? countries.firstWhere((e) => e['isoCode'] == selectedCountryCode)['name']
                                              : "Select Country",
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        const Icon(Icons.arrow_drop_down, color: Colors.white70)
                                      ],
                                    ),
                                  ),
                                ),
                          
                          const SizedBox(height: 10),
                          
                          // ============= STATE PICKER =============
                          loadingStates
                              ? const CircularProgressIndicator(color: Colors.white)
                              : InkWell(
                                  onTap: () async {
                                    final result = await _showSearchableBottomSheet(
                                      items: states,
                                      label: (s) => s['name'],
                                      title: "Select State",
                                    );
                                    if (result != null) {
                                      setStateDialog(() {
                                        selectedStateCode = result['isoCode'];
                                        loadingCities = true;
                                      });
                          
                                      cities = await _addressService.getCities(selectedCountryCode!, selectedStateCode!);
                                      setStateDialog(() => loadingCities = false);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white30, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedStateCode != null
                                              ? states.firstWhere((e) => e['isoCode'] == selectedStateCode)['name']
                                              : "Select State",
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        const Icon(Icons.arrow_drop_down, color: Colors.white70)
                                      ],
                                    ),
                                  ),
                                ),
                          
                          const SizedBox(height: 10),
                          
                          // ============= CITY PICKER =============
                          loadingCities
                              ? const CircularProgressIndicator(color: Colors.white)
                              : InkWell(
                                  onTap: () async {
                                    final result = await _showSearchableBottomSheet(
                                      items: cities,
                                      label: (c) => c['name'],
                                      title: "Select City",
                                    );
                                    if (result != null) {
                                      setStateDialog(() => selectedCity = result['name']);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white30, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedCity ?? "Select City",
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        const Icon(Icons.arrow_drop_down, color: Colors.white70)
                                      ],
                                    ),
                                  ),
                                ),
                          
                                            
                                  const SizedBox(height: 22),
                                            
                                  // BUTTONS
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Colors.white.withOpacity(0.8)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () async {
                                            if (_formKey.currentState!.validate()) {
                                              final newAddress = Address(
                                                id: address?.id ?? "",
                                                name: name,
                                                phone: phone,
                                                addressLine1: addressLine1,
                                                addressLine2: addressLine2,
                                               country: countries.firstWhere((e) => e['isoCode'] == selectedCountryCode)['name'],
                          state: states.firstWhere((e) => e['isoCode'] == selectedStateCode)['name'],
                          city: selectedCity!,
                          
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
                                               showTopOverlayMessage(e.toString());

                                              }
                                            }
                                          },
                                          child: const Text(
                                            "Save",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Addresses', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return Container(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.black.withOpacity(0.12)),
    color: Colors.black.withOpacity(0.06),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.location_on, color: Colors.black, size: 22),
      const SizedBox(width: 10),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${address.addressLine1}, ${address.city}, ${address.state} - ${address.pincode}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.7),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),

      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () => _showAddressForm(address),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteAddress(address.id),
          ),
        ],
      ),
    ],
  ),
);

              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _showAddressForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


