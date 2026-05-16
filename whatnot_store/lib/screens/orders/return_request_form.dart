import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/return_provider.dart';

class ReturnRequestForm extends StatefulWidget {
  final Map<String, dynamic> order;
  const ReturnRequestForm({super.key, required this.order});

  @override
  State<ReturnRequestForm> createState() => _ReturnRequestFormState();
}

class _ReturnRequestFormState extends State<ReturnRequestForm> {
  final Map<String, bool> selected = {};
  final Map<String, String?> selectedReason = {};
  final Map<String, TextEditingController> otherReasonController = {};

  final List<String> returnReasons = [
    "Defective",
    "Damaged",
    "Wrong item received",
    "Item missing",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    for (var item in widget.order["items"]) {
      final pid = item["product"]["_id"];
      selected[pid] = false;
      selectedReason[pid] = null;
      otherReasonController[pid] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in otherReasonController.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rProvider = Provider.of<ReturnProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Return Items", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...widget.order["items"].map((item) {
            final product = item["product"];
            final pid = product["_id"];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(product["name"]),
                      value: selected[pid],
                      onChanged: (val) {
                        setState(() {
                          selected[pid] = val!;
                          if (!val) {
                            selectedReason[pid] = null;
                            otherReasonController[pid]!.clear();
                          }
                        });
                      },
                    ),

                    if (selected[pid] == true) ...[
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: selectedReason[pid],
                        hint: const Text("Select return reason"),
                        items: returnReasons
                            .map(
                              (reason) => DropdownMenuItem(
                                value: reason,
                                child: Text(reason),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedReason[pid] = value;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),

                      if (selectedReason[pid] == "Other") ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: otherReasonController[pid],
                          decoration: const InputDecoration(
                            labelText: "Enter reason",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ]
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          // SUBMIT BUTTON
          ElevatedButton(
            onPressed: rProvider.isLoading
                ? null
                : () async {
                    List<Map<String, dynamic>> returnItems = [];

                    for (var item in widget.order["items"]) {
                      final pid = item["product"]["_id"];

                      if (selected[pid] == true) {
                        if (selectedReason[pid] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select return reason"),
                            ),
                          );
                          return;
                        }

                        if (selectedReason[pid] == "Other" &&
                            otherReasonController[pid]!
                                .text
                                .trim()
                                .isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter reason"),
                            ),
                          );
                          return;
                        }

                        final reason = selectedReason[pid] == "Other"
                            ? otherReasonController[pid]!.text.trim()
                            : selectedReason[pid]!;

                        returnItems.add({
                          "product": pid,
                          "quantity": item["quantity"],
                          "reason": reason,
                          "note": "",
                        });
                      }
                    }

                    if (returnItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Select at least one item"),
                        ),
                      );
                      return;
                    }

                    final ok = await rProvider.createReturnRequest(
                      context,
                      widget.order["_id"],
                      returnItems,
                    );

                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Return request submitted"),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(rProvider.error ?? "Error"),
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: rProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Submit Return",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}