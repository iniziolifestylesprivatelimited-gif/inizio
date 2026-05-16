// lib/screens/payment/address_form.dart

import 'package:flutter/material.dart';
import '../../models/address_model.dart';

class AddressForm extends StatefulWidget {
  final Function(Address) onSave;

  const AddressForm({super.key, required this.onSave});

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final line1Ctrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final countryCtrl = TextEditingController(text: "India");
  final pincodeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Add Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
            TextFormField(controller: line1Ctrl, decoration: const InputDecoration(labelText: "Address Line 1")),
            TextFormField(controller: cityCtrl, decoration: const InputDecoration(labelText: "City")),
            TextFormField(controller: stateCtrl, decoration: const InputDecoration(labelText: "State")),
            TextFormField(controller: pincodeCtrl, decoration: const InputDecoration(labelText: "Pincode")),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final address = Address(
                  id: "",
                  name: nameCtrl.text,
                  phone: phoneCtrl.text,
                  addressLine1: line1Ctrl.text,
                  addressLine2: null,
                  city: cityCtrl.text,
                  state: stateCtrl.text,
                  country: "India",
                  pincode: pincodeCtrl.text,
                );

                widget.onSave(address);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
