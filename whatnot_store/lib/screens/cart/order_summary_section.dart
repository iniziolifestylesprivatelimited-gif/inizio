import 'package:flutter/material.dart';

class OrderSummarySection extends StatelessWidget {
  final double totalBasePrice;
  final double totalOfferPrice;

  const OrderSummarySection({
    super.key,
    required this.totalBasePrice,
    required this.totalOfferPrice,
  });

  @override
  Widget build(BuildContext context) {
    final double discount = totalBasePrice - totalOfferPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildRow("Total MRP (Base Price)", "₹${totalBasePrice.toInt()}"),
          const SizedBox(height: 6),

          _buildRow(
            "Discount",
            discount > 0 ? "-₹${discount.toInt()}" : "₹0",
            valueColor: Colors.green,
          ),

          const SizedBox(height: 12),
          const Divider(thickness: 1),

          _buildRow(
            "Total Payable",
            "₹${totalOfferPrice.toInt()}",
            isBold: true,
            valueColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {Color valueColor = Colors.black, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
