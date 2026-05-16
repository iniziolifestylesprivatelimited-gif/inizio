import 'package:flutter/material.dart';
import '../orders/orders_screen.dart';

class PaymentStatusScreen extends StatefulWidget {
  final bool isSuccess;

  const PaymentStatusScreen({super.key, required this.isSuccess});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isSuccess ? Colors.green : Colors.red,
      body: Center(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 800),
          child: Icon(
            widget.isSuccess ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 120,
          ),
        ),
      ),
    );
  }
}
