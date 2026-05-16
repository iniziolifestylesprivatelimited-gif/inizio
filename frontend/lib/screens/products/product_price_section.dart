import 'package:flutter/material.dart';

class ProductPriceSection extends StatelessWidget {
  final double offerPrice;
  final double originalPrice;

  const ProductPriceSection({
    super.key,
    required this.offerPrice,
    required this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            "₹${offerPrice.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 22,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          if (offerPrice != originalPrice)
            Text(
              "₹${originalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
        ],
      ),
    );
  }
}
