import 'package:flutter/material.dart';

class ProductPriceSection extends StatelessWidget {
  final double offerPrice;
  final double originalPrice;
  final int quantity;
  final double totalPrice;

  const ProductPriceSection({
    super.key,
    required this.offerPrice,
    required this.originalPrice,
      required this.quantity,
      required this.totalPrice,
  });

  String formatPrice(double price) {
    // If price is whole number → no decimals
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

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔹 UNIT PRICE (TOP)
        Row(
          children: [
            Text(
              "₹${formatPrice(offerPrice)}",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 8),

            if (offerPrice != originalPrice)
              Text(
                "₹${formatPrice(originalPrice)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),

            const SizedBox(width: 8),

            if (discountPercent > 0)
              Text(
                "${discountPercent.toStringAsFixed(0)}% Off",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),

        /// 🔥 TOTAL PRICE (BOTTOM)
        if (quantity > 1)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              "$quantity × ₹${formatPrice(offerPrice)} = ₹${formatPrice(totalPrice)}",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    ),
  );
}
}
