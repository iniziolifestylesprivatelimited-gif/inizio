import 'package:flutter/material.dart';

class CartPriceSection extends StatelessWidget {
  final double offerPrice;
  final double originalPrice;

  const CartPriceSection({
    super.key,
    required this.offerPrice,
    required this.originalPrice,
  });

  String formatPrice(double price) {
    if (price % 1 == 0) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    double discountPercent = 0;

    if (offerPrice < originalPrice) {
      discountPercent =
          ((originalPrice - offerPrice) / originalPrice) * 100;
    }

    return Row(
      children: [
        Text(
          "₹${formatPrice(offerPrice)}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(width: 6),

        if (offerPrice < originalPrice)
          Text(
            "₹${formatPrice(originalPrice)}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),

        const SizedBox(width: 6),

        if (discountPercent > 0)
          Text(
            "${discountPercent.toStringAsFixed(0)}% Off",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
      ],
    );
  }
}
