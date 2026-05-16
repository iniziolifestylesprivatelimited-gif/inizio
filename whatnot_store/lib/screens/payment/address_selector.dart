import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../address/address_screen.dart';

class AddressSelector extends StatelessWidget {
  final List<Address> addresses;
  final Address? selectedAddress;
  final bool isLoading;
  final VoidCallback onAddPressed;
  final Function(Address?) onChanged;

  const AddressSelector({
    super.key,
    required this.addresses,
    required this.selectedAddress,
    required this.isLoading,
    required this.onAddPressed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Address",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        isLoading
            ? const Center(child: CircularProgressIndicator())
            : addresses.isEmpty
                ? Column(
                    children: [
                      const Text("No address found."),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: onAddPressed,
                        child: const Text("Add Address"),
                      ),
                    ],
                  )
                :  Column(
    children: [
      ...addresses.map((address) {
        final isSelected = selectedAddress?.id == address.id;
        return InkWell(
          onTap: () => onChanged(address),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: Colors.black,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${address.name}, ${address.city}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),

      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: onAddPressed,
        icon: const Icon(Icons.add),
        label: const Text("Add New Address"),
      ),
    ],
  )


      ],
    );
  }
}
