import 'package:flutter/material.dart';

class PaymentActionButton extends StatelessWidget {
  final bool isLoading;
  final Future<void> Function() onSubmit;

  const PaymentActionButton({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () async {
                await onSubmit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape:  RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),// 🔥 rectangle style
                ),
              ),
              child: const Text(
                "Tap to Pay",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
  }
}